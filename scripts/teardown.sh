#!/bin/bash

#tear down cluster
if [ -z $1 ];then
    echo 'Put in a cluster name'
else
    kops delete cluster --name=$1 --yes
fi

#remove bucket
aws s3 rb s3://cluster1.cloudhippo.io
