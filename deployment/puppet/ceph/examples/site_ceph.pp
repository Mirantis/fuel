$fsid = '07d28faa-48ae-4356-a8e3-19d5b81e159e'
$mon_secret = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
$keystone_admin_token    = 'nova'


Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
}

class role_ceph (
  $fsid,
  $auth_type = 'cephx'
) {

  class { 'ceph::conf':
    fsid            => $fsid,
    auth_type       => $auth_type,
    cluster_network => "${::network_eth0}/24",
    public_network  => "${::network_eth0}/24"
    ssh_private_key        => 'puppet:///ssh_keys/openstack',
    ssh_public_key         => 'puppet:///ssh_keys/openstack.pub',
            
  }

  include ceph::apt::ceph

}

class role_ceph_mon (
  $id
) {

  class { 'role_ceph':
    fsid           => $::fsid,
    auth_type      => 'cephx',
  }

  ceph::mon { $id:
    monitor_secret => $mon_secret,
    mon_port       => 6789,
    mon_addr       => $ipaddress_eth0,
  }

}

class role_mds (
    $id
) {
     ceph::mds { $id:
        fsid => $fsid,
        auth_type => 'cephx',
        mds_data => '/var/lib/ceph/mds',
    }
}

class ceph_client_add (
  $name,
  $create_pool ='no',
) {

  ceph::client { $name:
    create_pool => $create_pool,
  }

}


node 'ceph1' {
    if !empty($::ceph_admin_key) {
      @@ceph::key { 'admin':
        secret       => $::ceph_admin_key,
        keyring_path => '/etc/ceph/keyring',
      }
    }
    class { 'role_ceph_mon': id => 0}
    class { 'role_mds': id => 0}
    ceph::osd::deploy { '/dev/sdc': 
	osd_id	=> '0',
    }
    ceph::osd::deploy { '/dev/sdb':
	osd_id	=> '1',
    }
                                 
#    class { 'ceph_client_add': 
#	name => 'images',
#	create_pool => 'yes',
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
