# The heat::db::mysql class creates a MySQL database for heat.
# It must be used on the MySQL server
#
# == Parameters
#
#  [*password*]
#    password to connect to the database. Mandatory.
#
#  [*dbname*]
#    name of the database. Optional. Defaults to heat.
#
#  [*user*]
#    user to connect to the database. Optional. Defaults to heat.
#
#  [*host*]
#    the default source host user is allowed to connect from.
#    Optional. Defaults to 'localhost'
#
#  [*allowed_hosts*]
#    other hosts the user is allowd to connect from.
#    Optional. Defaults to undef.
#
#  [*charset*]
#    the database charset. Optional. Defaults to 'latin1'
#
class heat::db::mysql(
  $password      = false,
  $dbname        = 'heat',
  $user          = 'heat',
  $dbhost          = 'localhost',
  $allowed_hosts = undef,
  $charset       = 'latin1',
) {

  include 'heat::params'

#  require 'mysql::python'
  # Create the db instance before openstack-heat if its installed
#  Mysql::Db[$dbname] -> Anchor<| title == "heat-start" |>
#  Mysql::Db[$dbname] ~> Exec<| title == 'heat-db-sync' |>

  mysql::db_new { 
    $dbname:
    user         => $user,
    password     => $password,
    host         => $::heat::db::mysql::dbhost,
    charset      => $heat::params::heat_db_charset,
    # I may want to inject some sql
    #require      => Class['mysql::server'],
    grant    => ['all'],
  }
}
