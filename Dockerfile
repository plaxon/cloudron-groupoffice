FROM cloudron/base:2.0.0@sha256:f9fea80513aa7c92fe2e7bf3978b54c8ac5222f47a9a32a7f8833edf0eb5a4f4

RUN mkdir -p /app/code
WORKDIR /app/code

# configure apache
RUN rm /etc/apache2/sites-enabled/*
RUN sed -e 's,^ErrorLog.*,ErrorLog "|/bin/cat",' -i /etc/apache2/apache2.conf
COPY apache/mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf

RUN a2disconf other-vhosts-access-log
COPY apache/app.conf /etc/apache2/sites-enabled/app.conf
RUN echo "Listen 3000" > /etc/apache2/ports.conf

# configure mod_php
RUN a2enmod php7.3
RUN crudini --set /etc/php/7.3/apache2/php.ini PHP upload_max_filesize 256M && \
    crudini --set /etc/php/7.3/apache2/php.ini PHP upload_max_size 256M && \
    crudini --set /etc/php/7.3/apache2/php.ini PHP post_max_size 256M && \
    crudini --set /etc/php/7.3/apache2/php.ini PHP memory_limit 256M && \
    crudini --set /etc/php/7.3/apache2/php.ini PHP max_execution_time 200 && \
    crudini --set /etc/php/7.3/apache2/php.ini Session session.save_path /run/app/sessions && \
    crudini --set /etc/php/7.3/apache2/php.ini Session session.gc_probability 1 && \
    crudini --set /etc/php/7.3/apache2/php.ini Session session.gc_divisor 100

RUN apt-get update && \
    apt-get install -y libxml2-dev libpng-dev libfreetype6-dev libjpeg62-turbo-dev zip tnef ssl-cert libldap2-dev \
		catdoc unzip tar imagemagick tesseract-ocr tesseract-ocr-eng poppler-utils exiv2 libzip-dev mariadb-client && \
		docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr && \
		docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install soap pdo pdo_mysql calendar gd sysvshm sysvsem sysvmsg ldap opcache intl pcntl zip bcmath

RUN pecl install apcu
RUN docker-php-ext-enable apcu

ADD ./config.php.tpl /etc/groupoffice/config.php.tpl

#Download package from sourceforge
ADD https://iweb.dl.sourceforge.net/project/group-office/6.4/$PACKAGE.tar.gz /tmp/
#COPY /groupoffice-com-6.3.3-php-71.tar.gz /tmp/
RUN tar zxvfC /tmp/$PACKAGE.tar.gz /tmp/ \
    && rm /tmp/$PACKAGE.tar.gz \
    && mv /tmp/$PACKAGE /app/code/

#Install ioncube
ADD https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz /tmp/

RUN tar xvzfC /tmp/ioncube_loaders_lin_x86-64.tar.gz /tmp/ \
    && rm /tmp/ioncube_loaders_lin_x86-64.tar.gz \
    && mkdir -p /usr/local/ioncube \
    && cp /tmp/ioncube/ioncube_loader_* /usr/local/ioncube \
    && rm -rf /tmp/ioncube

RUN echo "zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.3.so" >> /usr/local/etc/php/conf.d/00_ioncube.ini


# COPY index.php start.sh /app/code/
RUN chown -R www-data.www-data /app/code

CMD [ "/app/code/start.sh" ]