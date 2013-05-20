define ceph::conf::client (
    $keyring_path = '/etc/ceph'
) {
  @@concat::fragment { "ceph-client-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '90',
    content => template('ceph/ceph.conf-client.erb'),
  }

}
