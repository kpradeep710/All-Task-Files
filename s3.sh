#!/bin/bash

# Create Bucket-1 and upload files (t1, t2, t3)
aws s3 mb s3://nani-bucket-1 --region ap-south-1
echo "Uploading files to nani-bucket-1"
aws s3 cp /C:/Users/nagub/Downloads/s3.txt s3://nani-bucket-1/ --recursive --region ap-south-1

# Create Bucket-2 and upload files (t4, t5, t6)
aws s3 mb s3://nani-bucket-2 --region ap-south-1
echo "Uploading files to nani-bucket-2"
aws s3 cp /C:/Users/nagub/Downloads/s3-1.txt s3://nani-bucket-2/ --recursive --region ap-south-1

# Copy files from bucket-1 to bucket-2
echo "Copying files from nani-bucket-1 to nani-bucket-2"
aws s3 sync s3://nani-bucket-1 s3://nani-bucket-2

# Create Bucket-3 and upload files (t7, t8, t9)
aws s3 mb s3://nani-bucket-3 --region us-east-1
echo "Uploading files to nani-bucket-3"
aws s3 cp /C:/Users/nagub/Downloads/s3-2.txt s3://nani-bucket-3/ --recursive --region us-east-1


# Copy files from bucket-1 to bucket-3
echo "Copying files from bucket-1 to bucket-3"
aws s3 sync s3://nani-bucket-1 s3://nani-bucket-3

# Make bucket-1 as static web host and add proper policy and change bucket ACL's to get webpage - index.html
echo "Configuring bucket-1 as a static website host"
aws s3 website s3://nani-bucket-1/ --index-document todolist.html

#Disable the public access.
aws s3api delete-public-access-block --bucket nani-bucket-1

# Add bucket policy for public  read access
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::nani-bucket-1/*"
      }
    ]
}
  

echo "$POLICY" > bucket-policy.json
aws s3api put-bucket-policy --bucket nani-bucket-1 --policy file://bucket-policy.json

# Set bucket ACL to public-read
aws s3api put-bucket-acl --bucket nani-bucket-1 --acl public-read

# Create EC2 instance in private subnet
PRIVATE_INSTANCE_ID=$(aws ec2 run-instances --image-id ami-04a37924ffe27da53 --count 1 --instance-type t2.micro --key-name nani.pem --subnet-id $SUBNET4_ID --query 'Instances[0].InstanceId' --output text)

# Access bucket-2 from the created EC2 instance (this requires IAM role and permissions setup for EC2 instance)
# You need to associate an IAM role with S3 access to your instance
INSTANCE_PROFILE_NAME="private"
ROLE_NAME="bucket-2-role"
POLICY_ARN="arn:aws:iam::aws:policy/AmazonS3FullAccess"

aws iam create-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME
aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://trust-policy.json
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn $POLICY_ARN
aws iam add-role-to-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME --role-name $ROLE_NAME

aws ec2 associate-iam-instance-profile --instance-id $PRIVATE_INSTANCE_ID --iam-instance-profile Name=$INSTANCE_PROFILE_NAME



# Block one IP address on bucket-2

#disable the public access
echo "block the public access"
aws s3api put-public-access-block --bucket nani-bucket-2 --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
{
  "Version": "2012-10-17",
  "Id": "Policy1726224815385",
  "Statement": [
      {
          "Sid": "Stmt1726224812799",
          "Effect": "Deny",
          "Principal": {
              "AWS": "arn:aws:iam::495599737832:user/pradeep"
          },
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::nani-bucket-2/*",
          "Condition": {
              "NotIpAddress": {
                  "aws:SourceIp": "103.186.128.27/32"
              }
          }
      }
  ]
}
echo "$BLOCK-IP-POLICY" > block-ip-policy.json
aws s3api put-bucket-policy --bucket nani-bucket-2 --policy file://block-ip-policy.json

# Allow only one IP address on bucket-3
{
    "Version": "2012-10-17",
    "Id": "Policy1726224815385",
    "Statement": [
        {
            "Sid": "Stmt1726224812799",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::495599737832:user/pradeep"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::nani-bucket-3/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "103.186.128.27/32"
                }
            }
        }
    ]
  }

echo "$ALLOW-IP-POLICY" > allow-ip-policy.json
aws s3api put-bucket-policy --bucket nani-bucket-3 --policy file://allow-ip-policy.json --region us-east-1


echo "Completed all tasks."
