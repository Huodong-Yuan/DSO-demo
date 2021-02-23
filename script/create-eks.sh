#!/bin/sh

STACK_NAME=$1
echo STACK_NAME=$STACK_NAME

eksctl version

### Check if stack exists yet
echo Checking if stack $STACK_NAME exists yet
if aws cloudformation describe-stacks --stack-name $STACK_NAME; then
    echo "Stack with id $STACK_NAME found. Continue."
    exit 0
else
    echo "Stack with id $STACK_NAME does not exist. Create one." 
    eksctl create cluster -f ./infrastructure/cluster.yaml
fi