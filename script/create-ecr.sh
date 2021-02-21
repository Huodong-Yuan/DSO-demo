#!/bin/sh

set -e
die () {
    echo >&2 "$@"
    exit 1
}

### Expect argument to be provided with the stack name
[ "$#" -eq 1 ] || die "Usage: $0 [stack_name]"
STACK_NAME=$1

### Check if stack exists yet
echo Checking if stack $STACK_NAME exists yet
if aws cloudformation describe-stacks --stack-name $STACK_NAME; then
    echo "Stack with id $STACK_NAME found. Continue."
    exit 0
else
    echo "Stack with id $STACK_NAME does not exist. Create one." 
    aws cloudformation create-stack --stack-name $STACK_NAME --template-url https://cf-templates-i6aohmzkcsjf-ap-east-1.s3.ap-east-1.amazonaws.com/templates/ecr-repository.yaml
fi