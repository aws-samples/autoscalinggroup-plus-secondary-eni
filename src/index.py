from logging import Filter
import boto3
import botocore
from datetime import datetime
import json
import time

ec2_client = boto3.client('ec2')
ec2_res = boto3.resource('ec2')
asg_client = boto3.client('autoscaling')

def lambda_handler(event, context = None):
  """ 
  Lambda Handler

  Takes the event from asg life cycle hook and attach secondary eni

  :param event: takes event triggered by cloudwatch rule from asg
  """
  
  # printing event received:
  log(f'event received: {event}')

  event_type = event["detail-type"]

  if (event_type == "EC2 Instance-launch Lifecycle Action"):
    try:

      #Grabs instance being launched
      instance_id = event["detail"]["EC2InstanceId"]
      log("Instance: {}".format(instance_id))
      instance = ec2_res.Instance(instance_id)
      az = ec2_client.describe_subnets(SubnetIds=[instance.subnet_id])['Subnets'][0]['AvailabilityZone']

     


      life_cycle_hook_name = event['detail']['LifecycleHookName']
      auto_scaling_group_name = event['detail']['AutoScalingGroupName']
      
      log("Here is the instance id: {}".format(instance_id))
      log("Here is the lifecycle hook: {}".format(life_cycle_hook_name))
      log("Here is the autoscaling group name: {}".format(auto_scaling_group_name))

      #Start prep creation of eni in management subnet with management SG
      #Grabs management subnet 
      subnet_mgmnt_id = ec2_client.describe_subnets(
        Filters = [
          {
            'Name': 'tag:Purpose',
            'Values': [
              'management'
            ]
          },
          {
              'Name':'availability-zone',
              'Values': [az]
          }
        ]  
        
      )['Subnets'][0]['SubnetId']
      if not subnet_mgmnt_id or subnet_mgmnt_id is None:
        raise Exception("Error finding the management subnet id")

      #Creates secondary eni
      secondary_eni = ec2_res.create_network_interface(
        SubnetId = subnet_mgmnt_id,
        TagSpecifications=[
          {
            'ResourceType':'network-interface',
            'Tags': [
                {
                    'Key': 'Name',
                    'Value': 'management-eni'
                },
                {
                  'Key': 'Purpose',
                  'Value': 'management'
                }
            ]
          },
        ]
      )

      if not secondary_eni or secondary_eni is None:
        raise Exception("Error creating secondary eni")

      #Attaches management SG 
      managed_sg = ec2_client.describe_security_groups(
        Filters = [
          {
            'Name': 'tag:Purpose',
            'Values': [
              'management'
            ]
          }  

        ]
      )['SecurityGroups'][0]['GroupId']

      #Attach security group to ENI
      ec2_client.modify_network_interface_attribute(
          Groups=[
              managed_sg,
          ],
          NetworkInterfaceId=secondary_eni.id,
      )

      #wait for ENI to become available 
      err = waitEniReady(secondary_eni.id)
      if err == 'false':
          raise Exception("Failure waiting for ENI to be ready")


      #Attach eni to instance
      attachment = attach_interface(secondary_eni.id,instance_id,device_index=1)
      if not attachment:
          complete_lifecycle_action_failure(life_cycle_hook_name, auto_scaling_group_name, instance_id)
          raise Exception("Unable to attach interface {}". format(secondary_eni))

      
      



      # network_interface_id = secondary_eni.id
      # #network_interface['NetworkInterfaces'][0]['NetworkInterfaceId']
      # log("Network interface id: {}".format(network_interface_id))
      # network_interface_status = network_interface['NetworkInterfaces'][0]['Status']
      # log("Network interface status: {}".format(network_interface_status))

      #checking status
      # if network_interface_status != 'available':
      #   log("Not Available so Detaching it first.")
      #   network_attachment_id = network_interface['NetworkInterfaces'][0]['Attachment']['AttachmentId']

      #   # check if detachment is successful
      #   if not detach_eni(network_interface_id, instance_id,network_attachment_id):
      #       complete_lifecycle_action_failure(life_cycle_hook_name, auto_scaling_group_name, instance_id)
      #       raise Exception(
      #         "Unable to detach interface"
      #       )
      # else:
      #   log('ENI Already Available so attaching it')
      #   log("Instance id: {}".format(instance_id))
      #   attachment = attach_interface(network_interface_id,instance_id,device_index=1)

      #   if not attachment:
      #     complete_lifecycle_action_failure(life_cycle_hook_name, auto_scaling_group_name, instance_id)
      #     raise Exception("Unable to attach interface {}". format(network_interface))

      try:
        complete_lifecycle_action_success(life_cycle_hook_name, auto_scaling_group_name, instance_id)
      except botocore.exceptions.ClientError as e:
        complete_lifecycle_action_failure(life_cycle_hook_name, auto_scaling_group_name, instance_id)
        raise Exception("Error completing life cycle hook for instance {}: ".format(instance_id))

    except botocore.exceptions.ClientError as e:
      log(e)
    except Exception as e:
      log(e)
 
  else:
    log("Irrelevant Event Identified")


def waitEniReady(Id):
    try:
        waiter = ec2_client.get_waiter('network_interface_available')
        waiter.wait(NetworkInterfaceIds=[Id], Filters= [{'Name' : 'status', 'Values': ['available']}])
        print(waiter)
    except Exception as e:
        print(Id)
        return 'false'
    else:
       return 'true'

def detach_eni(network_interface_id, instance_id, attachment_id):
  """
  detach network interface if it's attached to instance

  :param network_interface_id: network interface id that 
                               we get from network interface description 
                               which we get from instance tag

  :param instance_id: Instance id of the instance launch by asg life cycle event
  """

  # Retry logic:
  count = 0
  while count <= 5:
    try:
      detachment_eni = ec2_client.detach_network_interface(
          AttachmentId=attachment_id,
          Force=True
      )
      log("Detaching ENI", detachment_eni)
      
      if detachment_eni['ResponseMetadata']['HTTPStatusCode'] == 200:
        log("Detached Successfuly")
        attachment = attach_interface(network_interface_id,instance_id,device_index=1)
        if attachment:
          return True
        else: 
          return False
      else:
        count = count + 1
        time.sleep(10)
          
    except botocore.exceptions.ClientError as e:
      if count >= 5: 
        raise Exception ("Error detaching eni {}".format(attachment_id))
      else:
        count = count + 1
        time.sleep(10)

  return False

def attach_interface(network_interface_id, instance_id, device_index):

  attachment = None
  count = 0
  if network_interface_id and instance_id:
    # retry logic
    while count <= 5:
      try:
        log(f'Trying to attach retry: {count}')
        attach_elastic_interface = ec2_client.attach_network_interface (
            NetworkInterfaceId = network_interface_id,
            InstanceId = instance_id,
            DeviceIndex = device_index
        )
        log(f'Attach_interface {attach_elastic_interface}')
        attachment = attach_elastic_interface['AttachmentId']
        log("Created network attachment: {}".format(attachment))
        
        if attachment:
          return attachment
        else:
          count = count + 1
          time.sleep(10)
      except botocore.exceptions.ClientError as e:
        if count >= 5: 
          raise Exception ("Error attaching interface: {}".format(e))
        else:
          count = count + 1
          time.sleep(10)
    return False

def complete_lifecycle_action_success(hookname,groupname,instance_id):
  """ 
  Complete Lifecycle Action Success

  Complete the lifecycle with success if no exception occurs

  :param hookname: Life cycle hook name
  :param groupname: Autoscaling group name
  :param instanceid: Instance id for newly launched instance

  """

  try:
      asg_client.complete_lifecycle_action(
              LifecycleHookName=hookname,
              AutoScalingGroupName=groupname,
              InstanceId=instance_id,
              LifecycleActionResult='CONTINUE'
          )
      log("Lifecycle hook CONTINUEd for: {}".format(instance_id))
  except botocore.exceptions.ClientError as e:
      raise Exception("Error completing life cycle hook for instance {}: {}".format(instance_id, e.response['Error']))
            
def complete_lifecycle_action_failure(hookname,groupname,instance_id):
  """ 
  Complete Lifecycle Action Failure

  Complete the lifecycle with failure if exception occurs

  :param hookname: Life cycle hook name
  :param groupname: Autoscaling group name
  :param instanceid: Instance id for newly launched instance

  """
  try:
      asg_client.complete_lifecycle_action(
              LifecycleHookName=hookname,
              AutoScalingGroupName=groupname,
              InstanceId=instance_id,
              LifecycleActionResult='ABANDON'
          )
      log("Lifecycle hook ABANDONed for: {}".format(instance_id))
  except botocore.exceptions.ClientError as e:
      raise Exception("Error completing life cycle hook for instance {}: {}".format(instance_id, e.response['Error']))
          
def log(message):
  """ 
  Log

  takes message as an input and print it with time in iso format 
  """
  print (datetime.utcnow().isoformat() + 'Z ' , message)  
