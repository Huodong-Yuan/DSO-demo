#!/bin/sh

set -e
die () {
    echo >&2 "$@"
    exit 1
}

### Expect argument to be provided with the stack name
[ "$#" -eq 1 ] || die "Usage: $0 [stack_name]"
STACK_NAME=$1
echo $STACK_NAME

### Check if stack exists yet
echo Checking if stack $STACK_NAME exists yet
if aws cloudformation describe-stacks --stack-name ${STACK_NAME}; then
    echo "Stack with id $STACK_NAME found." 
    exit 0
else
    echo "Stack with id $STACK_NAME does not exist." 
    eksctl create cluster -f ./infrastructure/cluster.yaml
fi