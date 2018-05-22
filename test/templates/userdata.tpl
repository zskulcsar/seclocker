#!/bin/bash -xe
# Get the CloudWatch Logs agent
# ATM the installer fails on a standard AMZ AMI soneed to do some hacks (installing GCC ...)
yum install gcc -y
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
# Install the CloudWatch Logs agent
python awslogs-agent-setup.py -n -r ${aws_region} -c ${ssh_access_config_location} || error_exit 'Failed to run CloudWatch Logs agent setup'