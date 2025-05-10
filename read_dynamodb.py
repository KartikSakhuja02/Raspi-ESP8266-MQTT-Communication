import boto3
import time

# Initialize the DynamoDB resource
dynamodb = boto3.resource('dynamodb', region_name="ap-south-1")
table = dynamodb.Table('SensorData')  # Replace with your table name

# Function to fetch and display data
def scan_dynamodb():
    try:
        response = table.scan()  # Get all items
        items = response.get('Items', [])
        
        if items:
            print(f"Fetched {len(items)} record(s):")
            for item in items:
                print(item)  # Print each record (you can format it as needed)
        else:
            print("No data available.")
        
    except Exception as e:
        print(f"Error while scanning DynamoDB: {e}")

# Continuously scan the table every 1 second
while True:
    scan_dynamodb()
    time.sleep(1)  # Wait for 1 second before scanning again
