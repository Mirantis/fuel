define ceph::empty 
(
  $auth_type = 'cephx',
  $osd_fs = 'xfs',
  $cluster_network = "${::network_eth0}/24",
  $public_network  = "${::network_eth0}/24",
  $osd_journal = undef,
) {


  class { 'ceph::conf':
      fsid            => $::fsid,
      auth_type       => $auth_type,
      cluster_network => $cluster_network,
      public_network  => $public_network,
      osd_fs => $osd_fs,
      osd_journal => $osd_journal,
    }
    ->
    Ceph::Key <<| title == "admin" |>>

}

