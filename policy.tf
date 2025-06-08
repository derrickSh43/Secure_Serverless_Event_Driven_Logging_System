resource "aws_cloudwatch_event_target" "sns_security_alert" {
  rule      = aws_cloudwatch_event_rule.security_log_alert.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.security_alerts.arn
}

resource "aws_iam_policy" "eventbridge_s3_trigger" {
  name        = "eventbridge_s3_trigger"
  description = "Allow only S3 logs bucket to trigger EventBridge"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"

      Action = "events:PutEvents"
      Resource = aws_cloudwatch_event_rule.security_log_alert.arn
      Condition = {
        StringEquals = {
          "aws:SourceArn": "arn:aws:s3:::resumerx-logs-bucket"
        }
      }
    }]
  })
}
# derrickSh43\Secure_Serverless_Event_Driven_Logging_System
resource "aws_iam_policy" "eventbridge_processing" {
  name        = "eventbridge_processing"
  description = "Allow EventBridge to process security events and send to SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["events:PutEvents"]
      Resource = "*"
    },
    {
      Effect = "Allow"
      Action = ["sns:Publish"]
      Resource = aws_sns_topic.security_alerts.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_eventbridge_processing" {
  role       = aws_iam_role.eventbridge_execution_role.name
  policy_arn = aws_iam_policy.eventbridge_processing.arn
}

resource "aws_iam_role_policy_attachment" "attach_eventbridge_s3_trigger" {
  role       = aws_iam_role.eventbridge_execution_role.name
  policy_arn = aws_iam_policy.eventbridge_s3_trigger.arn
}


resource "aws_iam_policy" "eventbridge_security_sources" {
  name        = "eventbridge_security_sources"
  description = "Allow only Security Hub & CloudWatch Logs to trigger EventBridge"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"

      Action = "events:PutEvents"
      Resource = aws_cloudwatch_event_rule.security_hub_high_risk.arn
      Condition = {
        StringEquals = {
          "aws:SourceArn": [
            "arn:aws:securityhub:us-east-1:123456789012:hub/default",
            "arn:aws:logs:us-east-1:123456789012:log-group:/aws/lambda/security-logs:*"
          ]
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_eventbridge_security_sources" {
  role       = aws_iam_role.eventbridge_execution_role.name
  policy_arn = aws_iam_policy.eventbridge_security_sources.arn
}


resource "aws_iam_role" "eventbridge_execution_role" {
  name = "eventbridge_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "api_gateway_logging_policy" {
  name        = "api_gateway_logging_policy"
  description = "Allows API Gateway to write logs to CloudWatch"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents"
      ]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_api_gateway_logging_policy" {
  role       = aws_iam_role.api_gateway_logging.name
  policy_arn = aws_iam_policy.api_gateway_logging_policy.arn
}

resource "aws_iam_policy" "lambda_s3_access" {
  name        = "lambda_s3_access"
  description = "Allow Lambda to write logs to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        "${aws_s3_bucket.logs_bucket.arn}",         
        "${aws_s3_bucket.logs_bucket.arn}/logs/*"   
      ]
    }]
  })
}


resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "${aws_iam_role.lambda_exec_role.arn}"
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.logs_bucket.arn}",
          "${aws_s3_bucket.logs_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_sns_publish" {
  name        = "lambda_sns_publish"
  description = "Allows Lambda to publish messages to SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = "arn:aws:sns:us-east-1:182399711649:security-alerts"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_sns_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}
