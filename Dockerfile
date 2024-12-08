# Version 1.0.1
# amce: 
# 1. 将本地amce.sh-master拷贝到容器中
# 2. 设置别名 acme.sh = /opt/acme/acme.sh
# 3. 增加cron任务
FROM dhub.kubesre.xyz/nginx:latest
MAINTAINER chad <li17206@163.com>

RUN \
  apt-get -y update && apt-get -y install cron

RUN \  
  echo "source /opt/acme/sh/profile.sh" >> /root/.bashrc && \
  echo "0 2 1 * * root /opt/acme/sh/acme-cron.sh >> /var/log/cron.log 2>&1" >> /etc/crontab
  
ENV acme_home=/opt/acme/home  
ADD entry.sh /opt/entry.sh
ADD acme.sh-master $acme_home

# acme配置
VOLUME $acme_home/account.conf
# 申请证书脚本
VOLUME /opt/acme/sh
# nginx配置
VOLUME /etc/nginx/
# nginx日志
VOLUME /var/log/nginx
# nginx静态文件
VOLUME /opt/nginx/
# 时区
VOLUME /etc/localtime

EXPOSE 80
WORKDIR /opt/nginx
CMD ["/opt/entry.sh"]
