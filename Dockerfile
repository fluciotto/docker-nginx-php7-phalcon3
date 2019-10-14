FROM ubuntu:18.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
	curl \
	software-properties-common \
	sudo

RUN add-apt-repository ppa:ondrej/php

RUN curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | sudo bash

RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install \
	gcc \
	git \
	libpcre3-dev \
	make \
	nginx-extras \
	php7.3-cli \
	php7.3-dev \
	php7.3-fpm \
	php7.3-gd \
	php7.3-xdebug \
	php7.3-mysql \
	php7.3-curl \
	php7.3-phalcon

ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available/default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN echo "<?php phpinfo(); ?>" > /var/www/index.php

VOLUME ["/var/www"]

EXPOSE 80

CMD service php7.3-fpm start && nginx
