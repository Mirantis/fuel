define ceph::osd::deploy (
    $osd_id,
) {
    

    ceph::conf::osd { $osd_id:
        device  => $name,
        cluster_addr    => $ipaddress_br-mgmt,
        public_addr     => $ipaddress_br-ex,
    }
    ceph::osd::device { $name:
        osd_id => $osd_id,
    }

}