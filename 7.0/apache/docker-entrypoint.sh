#!/usr/bin/env bash

if [ -f docroot/initialized.txt ]; then
  echo 'Drupal is already initialized.'
  exit 0
fi

touch docroot/initialized.txt

# Install Drush using Composer.
composer global require drush/drush:"$DRUSH_VERSION" --prefer-dist
ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Before running this, from the project root, run:
# `drush dl drupal-7.56 --drupal-project-rename=docroot`
#drush dl drupal-$DRUPAL_VERSION --drupal-project-rename=docroot -y
cd docroot
drush dl drupal-$DRUPAL_VERSION
mv drupal-$DRUPAL_VERSION/* drupal-$DRUPAL_VERSION/.htaccess ..
rm -r drupal-$DRUPAL_VERSION
cd ..

# If a settings file doesn't exist, assume Drupal should be initialized for
# installation.
# ref: http://cgit.drupalcode.org/drupal/tree/INSTALL.txt?h=7.x
if [ ! -f $SITE/settings.php ]; then cp $SITE/default.settings.php $SITE/settings.php; chmod a+w $SITE/settings.php; fi
if [ ! -d $SITE/files ]; then mkdir $SITE/files; chmod a+w $SITE/files; fi

chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP /var/www/html

php-fpm -F
