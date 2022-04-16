# Version 1.0.1
FROM nginx:1.21.6
MAINTAINER chad <li17206@163.com>


RUN \
	rm /etc/localtime && \
	alias ll='ls -la --color=auto'

VOLUME /etc/nginx/
VOLUME /etc/localtime

EXPOSE 80
CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
