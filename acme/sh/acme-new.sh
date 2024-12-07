#!/bin/bash
# 申请证书

# 读取配置
source ./profile.sh
source $acme_home/account.conf
source ./util.sh

# 注册
cmd="$acme_sh --register-account -m $EMAIL --home $acme_home"
echo eval $cmd
eval $cmd

# 解析域名
domain_args=''
split "$DOMAINS" ','
join ' -d ' ${_split_arr[@]}

cmd="$acme_sh --force --issue --debug --log --dns dns_ali $join_str --home $acme_home"
echo eval $cmd
eval $cmd