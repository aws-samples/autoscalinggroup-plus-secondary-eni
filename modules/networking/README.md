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

| Name                                                                                                                                          | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                            | resource    |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                      | resource    |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                | resource    |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                    | resource    |
| [aws_route.public_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                     | resource    |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                            | resource    |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                             | resource    |
| [aws_route_table_association.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource    |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)    | resource    |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)     | resource    |
| [aws_security_group.management_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                | resource    |
| [aws_security_group.sg_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                   | resource    |
| [aws_subnet.management_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                           | resource    |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                              | resource    |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                               | resource    |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                               | resource    |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)         | data source |

## Inputs

| Name                                                                                                   | Description                              | Type  | Default | Required |
| ------------------------------------------------------------------------------------------------------ | ---------------------------------------- | ----- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input_environment)                                     | The deployment environment               | `any` | n/a     |   yes    |
| <a name="input_management_subnets_cidr"></a> [management_subnets_cidr](#input_management_subnets_cidr) | CIDR block og management subnet          | `any` | n/a     |   yes    |
| <a name="input_private_subnets_cidr"></a> [private_subnets_cidr](#input_private_subnets_cidr)          | CIDR block of private subnets            | `any` | n/a     |   yes    |
| <a name="input_project"></a> [project](#input_project)                                                 | The name of the project                  | `any` | n/a     |   yes    |
| <a name="input_public_subnets_cidr"></a> [public_subnets_cidr](#input_public_subnets_cidr)             | CIDR blocks of public subnets            | `any` | n/a     |   yes    |
| <a name="input_region"></a> [region](#input_region)                                                    | The region where the project is deployed | `any` | n/a     |   yes    |
| <a name="input_vpc_cidr"></a> [vpc_cidr](#input_vpc_cidr)                                              | Cidr range for the custom vpc            | `any` | n/a     |   yes    |

## Outputs

| Name                                                                             | Description |
| -------------------------------------------------------------------------------- | ----------- |
| <a name="output_igw"></a> [igw](#output_igw)                                     | n/a         |
| <a name="output_management_sg"></a> [management_sg](#output_management_sg)       | n/a         |
| <a name="output_private_subnets"></a> [private_subnets](#output_private_subnets) | n/a         |
| <a name="output_public_subnets"></a> [public_subnets](#output_public_subnets)    | n/a         |
| <a name="output_sg_default"></a> [sg_default](#output_sg_default)                | n/a         |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id)                            | n/a         |

<!-- END_TF_DOCS -->
