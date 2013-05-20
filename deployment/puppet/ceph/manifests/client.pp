define ceph::client (
  $keyring_path = "/etc/ceph/client.${name}.keyring",
  $pool2 = 'none',
  $create_pool = 'no',
) {
    if $pool2 == 'none' {
	if !ceph_key_get($name) {
	    exec { "ceph-permissions-set-${name}":
		command => "ceph auth get-or-create client.${name} mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=${name}'",
    		require => Package['ceph'],
	    }
	} else  {
	    $cli_key = ceph_key_get($name)
	    notify { "USER_ID: $cli_key": }
	    @@ceph::key{ $name:
		secret => $cli_key,
		keyring_path => $keyring_path,
	    }
	    Ceph::Key <<| title == $name |>>
	    
	}
    } else {
        if !ceph_key_get($name) {
            exec { "ceph-permissions-set-${name}":
                command => "ceph auth get-or-create client.${name} mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=${name}, allow rx pool=${pool2}'",
                require => Package['ceph'],
            }
        } else {
            $cli_key = ceph_key_get($name)
            notify { "USER_ID: $cli_key": }
            @@ceph::key{ $name:
                secret => $cli_key,
                keyring_path => $keyring_path,
            }
            Ceph::Key <<| title == $name |>>
	}
    }
    if $create_pool == 'yes' {
	exec { "ceph-pool-create-${name}":
	    command => "ceph osd pool create ${name} 128",
	    require => Package['ceph'],
	}
    }
    
    ceph::conf::client { $name: }
}
