#!/bin/bash

function git_login {
    eval $(ssh-agent)
    ssh-add ~/.ssh/id_rsa
}

function ssh_generate_key {
     comment=$1
     ssh-keygen -t rsa -b 4096 -C "$comment"
}

function ssh_generate_pem_key {
     comment=$1
     ssh-keygen -t rsa -b 4096 -m PEM -C "$comment"
}

