#!/bin/bash

name=nginx
docker stop $name && docker rm $name

docker run -d \
	-p 443:443 \
        -p 80:80 \
        -v `pwd`/nginx/conf/:/etc/nginx/:rw \
        -v `pwd`/nginx/data/:/opt/nginx/:rw \
	-v `pwd`/nginx/logs/:/var/log/nginx/:rw \
        -v `pwd`/acme/sh/:/opt/acme/sh:rw \
        -v `pwd`/account.conf:/opt/acme/home/account.conf:rw \
	-v /etc/localtime:/etc/localtime:ro \
	-m 512m --cpuset-cpus=2,3 \
	--restart=always \
        --name $name chad/nginx

