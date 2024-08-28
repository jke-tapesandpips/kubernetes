#!/bin/bash
tag="ansible-kubernetes"

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

# Rebuild image if --rebuild is present or if the image doesn't exist
if $rebuild || !(docker image ls | grep -q $tag); then
    docker build --no-cache -t $tag -f ansible.Dockerfile .

    if [ "$(uname)" == "Darwin" ]; then
        docker run -it --rm --network host -v $(pwd):/workdir:rw -v /run/host-services/ssh-auth.sock:/ssh-agent -e SSH_AUTH_SOCK="/ssh-agent" -v ~/.aws:/root/.aws:ro -v ~/.ssh:/tmp/.ssh:ro -e ANSIBLE_REMOTE_USER="${user}" $tag
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        docker run -it --rm --network host -v $(pwd):/workdir:rw -v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK} -e SSH_AUTH_SOCK=${SSH_AUTH_SOCK} -v ~/.aws:/root/.aws:ro -v ~/.ssh:/tmp/.ssh:ro -e ANSIBLE_REMOTE_USER="${user}" $tag
    fi
fi

sudo chmod -R 777 ansible/roles/

user=$(git config user.email) #Get git email
user="${user%@*}" #Remove Domain
user="${user,,}"  #To Lowercase

if [ "$(uname)" == "Darwin" ]; then
    docker run -it --rm --network host -v $(pwd)/ansible:/workdir/ansible:rw -v /run/host-services/ssh-auth.sock:/ssh-agent -e SSH_AUTH_SOCK="/ssh-agent" -v ~/.aws:/root/.aws:ro -v ~/.ssh:/tmp/.ssh:ro -e ANSIBLE_REMOTE_USER="${user}" $tag "${args[@]}"    
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    docker run -it --rm --network host -v $(pwd)/ansible:/workdir/ansible:rw -v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK} -e SSH_AUTH_SOCK=${SSH_AUTH_SOCK} -v ~/.aws:/root/.aws:ro -v ~/.ssh:/tmp/.ssh:ro -e ANSIBLE_REMOTE_USER="${user}" $tag "${args[@]}"
fi