FROM ubuntu:18.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
	curl \
	software-properties-common \
	sudo

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
	nginx-extras

# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
# 	gcc \
# 	git \
# 	libpcre3-dev \
# 	make \
# nginx-extras


RUN add-apt-repository ppa:ondrej/php

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
	php7.3-cli \
	php7.3-dev \
	php7.3-fpm \
	php7.3-gd \
	php7.3-xdebug \
	php7.3-mysql \
	php7.3-curl \
	php7.3-zip

COPY php7.3-phalcon_3.4.5-1+php7.3_amd64.deb /tmp
RUN DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/php7.3-phalcon_3.4.5-1+php7.3_amd64.deb

# ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available/default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log


RUN sed -i 's/error_log = \/var\/log\/php7.3-fpm.log/error_log = \/proc\/self\/fd\/2/' /etc/php/7.3/fpm/php-fpm.conf

RUN sed -i 's/;catch_workers_output = yes/catch_workers_output = yes/' /etc/php/7.3/fpm/pool.d/www.conf
RUN sed -i 's/;decorate_workers_output = no/decorate_workers_output = no/' /etc/php/7.3/fpm/pool.d/www.conf
RUN sed -i 's/;access.log = log\/$pool.access.log/access.log = \/proc\/self\/fd\/1/' /etc/php/7.3/fpm/pool.d/www.conf

RUN mkdir /run/php/

RUN echo "<?php phpinfo(); ?>" > /var/www/index.php

VOLUME ["/var/www"]

EXPOSE 80

# CMD service php7.3-fpm start && nginx -g 'daemon off;'
CMD service nginx start && php-fpm7.3 -F
