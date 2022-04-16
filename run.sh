#!/bin/bash

docker run -d \
        -p 80:80 \
	--user 501:20 \
        -v `pwd`/conf/:/etc/nginx/:ro \
        -v `pwd`/data/:/opt/nginx/:rw \
        --name nginx chad/nginx-forward

