define ceph::rolemon 
(
  $auth_type = 'cephx',
  $mon_secret,
  $mon_addr = $ipaddress_eth0,
  $osd_fs = 'xfs',
  $cluster_network = "${::network_eth0}/24",
  $public_network  = "${::network_eth0}/24",
  $ssh_private_key = undef,
  $ssh_public_key = undef,
  $osd_journal = undef,
) {


  class { 'ceph::conf':
      fsid            => $::fsid,
      auth_type       => $auth_type,
      cluster_network => $cluster_network,
      public_network  => $public_network,
      ssh_private_key        => $ssh_private_key,
      ssh_public_key         => $ssh_public_key,
      osd_fs => $osd_fs,
      osd_journal => $osd_journal,
    }

  ceph::mon { $name:
    monitor_secret => $mon_secret,
    mon_port       => 6789,
    mon_addr       => $mon_addr,
  }

}

