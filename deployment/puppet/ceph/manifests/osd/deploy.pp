define ceph::osd::deploy (
    $osd_id,
    $osd_fs = 'xfs',
    $cluster_addr = '0.0.0.0',
    $public_addr = '0.0.0.0',
) {
    ceph::conf::osd { $osd_id:
        device  => "${name}1",
        cluster_addr    => $cluster_addr,
        public_addr     => $public_addr,
    }
    ceph::osd::device { $name:
        osd_id => $osd_id,
        osd_fs => $osd_fs,
    }
}