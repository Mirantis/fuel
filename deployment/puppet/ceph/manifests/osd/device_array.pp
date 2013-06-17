# Configure a ceph osd device
#
# == Namevar
# the resource name is the full path to the device to be used.
#
# == Dependencies
#
# none
#
# == Authors
#
#  François Charlier francois.charlier@enovance.com
#
# == Copyright
#
# Copyright 2013 eNovance <licensing@enovance.com>
#

  define parted_disk {
      exec { "mktable_gpt_${name}":
	command => "parted -a optimal --script ${name} mktable gpt",
        unless  => "parted --script ${name} print|grep -sq 'gpt'",
#	unless  => "parted --script ${name} print|grep -sq 'Partition Table: gpt'",
        require => Package['parted']
      }

      exec { "mkpart_${name}":
        command => "parted -a optimal -s ${name} mkpart ceph 0% 100%",
        unless  => "parted ${name} print | egrep '^ 1.*ceph$'",
        require => [Package['parted'], Exec["mktable_gpt_${name}"]]
      }
   }
   define mk_btrfs {
	exec { "mk_btrfs_${name}1":
	    command => "mkfs.btrfs ${name}1",
	    unless  => "btrfs-show | grep ${name}1",
	    require => Package['btrfs-tools'],
	}
   }
    define mk_xfs {
	exec { "mk_xfs_${name}":
	    command => "mkfs.xfs -f -d agcount=${::processorcount} -l size=1024m -n size=64k ${name}",
	    unless  => "xfs_admin -l ${name}",
	    require => Package['xfsprogs'],
	}
    }
    define mk_md ($raid_level,$osd_dev) {
	$dev_count = size($osd_dev)
	$dev_arr = join($osd_dev,"\ ")
	exec { "mk_md raid ${raid_level}":
	    command => "mdadm --create --verbose /dev/md0 --level=raid${raid_level} --raid-devices=${dev_count} ${dev_arr}",
	    unless  => "mdadm --detail /dev/md0 | grep raid",
	    require => Package['mdadm'],
	}
    }
    define mk_btr_raid ($raid_level,$osd_dev) {
	$dev_count = size($osd_dev)
	$dev_arr = join($osd_dev," ")
	exec { "mk_btr raid ${raid_level}":
	    command => "mkfs.btrfs -m raid${raid_level} ${dev_arr}",
	    unless  => "btrfs-show | grep \"Total devices ${$dev_count}\"",
	    require => Package['btrfs-tools'],
	}
    }
    define mk_sing_osd ($osd_hash, $osd_fs, $public_addr, $cluster_addr) {
#	$blkid_uuid_fact = "blkid_uuid_${osd_hash[$name]}"
#        notify { "BLKID FACT ${osd_hash[$name]}: ${blkid_uuid_fact}": }
#        $blkid = inline_template('<%= scope.lookupvar(blkid_uuid_fact) %>')
	$blkid = ceph_get_osd_uuid("${osd_hash[$name]}")
        notify { "BLKID ${$osd_hash[$name]}: ${blkid}": }

#	exec { "ceph_osd_create_${osd_hash[$name]}":
#	    command => "ceph osd create ${blkid}",
#	    unless  => "ceph osd dump | grep -sq ${blkid}",
#	    require => Ceph::Key['admin'],
#	}
#        $osd_id_fact = "ceph_osd_id_${devname}1"
#        notify { "OSD ID FACT ${osd_hash[$name]}: ${osd_id_fact}": }
#	$osd_id = inline_template('<%= scope.lookupvar(osd_id_fact) %>')
	$osd_id = ceph_get_osd_id("${blkid}")
        notify { "OSD ID ${osd_hash[$name]}: ${osd_id}":}
	$osd_data = regsubst($::ceph::conf::osd_data, '\$id', "${osd_id}")
	file { $osd_data:
	    ensure => directory,
	}
	if $osd_fs != 'btrfs' {
    	    mount { $osd_data:
    		ensure  => mounted,
    		device  => $osd_hash[$name],
    		atboot  => true,
    		fstype  => $osd_fs,
    		options => 'rw,noatime,inode64',
    		pass    => 2,
    		require => File[$osd_data],
    	    }
        } else {
    	    mount { $osd_data:
        	ensure  => mounted,
        	device  => $osd_hash[$name],
        	atboot  => true,
        	fstype  => $osd_fs,
        	options => 'rw,noatime',
        	pass    => 2,
        	require => File[$osd_data],
    	    }
        }
        exec { "ceph-osd-mkfs-${osd_id}":
    	    command => "ceph-osd -c /etc/ceph/ceph.conf -i ${osd_id} --mkfs --mkkey --osd-uuid ${blkid}",
    	    creates => "${osd_data}/keyring",
    	    require => [
            Mount[$osd_data],
            Concat['/etc/ceph/ceph.conf'],
            ],
        }
	ceph::conf::osd { $osd_id:
	    device  => $osd_hash[$name],
	    cluster_addr    => $cluster_addr,
	    public_addr     => $public_addr,
	}

        exec { "ceph-osd-register-${osd_id}":
    	    command => "ceph auth add osd.${osd_id} osd 'allow *' mon 'allow rwx' -i ${osd_data}/keyring",
	    require => Exec["ceph-osd-mkfs-${osd_id}"],
	}
        exec { "ceph-osd-crush-${osd_id}":
    	    command => "ceph osd crush set ${osd_id} 1 root=default host=${::hostname}",
    	    require => Exec["ceph-osd-register-${osd_id}"],
        }

	service { "ceph-osd.${osd_id}":
    	    ensure    => running,
	    start     => "/etc/init.d/ceph start osd.${osd_id}",
	    stop      => "/etc/init.d/ceph stop osd.${osd_id}",
            status    => "/etc/init.d/ceph status osd.${osd_id}",
            binary    => "/etc/init.d/ceph",
            provider => base,
            require   => Exec["ceph-osd-crush-${osd_id}"],
            subscribe => Concat['/etc/ceph/ceph.conf'],
      }
    }

define ceph::osd::device_array (
    $osd_fs = 'xfs',
    $raid = undef,
    $osd_dev,
    $public_addr,
    $cluster_addr,
) {

  include ceph::osd
  include ceph::conf
    
    if $osd_fs != 'btrfs' {
	if $raid == undef {
	    $osd_devs = suffix($osd_dev,"1")
	    $osds_id = size($osd_dev)-1
	    parted_disk { $osd_dev: } -> mk_xfs { $osd_devs: } -> mk_sing_osd{ $osds_id: osd_hash => $osd_devs, osd_fs => $osd_fs, public_addr => $public_addr, cluster_addr => $cluster_addr }
	} else { 
	    parted_disk { $osd_dev: } -> mk_md{ "mk raid ${raid}": raid_level => $raid, osd_dev => suffix($osd_dev,"1")} -> mk_xfs{ "/dev/md0":} -> mk_sing_osd{ "0": osd_hash => ["/dev/md0"], osd_fs => $osd_fs }
	}
     } else {
        if $raid == undef {
    	    $osds_id = size($osd_dev)-1
    	    parted_disk { $osd_dev: } -> mk_btrfs { $osd_dev: } -> mk_sing_osd{ $osds_id: osd_hash => $osds_id, osd_fs => $osd_fs, public_addr => $public_addr, cluster_addr => $cluster_addr }
        } else {
    	   $osd_sosd = suffix($osd_dev,"1")
    	   parted_disk { $osd_dev: } -> mk_btr_raid { "mk btrfs raid": raid_level => $raid, osd_dev => $osd_sosd} -> mk_sing_osd{ "0": osd_hash => [$osd_sosd[0]], osd_fs => $osd_fs, public_addr => $public_addr, cluster_addr => $cluster_addr }
        }
     }
}
