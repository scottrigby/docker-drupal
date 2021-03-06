#!/usr/bin/env bash

if [ -f initialized.txt ]; then
  echo 'Drupal is already initialized.'
else
  touch initialized.txt

  # Install Drush using Composer.
  composer global require drush/drush:"$DRUSH_VERSION" --prefer-dist
  ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

  # Install Drupal codebase into docroot.
  pushd docroot

  # Determine how to install Drupal codebase from ENVs.
  if [ ! -z "$GIT_CLONE_URL" ]; then
    # Git download method.
    apt-get update && apt-get install -y git

    [ ! -z "$GIT_REF" ] && REF_COMMAND="--branch $GIT_REF" || REF_COMMAND=''
    git clone $GIT_CLONE_URL $REF_COMMAND --depth=1 tmp
  else
    # Drush method.
    drush dl drupal-$DRUSH_DRUPAL_VERSION --drupal-project-rename=tmp
  fi

  # Be permissive about copying dotfiles, because we won't know what important
  # ones are in the custom git repo, or may be added to Drupal core in the
  # future. It will only give a warning that you can not copy the directory
  # itself (alias "." and "..").
  mv tmp/$GIT_DOCROOT/{.,}* .
  rm -r tmp
  popd

  if [ ! -z "$DRUPAL_SETTINGS_PATH" ]; then
    DRUPAL_SETTINGS_DIR=$(dirname $DRUPAL_SETTINGS_PATH)
    mkdir -p $DRUPAL_SETTINGS_DIR
    gotpl /etc/gotpl/settings.php.tpl > $DRUPAL_SETTINGS_PATH
  fi

  # If a settings file doesn't exist, assume Drupal should be initialized for
  # installation.
  # ref: http://cgit.drupalcode.org/drupal/tree/INSTALL.txt?h=7.x
  if [ ! -f $SITE/settings.php ]; then cp $SITE/default.settings.php $SITE/settings.php; chmod a+w $SITE/settings.php; fi
  if [ ! -d $SITE/files ]; then mkdir $SITE/files; chmod a+w $SITE/files; fi

  chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP /var/www/html
fi

if [ ! -z "$BUILD_DEV" ]; then
  apt-get update && apt-get install -y \
    make \
    vim \
    php-xdebug && \
  apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
fi

/usr/bin/supervisord
