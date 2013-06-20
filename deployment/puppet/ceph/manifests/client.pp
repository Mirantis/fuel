define ceph::client (
  $keyring_path = "/etc/ceph/client.${name}.keyring",
  $pool2 = 'none',
  $create_pool = 'no',
  $pg_num = '128',
  $replicas = "3",
  $primary_node,
) {
if $primary_node {
    if $pool2 == 'none' {
	    exec { "ceph-permissions-set-${name}":
		command => "ceph auth get-or-create client.${name} mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=${name}'",
    		require => Package['ceph'],
    		creates => "/etc/ceph/client.${name}.keyring",
	    }
	    ->
	    Exec  <<| tag == "ceph-key-${name}" |>>
	  @@exec { "ceph-key-${name}":
	    command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key=`/usr/bin/ceph auth get-key client.${name}`",
	    creates => $keyring_path,
#	    require => Exec["ceph-permissions-set-${name}"]
	  }
    } else {
            exec { "ceph-permissions-set-${name}":
                command => "ceph auth get-or-create client.${name} mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=${name}, allow rx pool=${pool2}'",
                require => Package['ceph'],
                creates => "/etc/ceph/client.${name}.keyring",
            }
            ->
            Exec  <<| tag == "ceph-key-${name}" |>>
            @@exec { "ceph-key-${name}":
        	command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key=`/usr/bin/ceph auth get-key client.${name}`",
        	creates => $keyring_path,
#        	require => Exec["ceph-permissions-set-${name}"]
    	    }
    	    
    }
    if $create_pool == 'yes' {
	exec { "ceph-pool-create-${name}":
	    command => "ceph osd pool create ${name} ${pg_num}",
	    require => Package['ceph'],
	}
	exec { "ceph-pool-set-replicas-${name}":
	    command => "ceph osd pool set ${name} size ${replicas}",
	    require => [Package['ceph'],Exec["ceph-pool-create-${name}"]],
	}
    }
} else {
	Exec  <<| tag == "ceph-key-${name}" |>>
}
}
