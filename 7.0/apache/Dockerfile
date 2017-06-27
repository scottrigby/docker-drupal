# Don't change this unless you're prepared to fix breakage.
FROM ubuntu:xenial

# Among other things, ensure that UTF characters in a PPA name don't break things.
RUN apt-get clean && apt-get update && \
    apt-get install locales && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Copy our config into place.
COPY etc /etc/

# Install all the things.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -o Dpkg::Options::="--force-confold" install \
      software-properties-common \
      python-software-properties && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -o Dpkg::Options::="--force-confold" install \
      apache2 \
      curl \
      git \
      make \
      mysql-client \
      imagemagick \
      graphicsmagick \
      vim \
      php7.0 \
      php7.0-curl \
      php7.0-fpm \
      php7.0-gd \
      php7.0-json \
      php7.0-mbstring \
      php7.0-mcrypt \
      php7.0-mysql \
      php7.0-readline \
      php7.0-sqlite3 \
      php7.0-xml \
      php7.0-mbstring \
      php7.0-zip \
      php7.0-dom \
      php-imagick \
      php-xdebug \
      php-memcached \
      supervisor \
      wget && \
    apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Create the socket directory for PHP. This is needed because the socket dir isn't
# created until the service is started, and if PHP can't create it on startup,
# PHP will fail to start.
RUN mkdir /var/run/php && chmod 777 /var/run/php

# Enable Apache modules.
RUN a2enmod expires proxy_fcgi rewrite

# Install Composer.
RUN curl --silent --output /tmp/composer-setup.php https://getcomposer.org/installer && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm /tmp/composer-setup.php

# Install Hub.
RUN curl -L https://github.com/github/hub/releases/download/v2.2.3/hub-linux-amd64-2.2.3.tgz | tar xz -C /usr/local/share

# Set the Drush version.
ENV DRUSH_VERSION 8.1.12

# Install Drush using Composer.
RUN composer global require drush/drush:"$DRUSH_VERSION" --prefer-dist  && \
    ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Set the default working directory.
WORKDIR /var/www/html

# Before running this, from the project root, run:
# `drush dl drupal-7.56 --drupal-project-rename=docroot`
COPY docroot /var/www/html/docroot

# If a settings file doesn't exist, assume Drupal should be initialized for
# installation.
# ref: http://cgit.drupalcode.org/drupal/tree/INSTALL.txt?h=7.x
# To-do: move this optional step to a CMD docker-entrypoint script, based on
# env variables.
ARG SITE
ENV SITE ${SITE:-docroot/sites/default}
RUN if [ ! -f $SITE/settings.php ]; then cp $SITE/default.settings.php $SITE/settings.php; chmod a+w $SITE/settings.php; fi && \
    if [ ! -d $SITE/files ]; then mkdir $SITE/files; chmod a+w $SITE/files; fi && \
    ls -la $SITE

# Set defaults for Apache and PHP.
ENV APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data
RUN chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP /var/www/html

# Expose a volume to tooling that looks for it.
# But don't declare VOLUME unless you are done with that directory.
# ref: https://github.com/moby/moby/issues/3639
VOLUME /var/www/html

# Expose Apache to the outside world.
EXPOSE 80

ENTRYPOINT ["/usr/bin/supervisord"]
