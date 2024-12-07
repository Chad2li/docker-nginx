#!/bin/bash

docker stop nginx && docker rm nginx

docker run -d \
        -p 80:80 \
        -v `pwd`/nginx/conf/:/etc/nginx/:rw \
        -v `pwd`/nginx/data/:/opt/nginx/:rw \
	-v `pwd`/nginx/logs/:/var/log/nginx/:rw \
        -v `pwd`/acme/sh/:/opt/acme/sh:rw \
	-v /etc/localtime:/etc/localtime:ro \
        --name nginx chad/nginx-forward

