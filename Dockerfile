FROM ubuntu:18.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
	curl \
	sudo

RUN curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | sudo bash

RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install \
	gcc \
	git \
	libpcre3-dev \
	make \
	nginx-extras \
	php7.2-cli \
	php7.2-dev \
	php7.2-fpm \
	php7.2-gd \
	php7.2-xdebug \
	php7.2-mysql \
	php7.2-curl \
	php7.2-phalcon

ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available/default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN echo "<?php phpinfo(); ?>" > /var/www/index.php

VOLUME ["/var/www"]

EXPOSE 80

CMD service php7.2-fpm start && nginx
