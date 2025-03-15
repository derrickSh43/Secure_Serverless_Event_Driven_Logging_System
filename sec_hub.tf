resource "aws_securityhub_account" "security_hub" {}

resource "aws_cloudwatch_event_rule" "security_hub_high_risk" {
  name        = "security-hub-high-risk-alerts"
  description = "Trigger alerts for high-risk Security Hub findings"

  event_pattern = jsonencode({
    "source": ["aws.securityhub"],
    "detail-type": ["Security Hub Findings - Custom Action"],
    "detail": {
      "severity": {
        "Label": ["CRITICAL", "HIGH"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns_security_alert_sh" {
  rule      = aws_cloudwatch_event_rule.security_hub_high_risk.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.security_alerts.arn
}
