#!/bin/bash
# 将证书部署到nginx

domain=$1
# 加载配置
source $acme_home/account.conf


name=$(echo $domain |sed 's/*//g'|sed 's/\.//g')
mkdir -p $NGINX_PATH'/'$name
# 拷贝 key
cmd="cp $acme_home/$domain'_ecc/'$domain.key $NGINX_PATH/$name/key.key"
echo eval $cmd
eval $cmd
# 拷贝 chain
cmd="cp $acme_home/$domain'_ecc/fullchain.cer' $NGINX_PATH/$name/"
echo eval $cmd
eval $cmd
# 重加载 nginx
nginx -s reload
echo reload nginx...