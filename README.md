# Automated Deployment of a Secondary Management ENI with Terraform

## Description

Leveraging EC2 Launch Templates for use with EC2 AutoScaling Groups is a recommended best practice. However, some applications require an instance to connect to multiple subnets(vlans); such as a management network, public network, and a private network. When LaunchTemplates are used by an AutoScalingGroup (ASG) it will only recognize the first subnet specified in the launch template. In order to overcome this limitation and automate deployment of multiple subnets on these instances, customers can utilize an AWS Lambda function to create additional Elastic Network Interfaces(ENIs) in distinct subnets and attach the Elastic Network Interfaces to newly launched instances.

## Prerequisites:

- [terraform >= 0.14.9](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Usage

The below demonstrates how you can use this module:

```
module "attach_eni" {
  source                = "./lifecycle-hooks"
  asg_name              = var.asg_name
  default_result        = "ABANDON"
  detail = {
    "AutoScalingGroupName": ["${var.asg_name}"],
    "LifecycleTransition": ["autoscaling:EC2_INSTANCE_LAUNCHING"],
    "Origin": ["EC2"],
    "LifecycleHookName": ["attach_enis"]
  }
  environment           = var.environment
  environment_variables = {
      mgmt_subnet_az1         = "mgmt-az1"
      mgmt_subnet_az2         = "mgmt-az2"
      pvt_subnet_az1          = "private-az1"
      pvt_subnet_az2          = "private--az2"
      mgmt_sg_var             = "mgmt-sg"
      pvt_sg_var              = "private-sg"
  }
  event_rule_details    = ["EC2 Instance-launch Lifecycle Action"]
  file_contents         = file("${path.module}/lambda/${var.attach_filename}")
  filename              = var.attach_filename
  heartbeat_timeout     = 120
  lambda_key_arn        = var.lambda_key_arn
  lambda_role_arn       = var.lambda_role_arn
  lifecycle_hook_name   = "attach_enis"
  lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
}

```

The code above will deploy the components necessary to bootstrap an ASG with secondary ENIs from a fresh AWS Account, including: The ASG, CloudWatch alarms, Subnets, ENIs, secondary ENIs, a Lambda function for attaching secondary ENIs, load balancers, IAM roles and policies, VPC, NAT gateways, Internet Gateways, Route Tables, and Security Groups.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.14.9 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.2.0  |

## Providers

No providers.

## Modules

| Name                                                              | Source               | Version |
| ----------------------------------------------------------------- | -------------------- | ------- |
| <a name="module_compute"></a> [compute](#module_compute)          | ./modules/compute    | n/a     |
| <a name="module_lambda"></a> [lambda](#module_lambda)             | ./modules/lambda     | n/a     |
| <a name="module_networking"></a> [networking](#module_networking) | ./modules/networking | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                                                   | Description                                              | Type     | Default       | Required |
| ------------------------------------------------------------------------------------------------------ | -------------------------------------------------------- | -------- | ------------- | :------: |
| <a name="input_desired_asg_size"></a> [desired_asg_size](#input_desired_asg_size)                      | desired size                                             | `any`    | n/a           |   yes    |
| <a name="input_environment"></a> [environment](#input_environment)                                     | The deployment environment                               | `string` | `"dev"`       |    no    |
| <a name="input_instance_id"></a> [instance_id](#input_instance_id)                                     | The ID of the AMI to be used in the launch configuration | `string` | n/a           |   yes    |
| <a name="input_instance_size"></a> [instance_size](#input_instance_size)                               | The size of the instance                                 | `string` | n/a           |   yes    |
| <a name="input_management_subnets_cidr"></a> [management_subnets_cidr](#input_management_subnets_cidr) | CIDR block og management subnet                          | `any`    | n/a           |   yes    |
| <a name="input_max_asg_size"></a> [max_asg_size](#input_max_asg_size)                                  | max size                                                 | `any`    | n/a           |   yes    |
| <a name="input_min_asg_size"></a> [min_asg_size](#input_min_asg_size)                                  | min size                                                 | `any`    | n/a           |   yes    |
| <a name="input_private_subnets_cidr"></a> [private_subnets_cidr](#input_private_subnets_cidr)          | CIDR block of private subnets                            | `any`    | n/a           |   yes    |
| <a name="input_project"></a> [project](#input_project)                                                 | The name of the project                                  | `any`    | n/a           |   yes    |
| <a name="input_public_subnets_cidr"></a> [public_subnets_cidr](#input_public_subnets_cidr)             | CIDR blocks of public subnets                            | `any`    | n/a           |   yes    |
| <a name="input_region"></a> [region](#input_region)                                                    | n/a                                                      | `string` | `"us-east-1"` |    no    |
| <a name="input_vpc_cidr"></a> [vpc_cidr](#input_vpc_cidr)                                              | The CIDR block of the vpc                                | `any`    | n/a           |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
