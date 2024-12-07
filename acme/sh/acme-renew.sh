#!/bin/bash
# 刷新证书

# 读取配置
source ./profile.sh
source $acme_home/account.conf
source ./util.sh

# 解析域名
domain_args=''
split "$DOMAINS" ','
join ' -d ' ${_split_arr[@]}

cmd="$acme_sh --renew $join_str --force"
echo eval $cmd
#eval $cmd
