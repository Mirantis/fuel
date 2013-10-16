# enable an Apache module
define apache::loadmodule () {
  exec { "/usr/sbin/a2enmod ${name}" :
    unless => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
    notify => Service['httpd']
  }
}

# deploys Ceph radosgw as an Apache FastCGI application
class ceph::radosgw (
  $keyring_path     = '/etc/ceph/keyring.radosgw.gateway',
  $radosgw_auth_key = 'client.radosgw.gateway',
  $rgw_user         = $::ceph::params::user_httpd,

  # RadosGW settings
  $rgw_host                         = $::ceph::rgw_host,
  $rgw_port                         = $::ceph::rgw_port,
  $rgw_keyring_path                 = $::ceph::rgw_keyring_path,
  $rgw_socket_path                  = $::ceph::rgw_socket_path,
  $rgw_log_file                     = $::ceph::rgw_log_file,
  $rgw_data                         = $::ceph::rgw_data,
  $rgw_dns_name                     = $::ceph::rgw_dns_name,
  $rgw_print_continue               = $::ceph::rgw_print_continue,

  #rgw Keystone settings
  $rgw_use_pki                      = $::ceph::rgw_use_pki,
  $rgw_use_keystone                 = $::ceph::rgw_use_keystone,
  $rgw_keystone_url                 = $::ceph::rgw_keystone_url,
  $rgw_keystone_admin_token         = $::ceph::rgw_keystone_admin_token,
  $rgw_keystone_token_cache_size    = $::ceph::rgw_keystone_token_cache_size,
  $rgw_keystone_accepted_roles      = $::ceph::rgw_keystone_accepted_roles,
  $rgw_keystone_revocation_interval = $::ceph::rgw_keystone_revocation_interval,
  $rgw_nss_db_path                  = $::ceph::rgw_nss_db_path,
) {

  $dir_httpd_root = '/var/www/radosgw'

  package { [$::ceph::params::package_radosgw,
             $::ceph::params::package_fastcgi,
             $::ceph::params::package_libnss,
            ]:
    ensure  => 'latest',
  }

  service { 'radosgw':
    ensure  => 'running',
    name    => $::ceph::params::service_radosgw,
    enable  => true,
  }

  if !(defined('horizon') or 
       defined($::ceph::params::package_httpd) or
       defined($::ceph::params::service_httpd) ) {
    package {$::ceph::params::package_httpd:
      ensure => 'latest',
    }
    service { 'httpd':
      ensure => 'running',
      name   => $::ceph::params::service_httpd,
      enable => true,
    }
  }

  # All files need to be owned by the rgw / http user.
  File {
    owner    => $rgw_user,
    group    => $rgw_user,
  }

  ceph_conf {
    'client.radosgw.gateway/host':                             value => $rgw_host;
    'client.radosgw.gateway/keyring':                          value => $keyring_path;
    'client.radosgw.gateway/rgw_socket_path':                  value => $rgw_socket_path;
    'client.radosgw.gateway/log_file':                         value => $rgw_log_file;
    'client.radosgw.gateway/user':                             value => $rgw_user;
    'client.radosgw.gateway/rgw_data':                         value => $rgw_data;
    'client.radosgw.gateway/rgw_dns_name':                     value => $rgw_dns_name;
    'client.radosgw.gateway/rgw_print_continue':               value => $rgw_print_continue;
  }

  if ($use_ssl) {

    $httpd_ssl = $::ceph::params::dir_httpd_ssl
    exec {'copy OpenSSL certificates':
      command => "scp -r ${rgw_nss_db_path}/* ${::ceph::primary_mon}:${rgw_nss_db_path} && \
                  ssh ${::ceph::primary_mon} '/etc/init.d/radosgw restart'",
    }
    exec {"generate SSL certificate on ${name}":
      command => "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${httpd_ssl}apache.key -out ${httpd_ssl}apache.crt -subj '/C=RU/ST=Russia/L=Saratov/O=Mirantis/OU=CA/CN=localhost'",
      returns => [0,1],
    }
  }

  if ($rgw_use_keystone) {

    ceph_conf {
      'client.radosgw.gateway/rgw_keystone_url':                 value => $rgw_keystone_url;
      'client.radosgw.gateway/rgw_keystone_admin_token':         value => $rgw_keystone_admin_token;
      'client.radosgw.gateway/rgw_keystone_accepted_roles':      value => $rgw_keystone_accepted_roles;
      'client.radosgw.gateway/rgw_keystone_token_cache_size':    value => $rgw_keystone_token_cache_size;
      'client.radosgw.gateway/rgw_keystone_revocation_interval': value => $rgw_keystone_revocation_interval;
    }

    if ($rgw_use_pki) {

      ceph_conf {
      'client.radosgw.gateway/nss db path':                      value => $rgw_nss_db_path;
      }

      # This creates the signing certs used by radosgw to check cert revocation
      #   status from keystone
      exec {'create nss db signing certs':
        command => "openssl x509 -in /etc/keystone/ssl/certs/ca.pem -pubkey | \
          certutil -d ${rgw_nss_db_path} -A -n ca -t 'TCu,Cu,Tuw' && \ 
          openssl x509 -in /etc/keystone/ssl/certs/signing_cert.pem -pubkey | \
          certutil -A -d ${rgw_nss_db_path} -n signing_cert -t 'P,P,P'",
        user    => $rgw_user,
      }

      Exec["ceph-create-radosgw-keyring-on ${name}"] ->
      Exec['create nss db signing certs'] ~>
      Service['radosgw']

    } #END rgw_use_pki

  class {'ceph::keystone': }

  } #END rgw_use_keystone

  if ($::osfamily == 'Debian'){
    #a2mod is provided by horizon module
    a2mod { ['rewrite', 'fastcgi']: 
      ensure => present,
    }

    file {'/etc/apache2/sites-enabled/rgw.conf':
      ensure => link,
      target => "${::ceph::params::dir_httpd_sites}/rgw.conf",
      notify => Service['httpd'],
    }

    Package[$::ceph::params::package_fastcgi] ->
    File["${::ceph::params::dir_httpd_sites}/rgw.conf"] ->
    File['/etc/apache2/sites-enabled/rgw.conf'] ->
    A2mod[['rewrite', 'fastcgi']] ~>
    Service['httpd']

  } #END osfamily Debian

  file {$rgw_log_file:
    ensure => present,
    mode   => '0755'
  }

  file {[$::ceph::params::dir_httpd_ssl,
         "${::ceph::rgw_data}/ceph-radosgw.gateway",
         $::ceph::rgw_data,
         $dir_httpd_root,
         $rgw_nss_db_path,
        ]:
    ensure  => 'directory',
    mode    => '0755',
    recurse => true,
  }

  file { "${::ceph::params::dir_httpd_sites}/rgw.conf":
    content => template('ceph/rgw.conf.erb'),
  }

  file { "${dir_httpd_root}/s3gw.fcgi":
    content => template('ceph/s3gw.fcgi.erb'),
    mode    => '0755',
  }

  file {"${::ceph::params::dir_httpd_sites}/fastcgi.conf":
    content => template('ceph/fastcgi.conf.erb'),
    mode    => '0755',
    }

  exec { "ceph-create-radosgw-keyring-on ${name}":
    command => "ceph-authtool --create-keyring ${keyring_path}",
    creates => $keyring_path,
  }

  file { $keyring_path: mode => '0640', }

  exec { "ceph-generate-key-on ${name}":
    command => "ceph-authtool ${keyring_path} -n ${radosgw_auth_key} --gen-key",
  }

  exec { "ceph-add-capabilities-to-the-key-on ${name}":
    command => "ceph-authtool -n ${radosgw_auth_key} --cap osd 'allow rwx' --cap mon 'allow rw' ${keyring_path}",
  }

  exec { "ceph-add-to-ceph-keyring-entries-on ${name}":
    command => "ceph -k /etc/ceph/ceph.client.admin.keyring auth add ${radosgw_auth_key} -i ${keyring_path}",
  }

  Ceph_conf <||> ->
  Package[$::ceph::params::package_httpd] ->
  Package[[$::ceph::params::package_radosgw,
           $::ceph::params::package_fastcgi,
           $::ceph::params::package_libnss,]] ->
  File[["${::ceph::params::dir_httpd_sites}/rgw.conf",
        "${::ceph::params::dir_httpd_sites}/fastcgi.conf",
        "${dir_httpd_root}/s3gw.fcgi",
        $::ceph::params::dir_httpd_ssl,
        "${::ceph::rgw_data}/ceph-radosgw.gateway",
        $::ceph::rgw_data,
        $dir_httpd_root,
        $rgw_nss_db_path,
        $rgw_log_file,]] ->
  Exec["ceph-create-radosgw-keyring-on ${name}"] ->
  File[$keyring_path] ->
  Exec["ceph-generate-key-on ${name}"] ->
  Exec["ceph-add-capabilities-to-the-key-on ${name}"] ->
  Exec["ceph-add-to-ceph-keyring-entries-on ${name}"] ~>
  Service ['httpd'] ~>
  Service['radosgw']
}
