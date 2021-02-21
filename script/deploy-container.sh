#!/bin/sh

set -e
die () {
    echo >&2 "$@"
    exit 1
}

### Expect argument to be provided with the stack name
[ "$#" -eq 6 ] || die "Usage: $0 [service, aws account id, aws default region, ecr repository name, image tage, cluster name]"
SERVICE=$1
AWS_ACCOUNT_ID=$2
AWS_DEFAULT_REGION=$3
IMAGE_REPO_NAME=$4
IMAGE_TAG=$5
CLUSTER_NAME=$6

aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name $CLUSTER_NAME

HAS_SERVICE=$(kubectl get svc | grep $SERVICE);

if [ -z "$HAS_SERVICE" ]; then 
    echo "Service not exist, deploy one."
    kubectl create deployment $SERVICE --image=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
    kubectl expose deployment $SERVICE --type=LoadBalancer --port 80 --target-port 80
else 
    echo "Service exists, continue to deploy container"
fi

kubectl set image deployment/$SERVICE dso-repo=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG