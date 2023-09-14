FROM ubuntu:22.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
	curl \
	software-properties-common \
	sudo

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
	nginx-extras

# Install PHP 7.3 and some extensions
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
	php7.3-cli \
	php7.3-curl \
	php7.3-dev \
	php7.3-dom \
	php7.3-fpm \
	php7.3-gd \
	php7.3-mbstring \
	php7.3-mysql \
	php7.3-xdebug \
	php7.3-zip \
	composer

# Copy and install Phalcon 3
COPY php7.3-phalcon_3.4.5-1+php7.3_amd64.deb /tmp
RUN DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/php7.3-phalcon_3.4.5-1+php7.3_amd64.deb

# Copy nginx default site configuration
ADD default /etc/nginx/sites-available/default

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# PHP-FPM: log errors to stderr
RUN sed -i 's/error_log = \/var\/log\/php7.3-fpm.log/error_log = \/proc\/self\/fd\/2/' /etc/php/7.3/fpm/php-fpm.conf
# PHP-FPM: log workers errors
RUN sed -i 's/;catch_workers_output = yes/catch_workers_output = yes/' /etc/php/7.3/fpm/pool.d/www.conf
RUN sed -i 's/;decorate_workers_output = no/decorate_workers_output = no/' /etc/php/7.3/fpm/pool.d/www.conf
# PHP-FPM: log access to stdout
RUN sed -i 's/;access.log = log\/$pool.access.log/access.log = \/proc\/self\/fd\/1/' /etc/php/7.3/fpm/pool.d/www.conf

RUN mkdir /run/php/

RUN echo "<?php phpinfo(); ?>" > /var/www/index.php

RUN usermod -u 1000 www-data

VOLUME ["/var/www"]

EXPOSE 80

CMD service nginx start && php-fpm7.3 -F
