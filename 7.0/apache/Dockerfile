# Don't change this unless you're prepared to fix breakage.
FROM ubuntu:xenial

ENV GOTPL_VER 0.1.5
ENV GOTPL_URL https://github.com/wodby/gotpl/releases/download/${GOTPL_VER}/gotpl-linux-amd64-${GOTPL_VER}.tar.gz

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
      mysql-client \
      imagemagick \
      graphicsmagick \
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
      php7.0-zip \
      php7.0-dom \
      php-imagick \
      php-memcached \
      supervisor && \
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

# Install Gotpl.
RUN wget -qO- ${GOTPL_URL} | tar xz -C /usr/local/bin

# Set the default working directory.
WORKDIR /var/www/html

COPY docker-entrypoint.sh /

ENV DRUSH_VERSION ${DRUSH_VERSION:-8.1.12}
ENV DRUSH_DRUPAL_VERSION ${DRUPAL_VERSION:-7.56}

# Download Drupal via Git instead of default Drush method. This env var is the
# Custom Drupal codebase Git repo clone URL. Example:
# "https://git.drupal.org/project/drupal.git".
ENV GIT_CLONE_URL ${GIT_CLONE_URL:-}
# Subdirectory within the git repo that should be moved to the Drupal docroot.
# Example: "path/to/docroot". Leave blank if the docroot is the git root.
ENV GIT_DOCROOT ${GIT_DOCROOT:-}
# Optionally specify a git branch or tag to clone.
ENV GIT_REF ${GIT_REF:-}

# Drupal site directory, in case of Drupal multisite codebase.
# ref: https://www.drupal.org/docs/7/multisite-drupal/multi-site-sharing-the-same-code-base
ENV SITE ${SITE:-docroot/sites/default}

# Set defaults for Apache and PHP.
ENV APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data

# Set to true to build development packages.
ENV DEV ${BUILD_DEV:-}

# Location for templatized Drupal DB connection settings file. This is an env
# because the location is often project-specific (think Acquia site group). Be
# sure to include the file name in the path string (the file name itself often
# matters). To bypass settings file creation, do not set DRUPAL_SETTINGS_PATH.
ENV DRUPAL_SETTINGS_PATH ${DRUPAL_SETTINGS_PATH:-}
ENV MARIADB_HOST ${MARIADB_HOST:-}
ENV MARIADB_DATABASE ${MARIADB_DATABASE:-}
ENV MARIADB_USER ${MARIADB_USER:-}
ENV MARIADB_PASSWORD ${MARIADB_PASSWORD:-}

COPY templates /etc/gotpl/

# Expose a volume to tooling that looks for it.
# But don't declare VOLUME unless you are done with that directory.
# ref: https://github.com/moby/moby/issues/3639
VOLUME /var/www/html/docroot

# Expose Apache to the outside world.
EXPOSE 80

CMD ["/docker-entrypoint.sh"]
