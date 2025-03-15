resource "aws_cloudwatch_event_rule" "security_log_alert" {
  name        = "security-log-alert"
  description = "Trigger alerts for security-related events in S3 logs"

  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "detail": {
      "bucket": {
        "name": ["resumerx-logs-bucket"]  
      },
      "object": {
        "key": [{ "prefix": "logs/security/" }]  
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns_security_alert_eb" {
  rule      = aws_cloudwatch_event_rule.security_log_alert.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.security_alerts.arn
}
