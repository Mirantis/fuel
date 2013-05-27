class ceph::apt::ceph (
  $release = 'cuttlefish'
) {
        Yumrepo {
          failovermethod => 'priority',
          gpgkey         => 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6',
          gpgcheck       => 1,
          enabled        => 1,
        }
        yumrepo { 'epel':
          descr      => 'Extra Packages for Enterprise Linux 6 - $basearch',
          mirrorlist => 'http://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
        }
       yumrepo { 'ceph':
          baseurl       => 'http://ceph.com/rpms/el6/$basearch',
          enabled       => 1,
          gpgcheck      => 1,
          gpgkey        => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc'
        }

}
