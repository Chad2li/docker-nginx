#!/bin/bash

docker run -d -p 80:80 -v `pwd`/conf/:/etc/nginx/:ro --name nginx-forward chad/nginx-forward
