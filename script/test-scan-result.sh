#!/bin/sh

[ "$#" -eq 2 ] || die "Usage: $0 [ecr_repo]"
ECR_REPO=$1
IMAGE_TAG=$2
echo ECR_REPO=$ECR_REPO IMAGE_TAG=$IMAGE_TAG

echo Checking if ECR repository $ECR_REPO exists yet
if aws ecr describe-images --repository-name $ECR_REPO --image-ids imageTag=$IMAGE_TAG; then
    echo "Image tage $IMAGE_TAG in ECR repository $ECR_REPO found. Continue..."
else
    echo "Image tage $IMAGE_TAG in ECR repository $ECR_REPOdoes not exist. exit 0 without scanning." 
    exit 0
fi

CRITICAL=$(aws ecr describe-image-scan-findings --repository-name $ECR_REPO --image-id imageTag=$IMAGE_TAG --region ap-east-1 | grep "\"severity\": \"CRITICAL\"");

if [ -z "$CRITICAL" ]; then 
    echo "Not CRITICAL"
else 
    echo "$CRITICAL"
    exit 1
fi