define ceph::osd::deploy_array (
    $osd_id,
    $osd_fs = 'xfs',
    $cluster_addr = '0.0.0.0',
    $public_addr = '0.0.0.0',
    $raid = undef,
    $osd_dev,
    $parted_disk = true,
) {
    ceph::osd::device_array { $name:
        osd_fs => $osd_fs,
        raid => undef,
        osd_dev => $osd_dev,
        cluster_addr => $cluster_addr,
        public_addr => $public_addr,
        parted_disk => $parted_disk,
    }
}
