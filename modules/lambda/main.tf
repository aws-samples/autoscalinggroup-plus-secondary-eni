data "aws_iam_policy_document" "assume_role_policy" {
  statement {
      actions = ["sts:AssumeRole"]

      principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_custom_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:*"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["elasticloadbalancing:*"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["cloudwatch:*"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["autoscaling:*"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"

      values = [
        "autoscaling.amazonaws.com",
        "ec2scheduled.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "spot.amazonaws.com",
        "spotfleet.amazonaws.com",
        "transitgateway.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:logs:us-east-1:412165491374:log-group:/aws/lambda/my_lambda:*:*",
      "arn:aws:logs:us-east-1:412165491374:log-group:/aws/lambda/my_lambda:*",
    ]

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]
  }
}


resource "aws_iam_policy" "lambda_policy" {
  name = "my_lambda_policy"
  path = "/"
  policy = data.aws_iam_policy_document.lambda_custom_policy.json
  
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "my_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  
}

resource "aws_iam_role_policy_attachment" "attach" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "zip_the_python_code" {
  type = "zip"
  source_dir = "./src/"
  output_path = "./src/lambda-pythonv1.zip"
}




resource "aws_lambda_function" "lambda_function" {
  function_name = "my_lambda"
  role = aws_iam_role.iam_for_lambda.arn
  filename = "./src/lambda-pythonv1.zip"
  timeout = 180
  runtime = "python3.8"
  handler = "index.lambda_handler"
  publish = true
  depends_on = [
    aws_iam_role_policy_attachment.attach
  ]
}




resource "aws_cloudwatch_event_rule" "launch_trigger" {
  name = "launch-trigger-rule"
  event_pattern = <<EOF
  {
    "source": [
      "aws.autoscaling"
    ],
    "detail-type": [
      "EC2 Instance-launch Lifecycle Action"
    ]
  }
  EOF
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.launch_trigger.name
  arn = "${aws_lambda_function.lambda_function.arn}"

  depends_on = [
    aws_lambda_function.lambda_function
  ]
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.launch_trigger.arn

}

resource "aws_cloudwatch_log_group" "loggroup_lambda" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 0
}

resource "aws_autoscaling_lifecycle_hook" "asg_lambda_hook" {
  name = "test-hook-tf"
  autoscaling_group_name = var.asg.name
  default_result = "ABANDON"
  heartbeat_timeout = 1800
  lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

}
