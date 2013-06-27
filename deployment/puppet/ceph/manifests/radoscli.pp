define ceph::radoscli (
    $keyring_path = "/etc/ceph/client.radosgw.gateway.keyring",
) {
    exec { "mk-kr":
	command => "ceph-authtool --create-keyring ${keyring_path}",
	creates => "${keyring_path}",
	require => Exec['ceph-admin-key'],
    }
    file { "${keyring_path}":
	mode => 644,
    }
        exec { "step1":
	    command => "ceph-authtool ${keyring_path} -n client.radosgw.gateway --gen-key",
	    require => Exec["mk-kr"],
	    unless => "cat ${keyring_path} | grep key",
        }
        exec { "step2":
	    command => "ceph-authtool -n client.radosgw.gateway --cap osd 'allow rwx' --cap mon 'allow r' ${keyring_path}",
	    require => Exec["step1"],
	    unless => "cat ${keyring_path} | grep osd",
        }
	exec { "step3":
	    command => "ceph auth add client.radosgw.gateway -i ${keyring_path}",
	    require => Exec["step2"],
	    unless => "/usr/bin/ceph auth get-key client.radosgw.gateway",
        }
}