define ceph::conf::osd_array (
  $device,
  $cluster_addr,
  $public_addr,
  $raid = undef,
  $osd_fs = 'xfs',
) {

    $osds_id = range("0", size($device)-1)
    if $raid == undef {
	inc::osd_concat { $osds_id: device => suffix($device,"1"), cluster_addr => $cluster_addr, public_addr => $public_addr, osd_id => $name}
    } else {
	if $osd_fs != "btrfs" {
	    inc::osd_concat { $osd_id: device => ["/dev/md0"], cluster_addr => $cluster_addr, public_addr => $public_addr, osd_id => $name}
	} else {
	    $devs = suffix($device,"1")
	    inc::osd_concat { $osds_id: device => [$devs[0]], cluster_addr => $cluster_addr, public_addr => $public_addr, osd_id => $name}
	}
    }

}
