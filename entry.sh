#!/bin/bash

#source /root/.bashrc

# 申请证书
#sh $acme_home/sh/acme-new.sh

service cron start

# 启动 nginx
/usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
