class heat::cli (
  $ensure = 'present'
) {

  include heat::params

  package { 'deps_pbr_package_name':
    ensure => $ensure,
    name   => $::heat::params::deps_pbr_package_name,
  }
  if $::osfamily == 'RedHat' {
    package { 'heat-cli':
      ensure => $ensure,
      name   => $::heat::params::heat_cli_package_name,
    }
    Package['deps_pbr_package_name'] -> Package['heat-cli']
  }
}

