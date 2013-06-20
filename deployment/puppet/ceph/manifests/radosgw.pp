class ceph::radosgw (
    $datadir = "/var/lib/ceph/rados",
    $use_keystone = "false",
    $keystone_url = "127.0.0.1:5000",
    $keystone_admin_key = "",
    $roles = "admin, SwiftOperator",
    $nss_db_path = "/tmp/nss.db",
) {
    package { "httpd":
        ensure => "installed"
    }
#    package { "mod_fastcgi":
#	ensure => "installed"
#    }
    package { "ceph-radosgw":
	ensure => "installed"
    }
    package { "mod_ssl":
	ensure => "installed"
    }
    service { "httpd":
	ensure => "running",
	require => [Package['httpd'],Package['ceph-radosgw'],Package['mod_ssl']],
    }
    
    @@concat::fragment { "ceph-radosgw.conf":
	target  => '/etc/ceph/ceph.conf',
	order   => '110',
	content => template('ceph/ceph.conf-radosgw.erb'),
    }
    file { "${datadir}":
        ensure => "directory",
        mode   => 755,
    }
    file { "/etc/httpd/conf.d/rgw.conf":
        content => template('ceph/rgw.conf.erb'),
    }
    file { "/var/www/s3gw.fcgi":
        content => template('ceph/s3gw.fcgi.erb'),
    }
    service { "ceph-radosgw":
	ensure => "running",
	require => [Service["httpd"]],
    }
                    
}
