#!/bin/bash

tag="terraform-kubernetes"

# Check for --rebuild argument
rebuild=false
args=()
for arg in "$@"; do
    if [ "$arg" == "--rebuild" ]; then
        rebuild=true
    else
        args+=("$arg")
    fi
done

if !(docker image ls | grep -q $tag); then
    docker build --no-cache -t $tag -f terraform.Dockerfile .
fi

docker run -it --rm --network host -v $(pwd)/terraform:/workdir:rw $tag "$@"