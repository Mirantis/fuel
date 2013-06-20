define ceph::clientkey (
  $keyring_path = "/etc/ceph/client.${name}.keyring",
) {

  exec { "ceph-client-key-gen-${name}":
      command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --gen-key",
      creates => $keyring_path,
      require => Package['ceph'],
    }
}
