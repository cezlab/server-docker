FROM cezlab/phpapache:latest
MAINTAINER "Kevin Lee" <quocln@me.com>

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    COMPOSER_ALLOW_SUPERUSER=1

# Config PHP
COPY php.ini /custom/php/50-setting.ini
# Config Apache Web
ADD default.conf /etc/apache2/sites-available/000-default.conf

# You can switch the default version using update-alternatives:
RUN update-alternatives --set php /usr/bin/php5.6

RUN composer --version
RUN php -v