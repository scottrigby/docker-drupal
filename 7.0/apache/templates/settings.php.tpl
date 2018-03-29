<?php

$databases['default']['default'] = [
  'host' => getenv('MARIADB_HOST'),
  'database' => getenv('DRUPAL_DATABASE_NAME'),
  'username' => getenv('DRUPAL_DATABASE_USER'),
  'password' => getenv('DRUPAL_DATABASE_PASSWORD'),
  'driver' => 'mysql',
];
