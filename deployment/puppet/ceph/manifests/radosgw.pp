define ceph::radosgw (
    $datadir = "/var/lib/ceph/rados",
    $keyring_path = "/etc/ceph/client.radosgw.gateway.keyring",
    $use_keystone = "false",
    $keystone_url = "127.0.0.1:5000",
    $keystone_admin_key = "",
    $roles = "admin, SwiftOperator",
    $nss_db_path = "/tmp/nss.db",
) {
    case $::operatingsystem {
        'ubuntu', 'debian': {
#            package { 'apache2' : ensure => "installed" }
            package { 'libapache2-mod-fastcgi': ensure => "installed", require => Package['apache2'] }
            package { "radosgw": ensure => "installed", require => Package['apache2'] }
            exec { "enable mods":
        	command => "sudo a2enmod rewrite ; sudo a2enmod fastcgi",
            }
            file { "/etc/apache2/sites-enabled/rgw.conf":
        	content => template('ceph/rgw.conf.erb'),
    	    }
    	    $apache_user = 'www-data'
        }
        'centos','redhat': {
#    	    package { "httpd": ensure => "installed" }
    	    package { "ceph-radosgw": ensure => "installed", require => Package['httpd'] }
    	    package { "mod_ssl": ensure => "installed", require => Package['httpd'] }
    	    file { "/etc/httpd/conf.d/rgw.conf":
    		ontent => template('ceph/rgw.conf.erb'),
    	    }
    	    $apache_user = 'apache'
        }
    }

    concat::fragment { "ceph-radosgw.conf":
	target  => '/etc/ceph/ceph.conf',
	order   => '110',
	content => template('ceph/ceph.conf-radosgw.erb'),
    }
    file { "${datadir}":
        ensure => "directory",
        mode   => 755,
    }
    file { "/var/www/s3gw.fcgi":
        content => template('ceph/s3gw.fcgi.erb'),
    }
    ceph::radoscli { 'add gw user': 
	keyring_path => $keyring_path,
    }
    case $::operatingsystem {
	'ubuntu', 'debian': {
	    service { "radosgw":
		ensure => "running",
		require => [File["${datadir}"],Concat::Fragment["ceph-radosgw.conf"],File['/var/www/s3gw.fcgi'],Ceph::Radoscli['add gw user']],
	    }
#	    service { 'apache2':
#		ensure => "running",
#		require => [Package['apache2'],Package['libapache2-mod-fastcgi'],Package['radosgw'],Exec['nable mods'],Service['radosgw']],
#	    }
	}
	'centos','redhat': {
	    service { "ceph-radosgw":
		ensure => "running",
		require => [File["${datadir}"],Concat::Fragment["ceph-radosgw.conf"],File['/var/www/s3gw.fcgi'],Ceph::Radoscli['add gw user']],
	    }
	    service { "httpd":
		ensure => "running",
		require => [Package['httpd'],Package['ceph-radosgw'],Package['mod_ssl']],
	    }
	}
    }
}
