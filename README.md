# 概述

该镜像为`nginx:latest`，并使用`cron`每月1号凌晨2点自动刷新证书，部署到nginx和阿里云。

# 前置步骤

在运行容器前，需要先简单配置下。

## account.conf

`account.conf`需要挂载到`/opt/acme/home/account.conf`中，并且`acme`在运行
过程中会修改此文件，所以挂载时需要有读写(rw)权限。

- CONTACT_IDS
  ```
  # 阿里云证书部署联系人ID
  CONTACT_IDS={阿里云联系人ID}
  ```
  该联系人ID，可以通过阿里云控制台获取，在浏览器上打开`F12`，手动部署一遍，通过`network`
  中即可找到。    
  （这一步稍麻烦，但通过接口`ListContact`拿到的并不准确。）
- DOMAINS
  ```
  DOMAINS={申请证书域名，支持*通配符，多个以,分隔}
  ```
  部署阿里云时需要知道每个证书需要部署的资源，脚本中资源是通过域名关联的。
  配置举例如下：
  ```
  DOMAINS=*.baidu.com,img.cdn.baidu.com
  baiducom_BINDS=map.baidu.com,api.baidu.com
  imgcdnbaiducom_BINDS=img.cdn.baidu.com
  ```
  DOMAINS声明需要申请两个证书，分别颁发给`*.baidu.com`
  和`img.cdn.baidu.com`。    
  `baiducom_BINDS`是`*.baidu.com`去掉`*`和`.`后加上`BINDS`组成，
  声明`*.baidu.com`证书需要部署到绑定了`map.baidu.com`和`api.baidu.com`
  域名的资源上。    
  同理，`imgcdnbaiducom_BINDS`是由`img.cdn.baidu.com`去掉`.`加上`BINDS`
  组成，声明该证书需要部署到绑定了`img.cdn.baidu.com`域名的资源上。

# 使用

## 构建镜像

```shell
./build.sh
```

该命令以当前目录为基础，下载[acme](https://github.com/acmesh-official/acme.sh)，
并构建`chad/nginx`镜像。

## 运行

```shell
./run.sh
```

此时，以`nginx`命名的容器创建并启动成功。

## 修改证书

当第1次启动或者变更颁发证书时（修改`account.conf`里的`DOMAINS`），由于`cron`
执行的`acme-cron.sh`脚本仅刷新证书，所以需要手动创建证书。    
先进入`nginx`容器里：

```shell
docker exec -ti nginx /bin/bash 
```

再创建证书:

```shell
cd /opt/acme/sh
./acme-new.sh
```

此时仅创建了证书，如果需要立刻部署（否则会等到下一次`cron`任务，即下个1号凌晨2点）：

```shell
cd /opt/acme/sh
./deploy.sh
```

执行完部署后，所有证书都会部署到nginx和阿里云上。

# 配置nginx

nginx具体的配置不在本文的介绍范围内，本文仅说明该容器修改或需要配置的内容。    
nginx的目录在物理机的`./nginx/`目录下，结构说明：

| 物理目录        | 容器目录           | 说明   |
|-------------|----------------|------|
| nginx/conf/ | /etc/nginx/    | 配置   |
| nginx/data/ | /opt/nginx/    | 静态文件 |
| nginx/logs/ | /var/log/nginx | 日志   |

```
nginx\conf\:                nginx配置
_____\____\nginx.conf    nginx主配置，一般不需要修改     
_____\____\certs\        证书目录    
_____\____\conf.d\       nginx配置文件目录
```

- certs    
  证书部署时，会将所有证书以域名分割部署到该目录下，如颁发给`*.baidu.com`的证书会
  部署到`certs/baiducom/`目录下。
  包含文件`certs/baiducom/key.key`和`certs/baiducom/fullchain.cer`。
- conf.d    
  所有的nginx配置都可以放在该目录下，并以`.conf`结尾。该目录下当前有两个例子`html.conf`
  和`https.conf`例子，需要根据实际情况修改，并移除不需要的`.conf`配置文件。

当nginx配置变更后，需要执行nginx重载命令。
测试配置文件是否有错误：

```shell
docker exec nginx nginx -t
```

执行重载，配置生效：

```shell
docker exec nginx nginx -s reload
```
