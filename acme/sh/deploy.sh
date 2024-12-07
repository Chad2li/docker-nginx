#!/bin/bash

# 读取配置
source $acme_home/account.conf
source ./util.sh

# 遍历证书
split "$DOMAINS" ','
for domain in "${_split_arr[@]}"
do
	echo deploy domain: $domain
	./deploy-ali.sh $domain && \
	./deploy-nginx.sh $domain
done

