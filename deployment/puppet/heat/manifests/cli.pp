class heat::cli (
  $ensure = 'present'
) {
  include heat::params

  case $::osfamily {
    'RedHat': {

      package { 'deps_pbr_package_name':
        ensure => $ensure,
        name   => $::heat::params::deps_pbr_package_name,
      }
      package { 'heat-cli':
        ensure => $ensure,
        name   => $::heat::params::heat_cli_package_name,
        require => Package['deps_pbr_package_name'],
      }
    }
    default: {
    }
  }
}
