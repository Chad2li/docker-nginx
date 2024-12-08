# Version 1.0.1
FROM dhub.kubesre.xyz/nginx:latest
MAINTAINER chad <li17206@163.com>

# 替换阿里源
ADD debian.sources /etc/apt/sources.list.d/debian.sources

# 安装 cron
RUN \
  apt-get -y update && apt-get -y install cron

# 增加环境变量和 cron 任务
RUN \  
  echo "source /opt/acme/sh/profile.sh" >> /root/.bashrc && \
  echo "0 2 1 * * root /opt/acme/sh/acme-cron.sh >> /var/log/cron.log 2>&1" >> /etc/crontab

# 申明 acme_home 环境变量
ENV acme_home=/opt/acme/home
# 拷贝启动脚本
ADD entry.sh /opt/entry.sh
# 拷贝acme
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

EXPOSE 80 443
WORKDIR /opt/nginx

# 启动脚本
CMD ["/opt/entry.sh"]
