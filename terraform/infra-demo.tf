# Setup Providers
provider "aws" {
  version = "~> 2.61"
}

variable "default_tags" {
  type = map
  default = {
    Env = "Demo"
    App = "TeknoCerdas"
    FromTerraform = "true"
    Article = "PHP My API"
  }
}

variable "bref_layer_arn" {
  type = string
  default = "arn:aws:lambda:us-east-1:209497400698:layer:php-74:11"
}

resource "aws_iam_role" "lambda_exec" {
  name = "LambdaBasicExec"
  tags = var.default_tags
  description = "Allows Lambda functions to call AWS services on your behalf."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role = aws_iam_role.lambda_exec.id
  # AWS Managed
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "php_myip" {
  function_name = "PHPMyIP"
  handler       = "main.handler"
  role          = aws_iam_role.lambda_exec.arn
  memory_size   = 512
  runtime       = "provided"
  tags          = var.default_tags
  timeout       = 5
  layers        = [var.bref_layer_arn]

  filename = "${path.module}/../build/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../build/function.zip")
}

resource "aws_apigatewayv2_api" "php_myip" {
  name          = "PHPMyIP"
  protocol_type = "HTTP"
  tags          = var.default_tags
}

resource "aws_apigatewayv2_integration" "php_myip" {
  api_id              = aws_apigatewayv2_api.php_myip.id
  integration_uri     = aws_lambda_function.php_myip.arn
  integration_type    = "AWS_PROXY"
  integration_method  = "GET"
  connection_type     = "INTERNET"
  payload_format_version = "2.0"

  # Terraform bug?
  # passthrough_behavior only valid for WEBSOCKET but it detect changes for HTTP
  lifecycle {
    ignore_changes = [passthrough_behavior]
  }
}

resource "aws_apigatewayv2_route" "php_myip" {
  api_id    = aws_apigatewayv2_api.php_myip.id
  route_key = "GET /myip"
  authorization_type = "NONE"
  target    = "integrations/${aws_apigatewayv2_integration.php_myip.id}"
}

resource "aws_apigatewayv2_stage" "php_myip" {
  api_id    = aws_apigatewayv2_api.php_myip.id
  tags      = var.default_tags
  name      = "$default"
  auto_deploy = "true"

  # Terraform bug
  # https://github.com/terraform-providers/terraform-provider-aws/issues/12893
  lifecycle {
    ignore_changes = [deployment_id, default_route_settings]
  }
}

# By default other AWS resource can not call Lambda function
# It needs to be granted manually by giving lambda:InvokeFunction permission
resource "aws_lambda_permission" "php_myip" {
  statement_id  = "AllowApiGatewayToInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.php_myip.function_name
  principal     = "apigateway.amazonaws.com"

  # /*/*/* = Any stage / any method / any path
  source_arn    = "${aws_apigatewayv2_api.php_myip.execution_arn}/*/*/myip"
}

locals {
  api_path = split(" ", aws_apigatewayv2_route.php_myip.route_key)
}

output "api" {
  value = {
    end_point = "GET ${aws_apigatewayv2_api.php_myip.api_endpoint}${local.api_path[1]}"
  }
}