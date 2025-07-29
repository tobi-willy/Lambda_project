resource "aws_dynamodb_table" "todos" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_function" "create_todo" {
  function_name    = "createTodoFuntion"
  runtime          = "python3.11"
  handler          = "app.handler"
  filename         = "${path.module}/../lambda/createtodo/createTodo.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/createtodo/createTodo.zip")
  role             = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todos.name
    }
  }
}

resource "aws_api_gateway_rest_api" "todo_api" {
  name        = "TodoAPI"
  description = "API Gateway for the Todo Lambda Function"
}

resource "aws_api_gateway_resource" "todos_resource" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
  path_part   = "todos"
}

resource "aws_api_gateway_method" "post_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todos_resource.id
  http_method             = aws_api_gateway_method.post_todo.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.create_todo.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "todo_deployment" {
  depends_on  = [
    aws_api_gateway_integration.lambda_post_integration,
    aws_api_gateway_integration.get_todos
  ]
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  triggers = {
    redeployment = timestamp()
  }
  description = "Deployed on ${timestamp()}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "todo_stage" {
  stage_name    = "v1"
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  deployment_id = aws_api_gateway_deployment.todo_deployment.id
}

resource "aws_lambda_function" "get_todos" {
  function_name    = "get_todos"
  handler          = "get.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn
  filename         = "${path.module}/../lambda/gettodo/getTodos.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/gettodo/getTodos.zip")

  environment {
    variables = {
      todos = aws_dynamodb_table.todos.name
    }
  }
}


resource "aws_api_gateway_method" "get_todos" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_todos" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todos_resource.id
  http_method             = aws_api_gateway_method.get_todos.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_todos.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_get_todos" {
  statement_id  = "AllowGetFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_todos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}
