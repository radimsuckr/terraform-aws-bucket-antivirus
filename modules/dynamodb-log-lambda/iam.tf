data "aws_iam_policy_document" "processor" {
  statement {
    sid    = "AllowWriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.lambda.arn}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:PutItem",
    ]
    resources = [aws_dynamodb_table.log.arn]
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    sid     = "AllowLambdaSTSAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "processor_policy" {
  name   = local.names["iam_policy_lambda"]
  path   = "/"
  policy = data.aws_iam_policy_document.processor.json
}

resource "aws_iam_role" "processor_role" {
  name               = local.names["iam_role_lambda"]
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "processor_policy" {
  policy_arn = aws_iam_policy.processor_policy.arn
  role       = aws_iam_role.processor_role.name
}
