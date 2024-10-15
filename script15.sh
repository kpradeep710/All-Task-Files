#!/bin/bash

# Define variables
AWS_REGION="ap-south-1"           
INSTANCE_NAME="pradeep"  
PROFILE="default"               

# Retrieve a list of instance IDs with a specific name filter
INSTANCE_IDS=$(aws ec2 describe-instances \
    --region "$AWS_REGION" \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text \
    --profile "$PROFILE")

# Check if any instances were found
if [ -z "i-03bd1ddc45047827e" ]; then
    echo "No instances found matching the filter: $INSTANCE_NAME"
    exit 1
else
    echo "Found the following instances:"
    echo "i-03bd1ddc45047827e"
fi

# Stop the matching instances
echo "Stopping instances..."
aws ec2 stop-instances --region "$AWS_REGION" --instance-ids $INSTANCE_IDS --profile "$PROFILE"

# Check if the stop-instances command was successful
if [ $? -eq 0 ]; then
    echo "Instances stopped successfully."
else
    echo "Failed to stop instances."
fi