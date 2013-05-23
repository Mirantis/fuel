define ceph::osd::deploy (
    $osd_id,
) {
    

    ceph::conf::osd { $osd_id:
        device  => $name,
        cluster_addr    => $ipaddress_eth0,
        public_addr     => $ipaddress_eth0,
    }
    ceph::osd::device { $name:
        osd_id => $osd_id,
    }

}