# Version 0.0.1
FROM nginx:1.11.13
MAINTAINER chad <li17206@163.com>

# CentOS
RUN echo "Asia/shanghai" > /etc/timezone
# Ubuntu
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN echo "\n\nalias ll='ls -la'" >> /root/.bashrc

VOLUME /etc/nginx/

EXPOSE 80
ENTRYPOINT ["/usr/sbin/nginx"]
CMD ["-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
