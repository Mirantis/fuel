define inc::osd_concat ($device, $cluster_addr, $public_addr,$osd_id) {
    $device_sing = $device[$name]
    concat::fragment { "ceph-osd-${osd_id}${name}.conf":
        target  => '/etc/ceph/ceph.conf',
        order   => '80',
        content => template('ceph/ceph.conf-osd-array.erb'),
    }
}

