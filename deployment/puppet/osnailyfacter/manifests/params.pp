class osnailyfacter::params {
  case $::osfamily {
    'RedHat': {
      $apachedir = '/etc/httpd/'
      $apache_site_dir = "${apachedir}conf.d/"
    }
    'Debian': {
      $apachedir = '/etc/apache2/'
      $apache_site_dir = "${apachedir}site-enabled/"
    }
  }
}

