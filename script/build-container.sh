#!/bin/sh

### Expect argument to be provided with the stack name
[ "$#" -eq 6 ] || die "Usage: $0 [aws account id, aws default region, ecr repository name, image tage]"
AWS_ACCOUNT_ID=$1
AWS_DEFAULT_REGION=$2
IMAGE_REPO_NAME=$3
IMAGE_TAG=$4
ECR_STACK_NAME=$5

echo Checking if stack $ECR_STACK_NAME exists yet
if aws cloudformation describe-stacks --stack-name $ECR_STACK_NAME; then
    echo "Stack with id $ECR_STACK_NAME found. Continue..."
else
    echo "Stack with id $ECR_STACK_NAME does not exist. exit 0" 
    exit 0
fi

docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG

aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
sleep 1m