#!/bin/bash
mkdir test-directory
cd /test-directory
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value[] | [0], Placement.AvailabilityZone,InstanceType,State.Name]' | sudo tee outputs
aws ssm get-parameters --region us-east-1 --names DBName --query Parameters[0].Value | sudo tee outputs-2