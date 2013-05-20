class ceph::radoscli (
    $keyring_path = "/etc/ceph/keyring.radosgw.gateway",
) {
    exec { "mk-kr":
	command => "ceph-authtool --create-keyring ${keyring_path}",
	creates => "${keyring_path}",
    }
    file { "${keyring_path}":
	mode => 644,
    }
    if !ceph_key_get('radosgw.gateway') {
        exec { "step1":
	    command => "ceph-authtool ${keyring_path} -n client.radosgw.gateway --gen-key",
	    require => Exec["mk-kr"],
        }
        exec { "step2":
	    command => "ceph-authtool -n client.radosgw.gateway --cap osd 'allow rwx' --cap mon 'allow r' ${keyring_path}",
	    require => Exec["step1"],
        }
	exec { "step3":
	    command => "ceph auth add client.radosgw.gateway -i ${keyring_path}",
	    require => Exec["step2"],
        }
    } else {
	$cli_key = ceph_key_get('radosgw.gateway')
        @@ceph::key{ 'radosgw.gateway':
            secret => $cli_key,
            keyring_path => '/etc/ceph/keyring.radosgw.gateway2',
        }
        Ceph::Key <<| title == 'radosgw.gateway' |>>
    }
}