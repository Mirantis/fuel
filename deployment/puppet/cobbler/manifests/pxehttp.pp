class cobbler::pxehttp(
  $pxe_root = "/var/lib/tftpboot",
  ){

  file { "/etc/httpd/conf.d/pxe.conf":
    content => template('cobbler/pxe_http.conf.erb'),
    require => Package[$cobbler::packages::cobbler_web_package],
    notify => Service[$cobbler::server::cobbler_web_service]
  }

}
