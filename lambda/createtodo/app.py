import json
import uuid
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME')
table =  dynamodb.Table(table_name)

def handler(event, context):
    print("Received event:", event)
    try: 
        body = json.loads(event ['body'])
        
        todo = {
            'id': str(uuid.uuid4()),
            'title': body['title'],
            'description': body.get('description', ''),
            'status': 'pending'
        }
        table.put_item(Item=todo)

        return {
            'statusCode': 201,
            'headers': {
            'Access-Control-Allow-Origin':'*',
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Methods': 'POST,OPTIONS,GET'
            },
            'body': json.dumps({'message': 'Todo created', 'todo': todo})
        }
        
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error creating todo'})
        }