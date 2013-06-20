define ceph::rolemds 
(
  $auth_type = 'cephx',
  $mds_data = '/var/lib/ceph/mds'
) {
  ceph::mds { $name:
     fsid => $::fsid,
     auth_type => 'cephx',
     mds_data => '/var/lib/ceph/mds',
  }
}
                                     
