#!/bin/sh

AWS_ACCOUNT_ID=$1
AWS_DEFAULT_REGION=$2
IMAGE_REPO_NAME=$3
IMAGE_TAG=$4
ECR_STACK_NAME=$5
echo AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION IMAGE_REPO_NAME=$IMAGE_REPO_NAME IMAGE_TAG=$IMAGE_TAG ECR_STACK_NAME=$ECR_STACK_NAME

echo Checking if stack $ECR_STACK_NAME exists yet
if aws cloudformation describe-stacks --stack-name $ECR_STACK_NAME; then
    echo "Stack with id $ECR_STACK_NAME found. Continue..."
else
    echo "Stack with id $ECR_STACK_NAME does not exist. exit 0" 
    exit 0
fi

docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/demo:$IMAGE_TAG .
docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG

aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
sleep 1m