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
    "Version": "2021-11-10",
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

resource "aws_api_gateway_get" "event" {
  rest_api_id   = aws_api_gateway_rest_api.event.id
  resource_id   = aws_api_gateway_resource.event.id
  http_method   = "GET"
  authorization = "NONE"
}