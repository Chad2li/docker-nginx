# Version 1.0.1
# amce: 
# 1. 将本地amce.sh-master拷贝到容器中
# 2. 设置别名 acme.sh = /opt/acme/acme.sh
# 3. 增加cron任务
FROM dhub.kubesre.xyz/nginx:latest
MAINTAINER chad <li17206@163.com>

ADD debian.sources /etc/apt/sources.list.d/

RUN \
  apt-get -y update && apt-get -y install cron

RUN \  
  echo "source /opt/acme/sh/profile.sh" >> /root/.bashrc && \
  echo "0 2 1 * * root /opt/acme/sh/acme-cron.sh >> /var/log/cron.log 2>&1" >> /etc/crontab
  
ENV acme_home=/opt/acme/home  
ADD entry.sh /opt/entry.sh
ADD acme.sh-master $acme_home
COPY account.conf $acme_home

VOLUME /opt/acme/sh
VOLUME /etc/nginx/
VOLUME /etc/localtime

EXPOSE 80
WORKDIR /opt/nginx
CMD ["/opt/entry.sh"]
