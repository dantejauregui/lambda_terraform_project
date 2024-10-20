data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "rds_manager_inline_policy" {
    statement {
      effect = "Allow"
      actions = [
            "logs:CreateLogGroup"
            ]
        resources = ["arn:aws:logs:${var.region}:679390074177:*"]
    }
    statement {
      effect = "Allow"
      actions = [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        resources = ["arn:aws:logs:${var.region}:679390074177:log-group:/aws/lambda/${local.function_name}:*"]
    }
    statement {
      effect = "Allow"
      actions = [
                "rds:StopDBInstance",
                "rds:StartDBInstance",
                "rds:DescribeDBInstances"
            ]
        resources = ["arn:aws:rds:${var.region}:679390074177:db:*"]
    }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_function.py"
  output_path = "${path.module}/src/lambda_function_payload.zip"
}

data "aws_iam_policy_document" "schedule_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "rds_manager_scheduler" {
    statement {
      effect = "Allow"
      actions = [
            "lambda:InvokeFunction"
            ]
        resources = ["arn:aws:lambda:${var.region}:679390074177:function:rds_manager-${var.region}"]
    }
}