#!/bin/sh

echo Start deploy container...

SERVICE=$1
AWS_ACCOUNT_ID=$2
AWS_DEFAULT_REGION=$3
IMAGE_REPO_NAME=$4
IMAGE_TAG=$5
CLUSTER_NAME=$6
ECR_STACK_NAME=$7
echo SERVICE=$SERVICE AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION IMAGE_REPO_NAME=$IMAGE_REPO_NAME IMAGE_TAG=$IMAGE_TAG CLUSTER_NAME=$CLUSTER_NAME ECR_STACK_NAME=$ECR_STACK_NAME

echo Checking if stack $ECR_STACK_NAME exists yet
if aws cloudformation describe-stacks --stack-name $ECR_STACK_NAME; then
    echo "Stack with id $ECR_STACK_NAME found. Continue..."
else
    echo "Stack with id $ECR_STACK_NAME does not exist. exit 0" 
    exit 0
fi

kubectl version --short --client
echo Logging into Amazon ECR...
aws sts get-caller-identity
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name $CLUSTER_NAME

HAS_SERVICE=$(kubectl get svc | grep $SERVICE);
echo HAS_SERVICE=$HAS_SERVICE

if [ -z "$HAS_SERVICE" ]; then 
    echo "Service not exist, deploy one."
    kubectl create deployment $SERVICE --image=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
    kubectl expose deployment $SERVICE --type=LoadBalancer --port 80 --target-port 80
else 
    echo "Service exists, continue to deploy container"
    kubectl set image deployment/$SERVICE $IMAGE_REPO_NAME=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
fi

kubectl get svc