<?php

$databases['default']['default'] = [
  'host' => '{{ getenv "MARIADB_HOST" "" }}',
  'database' => '{{ getenv "MARIADB_DATABASE" "" }}',
  'username' => '{{ getenv "MARIADB_USER" "" }}',
  'password' => '{{ getenv "MARIADB_PASSWORD" "" }}',
  'driver' => 'mysql',
];
