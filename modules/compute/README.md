<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                        | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)                  | resource    |
| [aws_kms_alias.custom_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                     | resource    |
| [aws_kms_key.custom_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                               | resource    |
| [aws_launch_template.template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template)                 | resource    |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)                                                | resource    |
| [aws_lb_listener.listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)                         | resource    |
| [aws_lb_target_group.target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)             | resource    |
| [aws_iam_policy_document.custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name                                                                              | Description                                              | Type  | Default | Required |
| --------------------------------------------------------------------------------- | -------------------------------------------------------- | ----- | ------- | :------: |
| <a name="input_desired_asg_size"></a> [desired_asg_size](#input_desired_asg_size) | desired size                                             | `any` | n/a     |   yes    |
| <a name="input_environment"></a> [environment](#input_environment)                | The deployment environment                               | `any` | n/a     |   yes    |
| <a name="input_instance_id"></a> [instance_id](#input_instance_id)                | The ID of the AMI to be used in the launch configuration | `any` | n/a     |   yes    |
| <a name="input_instance_size"></a> [instance_size](#input_instance_size)          | The size of the instance                                 | `any` | n/a     |   yes    |
| <a name="input_management_sg"></a> [management_sg](#input_management_sg)          | management SG                                            | `any` | n/a     |   yes    |
| <a name="input_max_asg_size"></a> [max_asg_size](#input_max_asg_size)             | max size                                                 | `any` | n/a     |   yes    |
| <a name="input_min_asg_size"></a> [min_asg_size](#input_min_asg_size)             | min size                                                 | `any` | n/a     |   yes    |
| <a name="input_private_subnets"></a> [private_subnets](#input_private_subnets)    | private Subnets created by networking module             | `any` | n/a     |   yes    |
| <a name="input_project"></a> [project](#input_project)                            | The name of the project                                  | `any` | n/a     |   yes    |
| <a name="input_public_subnets"></a> [public_subnets](#input_public_subnets)       | Public Subnets created by networking module              | `any` | n/a     |   yes    |
| <a name="input_region"></a> [region](#input_region)                               | The region where the project is deployed                 | `any` | n/a     |   yes    |
| <a name="input_sg_default"></a> [sg_default](#input_sg_default)                   | Default SG                                               | `any` | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                               | custom vpc id                                            | `any` | n/a     |   yes    |

## Outputs

| Name                                         | Description |
| -------------------------------------------- | ----------- |
| <a name="output_asg"></a> [asg](#output_asg) | n/a         |

<!-- END_TF_DOCS -->
