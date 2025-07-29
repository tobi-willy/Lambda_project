# AWS Lambda Todo API – Serverless Application
This is a backend-only serverless TODO API built using AWS Lambda, API Gateway, and DynamoDB, provisioned entirely with Terraform. The project demonstrates real-world DevOps and cloud engineering skills using infrastructure as code and a serverless architecture.
It is RESTful API that allows users to create and retrieve todo tasks using POST and GET endpoints. It's designed to be event-driven, cost-effective, and easily scalable.

I built this to practice deploying a production-grade backend without managing servers, while reinforcing hands-on AWS knowledge (Lambda, API Gateway, DynamoDB, CloudWatch) and applying Terraform for full infrastructure automation.

## Architecture
![Lambda diagram](https://github.com/user-attachments/assets/2c7a1ca0-9784-4ed2-97e4-7101d7eb1aeb)
- API Gateway exposes two endpoints (POST /v1/todos and GET /v1/todos).
- Lambda Function processes and handles requests.
- DynamoDB stores todo records.
- CloudWatch Logs capture execution logs and errors.
- Terraform provisions and manages all AWS resources.

## Security
- IAM roles defined with least privilege principle.
- Lambda functions have permissions only to access DynamoDB and CloudWatch.

## Techstack used 
- AWS Lambda (Python runtime)
- API Gateway (REST API)
- DynamoDB (NoSQL database)
- CloudWatch (logging/monitoring)
- Terraform (IaC)

## Project structure
```
├── lambda/
│   ├── app.py         # Main handler
│   ├── createtodo.py  # POST logic
│   └── gettodo.py     # GET logic
├── terraform/
│   ├── lambda.tf
│   ├── provider.tf
│   ├── variables.tf
├── .gitignore
└── README.md
```
