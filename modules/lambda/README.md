<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_archive"></a> [archive](#provider_archive) | n/a     |
| <a name="provider_aws"></a> [aws](#provider_aws)             | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                     | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_autoscaling_lifecycle_hook.asg_lambda_hook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource    |
| [aws_cloudwatch_event_rule.launch_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)            | resource    |
| [aws_cloudwatch_event_target.lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)         | resource    |
| [aws_cloudwatch_log_group.loggroup_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)             | resource    |
| [aws_iam_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                   | resource    |
| [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                      | resource    |
| [aws_iam_role_policy_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)          | resource    |
| [aws_lambda_function.lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                       | resource    |
| [aws_lambda_permission.allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                  | resource    |
| [archive_file.zip_the_python_code](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                              | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)         | data source |
| [aws_iam_policy_document.lambda_custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)       | data source |

## Inputs

| Name                                                               | Description                | Type  | Default | Required |
| ------------------------------------------------------------------ | -------------------------- | ----- | ------- | :------: |
| <a name="input_asg"></a> [asg](#input_asg)                         | auto scaling group         | `any` | n/a     |   yes    |
| <a name="input_environment"></a> [environment](#input_environment) | The deployment environment | `any` | n/a     |   yes    |
| <a name="input_project"></a> [project](#input_project)             | The name of the project    | `any` | n/a     |   yes    |
| <a name="input_region_used"></a> [region_used](#input_region_used) | Region                     | `any` | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
