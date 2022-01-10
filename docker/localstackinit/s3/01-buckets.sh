#!/bin/bash

printf ">>> Init localstack s3\n"

buckets=(
    "my-s3-bucket"
    "another-bucket"
)
#set -x
for b in ${buckets[@]}; do
    awslocal s3 mb s3://$b || echo "Already created bucket $b"
done
#set +x

printf ">>> Done initializing localstack s3"
