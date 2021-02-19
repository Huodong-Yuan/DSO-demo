# configure awscli
aws configure

# create EKS Cluster and Nodegroup in region ap-east-1 (only supported in certain regions)
eksctl create cluster \
--name yhdEks \
--region ap-east-1 \
--zones ap-east-1a,ap-east-1b \
--nodegroup-name workers \
--node-type t3.micro \
--nodes 2 \
--nodes-min 1 \
--nodes-max 3 \
--node-ami auto

# create repository
aws ecr create-repository --repository-name dso-repo

# build / tag image
docker build -t <aws_account_id>.dkr.ecr.ap-east-1.amazonaws.com/<image>:<tag> .
docker build -t 481978552537.dkr.ecr.ap-east-1.amazonaws.com/demo:1:0 .

# upload image to registry
aws ecr get-login --region ap-east-1 --no-include-email
docker push 481978552537.dkr.ecr.ap-east-1.amazonaws.com/demo:1.0

# Create service deployment for container
kubectl create deployment dso-demo \
--image=937127767762.dkr.ecr.ap-east-1.amazonaws.com/dso-repo:1.0

# expose service
kubectl expose deployment dso-demo \
--type=LoadBalancer --port 80 --target-port 80


# scale pods
kubectl scale deployment demo-app --replicas=3

# hit pods
kubectl get service
while true; do sleep 0.1; curl http://aec84399f1b5f11ea833d0a247407c60-1248700768.ap-east-1.elb.amazonaws.com/; echo -e;done

# get nodegroup info
eksctl get nodegroup --cluster=yhdEks

# scale nodes
eksctl scale nodegroup --cluster=yhdEks --nodes=3 --name=ng-e56250ca
kubectl scale deployment dso-demo --replicas=3
eksctl scale nodegroup --cluster=yhdEks --nodes=5, --name=ng-e56250ca

# update deployment
docker build -t 481978552537.dkr.ecr.ap-east-1.amazonaws.com/demo:2.0 .
docker push 481978552537.dkr.ecr.ap-east-1.amazonaws.com/demo:2.0
kubectl set image deployment/dso-demo \
dso-repo=937127767762.dkr.ecr.ap-east-1.amazonaws.com/dso-repo:latest

# remove load balancer
kubectl delete service demo-app

# Delete EKS cluster
eksctl delete cluster --name yhdEks

# Delete service deployment
kubectl delete service dso-demo

# delete images
aws ecr list-images --repository-name demo

# delete 2.0 image
aws ecr batch-delete-image --repository-name demo --image-ids imageDigest=sha256:f00e429b3dd2a6f5b158ca035e8d16afc779b1db0b813a2c9b9f47060d32b1a3

# delete entire repository --force is to delete images in repo if present
aws ecr delete-repository --repository-name demo --force
