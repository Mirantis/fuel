class heat::cli (
  $ensure = 'present'
) {

  include heat::params

  package { 'heat-cli':
    ensure => $ensure,
    name   => $::heat::params::heat_cli_package_name,
  }

}
