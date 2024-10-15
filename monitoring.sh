#!/bin/bash

# Define Variables
INSTANCE_ID="i-0d4293d225af524e4"       # Replace with your EC2 instance ID
ALARM_NAME="NetworkLoad"
SNS_TOPIC_NAME="pradeep-cli-topic"
SNS_EMAIL="pradeepkoduri1999@gmail.com"  # Replace with your email address
SQS_QUEUE_NAME="pradeep-cli-queue"
AWS_REGION="ap-south-1"              # Set your AWS region

# Step 45: Create a CloudWatch alarm for the specified instance
# The alarm will monitor the NetworkIn metric and trigger if it exceeds 10000000 bytes in 5 minutes
aws cloudwatch put-metric-alarm --alarm-name $ALARM_NAME \
  --metric-name NetworkIn \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 10000000 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value=$INSTANCE_ID \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:$AWS_REGION:$AWS_ACCOUNT_ID:$SNS_TOPIC_NAME \
  --region $AWS_REGION
echo "CloudWatch Alarm $ALARM_NAME created for instance $INSTANCE_ID."

# Step 46: Create an SNS topic and subscribe an email address
SNS_TOPIC_ARN=$(aws sns create-topic --name $SNS_TOPIC_NAME --region $AWS_REGION --output text)
aws sns subscribe --topic-arn $SNS_TOPIC_ARN --protocol email --notification-endpoint $SNS_EMAIL --region $AWS_REGION
echo "SNS topic $SNS_TOPIC_NAME created and email $SNS_EMAIL subscribed."

# Step 47: Create an SQS queue and subscribe it to the SNS topic
SQS_QUEUE_URL=$(aws sqs create-queue --queue-name $SQS_QUEUE_NAME --region $AWS_REGION --output text)
SQS_QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url $SQS_QUEUE_URL --attribute-name QueueArn --query 'Attributes.QueueArn' --output text)
aws sns subscribe --topic-arn $SNS_TOPIC_ARN --protocol sqs --notification-endpoint $SQS_QUEUE_ARN --region $AWS_REGION
echo "SQS queue $SQS_QUEUE_NAME created and subscribed to SNS topic $SNS_TOPIC_NAME."

# Step 48: Verify message flow from SNS to SQS
# Publish a test message to SNS
TEST_MESSAGE="Test alert for $SNS_EMAIL"
aws sns publish --topic-arn $SNS_TOPIC_ARN --message "$TEST_MESSAGE" --region $AWS_REGION
echo "Test message published to SNS topic $SNS_TOPIC_NAME."

# Wait for message to be delivered to SQS
sleep 5

# Receive the message from SQS queue
RECEIVED_MESSAGE=$(aws sqs receive-message --queue-url $SQS_QUEUE_URL --region $AWS_REGION --query 'Messages[0].Body' --output text)

if [[ $RECEIVED_MESSAGE == "$TEST_MESSAGE" ]]; then
  echo "Message successfully received in SQS queue: $RECEIVED_MESSAGE"
else
  echo "No message received in SQS queue, or message does not match."
fi
