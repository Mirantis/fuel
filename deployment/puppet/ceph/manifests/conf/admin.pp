define ceph::conf::admin (
    $keyring_path = '/etc/ceph'
) {
  @@concat::fragment { "ceph-client-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '100',
    content => template('ceph/ceph.conf-admin.erb'),
  }

}
