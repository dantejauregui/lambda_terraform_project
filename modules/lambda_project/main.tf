locals {
  function_name = join("", [var.resource_name, var.region])
  schedule_name = join("", [var.resource_name, var.region, "-scheduler"])
}

resource "aws_iam_role" "rdsmanager-iam" {
  name               = local.function_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
    inline_policy {
    name   = local.function_name
    policy = data.aws_iam_policy_document.rds_manager_inline_policy.json
    }
}

resource "aws_cloudwatch_log_group" "rds_manager" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_function" "rds_manager" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = local.function_name
  role          = aws_iam_role.rdsmanager-iam.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.12"
  timeout = 10
}

#Eventbridge schedule role
resource "aws_iam_role" "rdsmanager-schedule" {
  name               = local.schedule_name
  assume_role_policy = data.aws_iam_policy_document.schedule_assume_role.json
    inline_policy {
    name   = local.schedule_name
    policy = data.aws_iam_policy_document.rds_manager_scheduler.json
    }
}

#Eventbridge scheduler
resource "aws_scheduler_schedule" "rds_manager" {
  name = local.schedule_name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(1 21 * * ? *)"

  target {
    arn      = resource.aws_lambda_function.rds_manager.arn
    role_arn = aws_iam_role.rdsmanager-schedule.arn
    input = "{\"switch\": 0}"
  }
}