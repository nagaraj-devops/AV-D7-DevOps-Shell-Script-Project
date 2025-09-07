#!/bin/bash
# Cronjob to get report of AWS resource usage
# Date : 2025-09-07
# Author: Nagaraj Sajjan

# ===============================
# Configuration
# ===============================
REPORT_FILE="/var/log/aws_resource_report_$(date +%F).log"
PROFILE="default"   # Change if using a named AWS CLI profile
REGION="ap-south-1" # Change region if required

# ===============================
# Start Report
# ===============================
echo "#############################################" | tee -a $REPORT_FILE
echo " AWS Resource Usage Report - $(date)" | tee -a $REPORT_FILE
echo "#############################################" | tee -a $REPORT_FILE
echo "" | tee -a $REPORT_FILE

# ========= S3 Buckets ==========
echo "######## AWS S3 Buckets ########" | tee -a $REPORT_FILE
aws s3 ls --profile $PROFILE | tee -a $REPORT_FILE
echo "" | tee -a $REPORT_FILE

# ========= EC2 Instances =========
echo "######## AWS EC2 Instances ########" | tee -a $REPORT_FILE
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].{ID:InstanceId,Name:Tags[?Key==`Name`].Value|[0],Type:InstanceType,State:State.Name,AZ:Placement.AvailabilityZone,LaunchTime:LaunchTime,AMI:ImageId,PublicIP:PublicIpAddress}' \
  --output table --profile $PROFILE --region $REGION | tee -a $REPORT_FILE
echo "" | tee -a $REPORT_FILE

# ========= Lambda Functions =========
echo "######## AWS Lambda Functions ########" | tee -a $REPORT_FILE
aws lambda list-functions \
  --query 'Functions[].{Name:FunctionName,Runtime:Runtime,LastModified:LastModified,MemorySize:MemorySize,Timeout:Timeout}' \
  --output table --profile $PROFILE --region $REGION | tee -a $REPORT_FILE
echo "" | tee -a $REPORT_FILE

# ========= IAM Users =========
echo "######## AWS IAM Users ########" | tee -a $REPORT_FILE
aws iam list-users \
  --query 'Users[].{UserName:UserName,CreateDate:CreateDate,ARN:Arn}' \
  --output table --profile $PROFILE | tee -a $REPORT_FILE
echo "" | tee -a $REPORT_FILE

# ========= RDS Instances =========
echo "######## AWS RDS Instances ########" | tee -a $REPORT_FILE
aws rds describe-db-instances \
  --query 'DBInstances[].{ID:DBInstanceIdentifier,Engine:Engine,Status:DBInstanceStatus,Class:DBInstanceClass,Endpoint:Endpoint.Address,Username:MasterUsername}' \
  --output table --profile $PROFILE --region $REGION | tee -a $REPORT_FILE
echo "" | tee -a $REPORT_FILE

# ========= VPCs =========
echo "######## AWS VPCs ########" | tee -a $REPORT_FILE
aws ec2 describe-vpcs \
  --query 'Vpcs[].{VPCID:VpcId,CIDR:CidrBlock,IsDefault:IsDefault}' \
  --output table --profile $PROFILE --region $REGION | tee -a $REPORT_FILE
echo "" | tee -a $REPORT_FILE

# ========= Summary =========
echo "#############################################" | tee -a $REPORT_FILE
echo " Report saved at: $REPORT_FILE" | tee -a $REPORT_FILE
echo "#############################################" | tee -a $REPORT_FILE
