#!/bin/sh

set -e
die () {
    echo >&2 "$@"
    exit 1
}

### Expect argument to be provided with the ECR repository name
[ "$#" -eq 1 ] || die "Usage: $0 [ecr_repo]"
ECR_REPO=$1

isHigh=$(aws ecr describe-image-scan-findings --repository-name $ECR_REPO --image-id imageTag=1.0 --region ap-east-1 | grep "\"severity\": \"HIGH\"");

if [ -z "$isHigh" ]; then 
    echo "Not high"
else 
    echo "$isHigh"
    exit 1
fi