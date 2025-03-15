resource "aws_api_gateway_rest_api" "example" {
  name = "example"
}

resource "aws_api_gateway_resource" "example" {
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
  rest_api_id = aws_api_gateway_rest_api.example.id
}

resource "aws_api_gateway_method" "example" {
  authorization = "AWS_IAM"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
}

resource "aws_api_gateway_integration" "example" {
  http_method             = aws_api_gateway_method.example.http_method
  resource_id             = aws_api_gateway_resource.example.id
  rest_api_id             = aws_api_gateway_rest_api.example.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.process_logs_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  depends_on = [
    aws_api_gateway_method.example,
    aws_api_gateway_integration.example  # Add this to ensure the deployment waits for the integration
  ]

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example))
  }

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "dev"
}

resource "aws_api_gateway_account" "api_logging" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_logging.arn
  depends_on = [aws_iam_role.api_gateway_logging] 

}

resource "aws_iam_role_policy" "api_gateway_logging_policy" {
  role = aws_iam_role.api_gateway_logging.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "api_gateway_logging" {
  name               = "api_gateway_logging_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  lifecycle {
    prevent_destroy = false  
  }
}
