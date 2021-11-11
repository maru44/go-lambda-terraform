provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

data "aws_region" "current" {}

# define lambda function
resource "aws_lambda_function" "event" {
  function_name    = "event"
  filename         = "main.zip"
  handler          = "event"
  source_code_hash = sha256(filebase64("main.zip"))
  role             = aws_iam_role.event.arn
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 1
}

# IAM (lambda)
resource "aws_iam_role" "event" {
  name               = "event"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow"
    }
}
EOF
}

# allow apigateway to invoke lambda 'event' function
resource "aws_lambda_permission" "event" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.event.arn
  principal     = "apigateway.amazonaws.com"
}

# Gateway to map a Lambda function to an HTTP endpoint.
resource "aws_api_gateway_resource" "event" {
  rest_api_id = aws_api_gateway_rest_api.event.id
  parent_id   = aws_api_gateway_rest_api.event.root_resource_id
  path_part   = "event"
}

resource "aws_api_gateway_rest_api" "event" {
  name = "event"
}

resource "aws_api_gateway_method" "event" {
  rest_api_id   = aws_api_gateway_rest_api.event.id
  resource_id   = aws_api_gateway_resource.event.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "event" {
  rest_api_id             = aws_api_gateway_rest_api.event.id
  resource_id             = aws_api_gateway_resource.event.id
  http_method             = aws_api_gateway_method.event.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.event.arn}/invocations"
}

resource "aws_api_gateway_deployment" "event_v1" {
  depends_on = [
    aws_api_gateway_integration.event
  ]
  rest_api_id = aws_api_gateway_rest_api.event.id
  stage_name  = "v1"
}

output "url" {
  value = "${aws_api_gateway_deployment.event_v1.invoke_url}${aws_api_gateway_resource.event.path}"
}
