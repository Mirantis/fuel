$mon_secret = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
$keystone_admin_token    = 'nova'


Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
}



node 'ceph1' {
    if !empty($::ceph_admin_key) {
      @@ceph::key { 'admin':
        secret       => $::ceph_admin_key,
        keyring_path => '/etc/ceph/keyring',
      }
    }
    ceph::relo_mon {'0':
	mon_secret => $mon_secret
    }
    ceph::relo_mds { '0': }
    ceph::osd::deploy { '/dev/sdc': 
	osd_id	=> '0',
    }
    ceph::osd::deploy { '/dev/sdb':
	osd_id	=> '1',
    }
                                 
#    ceph::client { 'images':
#	create_pool => 'yes',
#	pool2 => 'images',
#    }
#    ceph::client { 'volumes':
#      create_pool => 'yes',
#      pool2 => 'images',
#    }
#    ceph::conf::admin { 'admin': }
#    class { 'ceph::radosgw': 
#	use_keystone => "true",
#	keystone_url => "192.168.122.206:5000",
#	keystone_admin_key => $keystone_admin_token,
#    }
#    class { 'ceph::radoscli': }
}


node 'ceph03' {
    class { 'role_ceph_mon': id => 1}
 class { 'ceph::osd' :
        public_address  => $ipaddress_eth0,
        cluster_address => $ipaddress_eth0,
    }
    ceph::conf::osd { '2':
	device	=> '/dev/sdc',
	cluster_addr	=> $ipaddress_eth0,
	public_addr	=> $ipaddress_eth0,
    }    
ceph::osd::device { '/dev/sdc': }    
    ceph::conf::osd { '4':
	device	=> '/dev/sdb',
	cluster_addr	=> $ipaddress_eth0,
	public_addr	=> $ipaddress_eth0,
    }
    ceph::osd::device { '/dev/sdb': }
    class { 'role_mds': id => 1}
#    Ceph::Key <<| title == 'image8' |>>
}

node 'ceph02' {
    class { 'role_ceph_mon': id => 3}
    class { 'role_mds': id => 3}
}
