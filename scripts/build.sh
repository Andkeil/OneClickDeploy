#!/bin/bash
sudo apt-get update

#install kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list
sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

#install kops
sudo wget https://github.com/kubernetes/kops/releases/download/1.10.0/kops-linux-amd64
sudo chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

#awscli
sudo apt-get install -y awscli

#docker
sudo apt-get install docker.io

#set s3 bucket
aws s3 mb s3://cluster1.cloudhippo.io
export KOPS_STATE_STORE=s3://cluster1.cloudhippo.io

#create cluster
kops create cluster --cloud=aws --zones=us-west-1b --dns-zone=cloudhippo.io --name=cluster1.cloudhippo.io --yes

until kops validate cluster | tail -1 | grep ready
do
    echo "Waiting for cluster to be ready..."
done

# run deploy
echo "Deploying..."
kubectl create -f deploy.yml

# exposing app
echo "Exposing app..."
kubectl expose deploy hello-deploy --name=hello-svc --target-port=8080 --type=NodePort

SECURITY="$(aws ec2 describe-security-groups --filters Name=group-name,Values=nodes.cluster1.cloudhippo.io --query 'Se
