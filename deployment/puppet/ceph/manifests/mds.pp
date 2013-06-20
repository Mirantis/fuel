# Configure a ceph mds
#
# == Name
#   This resource's name is the mon's id and must be numeric.
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*auth_type*] Auth type.
#   Optional. undef or 'cephx'. Defaults to 'cephx'.
#
# [*mds_data*] Base path for mon data. Data will be put in a mon.$id folder.
#   Optional. Defaults to '/var/lib/ceph/mds.
#
# == Dependencies
#
# none
#
# == Authors
#
#  Sébastien Han sebastien.han@enovance.com
#  François Charlier francois.charlier@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#

define ceph::mds (
  $fsid,
  $auth_type = 'cephx',
  $mds_data = '/var/lib/ceph/mds',
) {

  include 'ceph::package'

  $mds_data_expanded = "${mds_data}/mds.${name}"

  file { $mds_data_expanded:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }

  exec { 'mk-mds-dir':
    command => "mkdir -p /var/lib/ceph/mds",
    creates => "/var/lib/ceph/mds",
  }
  exec { 'ceph-mds-keyring':
    command =>"ceph auth get-or-create mds.${name} mds 'allow ' osd 'allow *' mon 'allow rwx' -o /var/lib/ceph/mds/mds.${name}/keyring",
    creates => "/var/lib/ceph/mds/mds.${name}/keyring",
#    before => Service['ceph-mds.${name}'],
    require => [Package['ceph'], Exec['mk-mds-dir']]
  }

  service { "ceph-mds.${name}":
    ensure  => running,
    start   => "/etc/init.d/ceph start mds.${name}",
    stop    => "/etc/init.d/ceph stop mds.${name}",
    status  => "/etc/init.d/ceph status mds.${name}",
    binary  => "/etc/init.d/ceph",
    provider => base,
    require => Exec['ceph-mds-keyring'],
 }
  ceph::conf::mds { $name:
    mds_data => $mds_data
  }
}