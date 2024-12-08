#!/bin/bash
domain=$1
echo start deploy domain: $domain

# todo
# 1. 重试 - done
# 2. 读取配置、证书
source $acme_home/account.conf
# 公网地址
CAS_API="https://cas.aliyuncs.com/"
api_key=$SAVED_Ali_Key
api_secret=$SAVED_Ali_Secret
# 联系人id
contact_ids="$CONTACT_IDS"
# 内网地址
#CAS_API = "https://cas-vpc.cn-hangzhou.aliyuncs.com"

# 上传证书
# _upload_query "$_domain" "$_sub_domain" && _ali_rest "Add record"

upload() {
  _list_user_certificate_order && _ali_rest "ListUserCertificateOrder"
  echo $responsea
}

# 部署

# 上传证书参数
_upload_user_certificate_query() {
  query=''
  query=$query'AccessKeyId='$api_key
  query=$query'&Action=UploadUserCertificate'
  _url_encode "$cert_chain"
  query=$query'&Cert='$_url_encode_str
  query=$query'&Format=JSON'
  _url_encode "$cert_key"
  query=$query'&Key='$_url_encode_str
  _url_encode 'jbdCert-'$(date "+%Y%m%d%H%M%S")'-'$RANDOM
  query=$query'&Name='$_url_encode_str
  # query=$query'&ResourceGroupId='
  _url_encode 'HMAC-SHA1'
  query=$query'&SignatureMethod='$_url_encode_str
  _url_encode $(date +%s%3N)$RANDOM
  query=$query'&SignatureNonce='$_url_encode_str
  _url_encode '1.0'
  query=$query'&SignatureVersion='$_url_encode_str
  _url_encode $(date -d "-8 hour" "+%Y-%m-%dT%H:%M:%SZ")
  query=$query'&Timestamp='$_url_encode_str
  _url_encode '2020-04-07'
  query=$query'&Version='$_url_encode_str
}

# 创建部署任务参数
_create_deployment_job_query() {
  query=''
  query=$query'AccessKeyId='$api_key
  query=$query'&Action=CreateDeploymentJob'
  query=$query'&CertIds='$certId
  _url_encode $contact_ids
  query=$query'&ContactIds='$_url_encode_str
  query=$query'&Format=JSON'
  query=$query'&JobType=user'
  _url_encode 'certDeploy-20241204002'
  query=$query'&Name='$_url_encode_str
  _url_encode $resource_ids
  query=$query'&ResourceIds='$_url_encode_str
  #_url_encode $(date -d "+1 day" +%s%3N)
  #query=$query'&ScheduleTime='$_url_encode_str
  _url_encode 'HMAC-SHA1'
  query=$query'&SignatureMethod='$_url_encode_str
  _url_encode $(date +%s%3N)$RANDOM
  query=$query'&SignatureNonce='$_url_encode_str
  _url_encode '1.0'
  query=$query'&SignatureVersion='$_url_encode_str
  _url_encode $(date -d "-8 hour" "+%Y-%m-%dT%H:%M:%SZ")
  query=$query'&Timestamp='$_url_encode_str
  _url_encode '2020-04-07'
  query=$query'&Version='$_url_encode_str
}

# https://help.aliyun.com/zh/ssl-certificate/developer-reference/api-cas-2020-04-07-listusercertificateorder?spm=a2c4g.11186623.0.0.335f6f93mu9Jvx
_list_cloud_resources_query() {
  query=''
  query=$query'AccessKeyId='$api_key
  query=$query'&Action=ListCloudResources'
  query=$query'&CurrentPage=1'
  query=$query'&Format=JSON'
  # query=$query'&Keyword='
  query=$query'&OrderType=UPLOAD'
  # query=$query'&ResourceGroupId='
  # query=$query'&ShowSize='
  _url_encode 'HMAC-SHA1'
  query=$query'&SignatureMethod='$_url_encode_str
  _url_encode $(date +%s%3N)$RANDOM
  query=$query'&SignatureNonce='$_url_encode_str
  _url_encode '1.0'
  query=$query'&SignatureVersion='$_url_encode_str
  # query=$query'&Status='
  _url_encode $(date -d "-8 hour" "+%Y-%m-%dT%H:%M:%SZ")
  query=$query'&Timestamp='$_url_encode_str
  _url_encode '2020-04-07'
  query=$query'&Version='$_url_encode_str
}

_list_contact_query() {
  query=''
  query=$query'AccessKeyId='$api_key
  query=$query'&Action=ListCloudResources'
  query=$query'&CurrentPage=1'
  query=$query'&Format=JSON'
  # query=$query'&Keyword='
  query=$query'&ShowSize=1'
  _url_encode 'HMAC-SHA1'
  query=$query'&SignatureMethod='$_url_encode_str
  _url_encode $(date +%s%3N)$RANDOM
  query=$query'&SignatureNonce='$_url_encode_str
  _url_encode '1.0'
  query=$query'&SignatureVersion='$_url_encode_str
  _url_encode $(date -d "-8 hour" "+%Y-%m-%dT%H:%M:%SZ")
  query=$query'&Timestamp='$_url_encode_str
  _url_encode '2020-04-07'
  query=$query'&Version='$_url_encode_str
}

_list_deployment_job_query() {
  query=''
  query=$query'AccessKeyId='$_url_encode_str
  query=$query'&Action=ListDeploymentJob'
  query=$query'&CurrentPage=1'
  query=$query'&Format=JSON'
  query=$query'&JobType=user'
  _url_encode 'HMAC-SHA1'
  query=$query'&SignatureMethod='$_url_encode_str
  _url_encode $(date +%s%3N)$RANDOM
  query=$query'&SignatureNonce='$_url_encode_str
  _url_encode '1.0'
  query=$query'&SignatureVersion='$_url_encode_str
  query=$query'&Status=success'
  _url_encode $(date -d "-8 hour" "+%Y-%m-%dT%H:%M:%SZ")
  query=$query'&Timestamp='$_url_encode_str
  _url_encode '2020-04-07'
  query=$query'&Version='$_url_encode_str
}

# 解析json中的值
# arg-1: json, arg-2: 需要提取值的json key
_json_parse() {
  _json_value=''
  _json_value=$(echo $1 | awk -v k="$2" 'BEGIN{RS=","; FS=":"} $1 ~ "\""k"\""{gsub(/[{}"]/,"",$2); print $2}')
}

# get请求
# arg-1: 参数方法名, arg-2：重试次数，默认5
_get() {
  act=$1
  mtd="GET"
  # 默认重试3遍
  retry=${2:-5}
  # 执行参数
  $act
  # 资源标识
  _url_encode $query
  sign=$_url_encode_str
  sign="${mtd}&%2F&"$sign
  #echo sign "$sign"
  sign=$(echo -n "$sign" | openssl dgst -sha1 -hmac "$api_secret&" -binary | openssl base64)
  url=$CAS_API'?'$query'&Signature='$sign
  #echo request $url
  # 请求
  echo get: $act
  resp=$(curl -s -X $mtd $url)
  # 判断是否成功
  #_json_parse $resp 'Code'
  #echo code $_json_value
  #if [ -n "$_json_value" ]; then
  if echo $resp | grep -q '"Code"'; then
    # 失败 重试
    if [ $retry -gt 1 ]; then
      sleep 3
      echo get failed retry for $retry: $act
      _get $act $(($retry-1))
    else
      echo get failed: $act, url: $url
      echo get failed: $act, resp: $resp
      exit 1
    fi
  fi
}

# 解析响应中域名关联的资源ID
# arg-1: 域名, arg-2: 响应
_list_user_certificate_order_parse() {
  _split $2
  resource_id_sub=''
  d=$1
  for json in "${_split_arr[@]}"
  do
      id=$(echo $json | grep $d | awk -v k="Id" 'BEGIN{RS=","; FS=":"} $1 ~ "\""k"\""{gsub(/[{}"]/,"",$2); print $2}')
      if [ ! -z "$id" ]; then
        if [ ! -z "$resource_id_sub" ]; then
          resource_id_sub=$resource_id_sub','$id
        else
          resource_id_sub=$id
        fi
      fi
  done
}

_url_encode() {
  _url_encode_str=$(echo $1 |sed 's/%/%25/g'|sed 's/=/%3D/g'|sed 's/&/%26/g'|sed 's/ /%20/g'| sed 's/:/%3A/g'|sed 's/\\/%5C/g'|sed 's/+/%2B/g'|sed 's/\//%2F/g'|sed 's/,/%2C/g')
}

_split() {
  _split_arr=''
  old_ifs=$IFS
  IFS='}' read -r -a _split_arr <<< "$1"
  IFS=$old_ifs
}


# 上传证书并获取证书ID
_upload_user_certificate() {
  _get '_upload_user_certificate_query'
  _json_parse $resp 'CertId'
  certId=$_json_value
  echo certId $certId
}

# 创建部署任务，证书ID-资源ID
_create_deployment_job() {
  _get '_create_deployment_job_query'
  echo resp $resp
}

# 获取域名关联的资源ID
_list_cloud_resources() {
  # 请求
  _get '_list_cloud_resources_query'
  # 从响应中解析关联域名的资源ID
  for d in "${domain_binds[@]}"
  do
    # 解析资源ID数组
    _list_user_certificate_order_parse $d $resp
    if [ ! -z "$resource_id_sub" ]; then
      if [ ! -z "$resource_ids" ]; then
        resource_ids=$resource_ids','$resource_id_sub
      else
        resource_ids=$resource_id_sub
      fi 
    fi
  done
  echo resource_ids $resource_ids
}

# 获取联系人列表
_list_contact() {
  _get '_list_contact_query'
  echo resp $resp
}

_list_deployment_job() {
  _get '_list_deployment_job_query'
  echo _list_deployment_job $resp
}

# 获取证书关联的域名
_get_domain_binds() {
  name=$(echo $domain |sed 's/*//g'|sed 's/\.//g')'_BINDS'
  _split ${!name}
  domain_binds=$_split_arr
  echo domain_binds $domain_binds
  if [ ! -n "$domain_binds" ];then
    echo get domain binds failed: $domain
    exit 1
  fi
}

# 读取证书内容
_read_cert() {
  cert_key=''
  cert_chain=''
  # key
  cert_key=$(cat $acme_home'/'$domain'_ecc/'$domain'.key')
  #echo cert_key $cert_key
  # chain
  cert_chain=$(cat $acme_home'/'$domain'_ecc/fullchain.cer')
  #echo cert_chain $cert_chain
}

#_list_contact

#_list_deployment_job

# 获取证书关联域名
_get_domain_binds && \
# 获取关联资源ID
_list_cloud_resources && \
# 读取证书内容
_read_cert && \
# 上传证书
_upload_user_certificate && \
# 部署
_create_deployment_job







