#!/bin/bash

acme=acme.sh-master
if [ ! -d "$acme" ]; then
  # down acme from github
  wget -O $acme.zip https://codeload.github.com/acmesh-official/acme.sh/zip/refs/heads/master && \
  unzip $acme.zip 
fi

docker build -t chad/nginx-forward .
