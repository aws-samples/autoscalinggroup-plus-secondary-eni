#kms key policy 
data "aws_iam_policy_document" "custom_policy" {
  version = "2012-10-17"
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::412165491374:root"]
    }
  }
  statement {
    sid       = "Allow access for Key Admin"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]
    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::412165491374:user/UserPA",
        "arn:aws:iam::412165491374:role/Admin",
        "arn:aws:iam::412165491374:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
      ]
    }
  }
  statement {
    sid       = "Allow attachment of persistent resources"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::412165491374:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
    }
  }
  statement {
    sid    = "Allow service-linked role to use CMK"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::412165491374:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "aws_lb" "nlb" {
  name               = "${var.project}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnets.*.id


}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.project}-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    interval            = "30"
    port                = "80"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_kms_key" "custom_key" {
  description = "customer managed key"
  policy      = data.aws_iam_policy_document.custom_policy.json

}
resource "aws_kms_alias" "custom_key_alias" {
  name          = "alias/my-custom-key-1"
  target_key_id = aws_kms_key.custom_key.id
}


resource "aws_launch_template" "template" {
  name                   = "template1"
  image_id               = var.instance_id
  instance_type          = var.instance_size
  vpc_security_group_ids = ["${var.sg_default}"]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = true
      kms_key_id  = aws_kms_key.custom_key.arn
      volume_size = 8
    }
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project}-${var.environment}-LaunchTemplateInstance"
    }
  }



}


resource "aws_autoscaling_group" "asg" {
  name                = "${var.project}-asg"
  vpc_zone_identifier = var.private_subnets.*.id
  min_size            = var.min_asg_size
  desired_capacity    = var.desired_asg_size
  max_size            = var.max_asg_size
  launch_template {
    id      = aws_launch_template.template.id
    version = aws_launch_template.template.latest_version
  }
  target_group_arns = ["${aws_lb_target_group.target_group.arn}"]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",

  ]

}



