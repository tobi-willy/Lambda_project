import json
import boto3
import os

dynamodb =  boto3.resource('dynamodb')
table = dynamodb.Table(os.environ.get('todos'))

def handler(event, context):
    print("Fetching all todos")
    try:
        response = table.scan()
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin':'*',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Methods':'POST,OPTIONS,GET'   
                        },
            'body': json.dumps(response['Items'])  
        }
    except Exception as e: 
        print (e)
        return {
            'statusCode': 500,
            'body': json.dumps({'message':'Error fetching todos'})  
        }   