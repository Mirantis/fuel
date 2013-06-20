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
	command => "dd if=/dev/zero of=${name} count=1k bs=1k ; parted -s ${name} mklabel gpt",
	unless  => "ceph osd dump | grep `/sbin/blkid ${name}1 -o value -s UUID`",
#       unless  => "parted --script ${name} print|grep -sq 'gpt'",
#	unless  => "parted --script ${name} print|grep -sq 'Partition Table: gpt'",
        require => Package['parted']
      }

      exec { "mkpart_${name}":
        command => "parted -a optimal -s ${name} mkpart ceph 0% 100%",
        unless  => "parted ${name} print | egrep '^ 1.*ceph$'",
        require => [Package['parted'], Exec["mktable_gpt_${name}"]]
      }
   }
   define mk_btrfs ($parted = true) {
	if !$parted {
	    exec { "clean_step1_${name}":
		command => "dd if=/dev/zero of=${name} count=1k bs=1k ; mkfs.btrfs ${name}",
		unless  => "/sbin/blkid ${name} -o value -s UUID",
		require => Package['btrfs-tools'],
	    }
	    exec { "clean_step2_${name}":
		command => "dd if=/dev/zero of=${name} count=1k bs=1k ; mkfs.btrfs ${name}",
		unless  => "ceph osd dump | grep `/sbin/blkid ${name} -o value -s UUID`",
		require => Exec["clean_step1_${name}"],
	    }
	}
	exec { "mk_btrfs_${name}":
	    command => "mkfs.btrfs ${name}",
	    unless  => "btrfs-show | grep ${name}",
	    require => Package['btrfs-tools'],
	}
   }
    define mk_xfs ($parted = true) {
	if !$parted {
	    exec { "clean_step1_${name}":
		command => "dd if=/dev/zero of=${name} count=1k bs=1k ; mkfs.xfs -f -d agcount=${::processorcount} -l size=1024m -n size=64k ${name}",
		unless  => "/sbin/blkid ${name} -o value -s UUID",
		require => Package['xfsprogs'],
	    }
	    exec { "clean_step2_${name}":
		command => "dd if=/dev/zero of=${name} count=1k bs=1k ; mkfs.xfs -f -d agcount=${::processorcount} -l size=1024m -n size=64k ${name}",
		unless  => "ceph osd dump | grep `/sbin/blkid ${name} -o value -s UUID`",
		require => Exec["clean_step1_${name}"],
	    }
	}
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
	$dev_arr = join($osd_dev,"\ ")
	exec { "mk_btr raid ${raid_level}":
	    command => "mkfs.btrfs -m raid${raid_level} ${dev_arr}",
	    unless  => "btrfs-show | grep \"Total devices ${$dev_count}\"",
	    require => Package['btrfs-tools'],
	}
    }
    define mk_sing_osd ($osd_hash, $osd_fs, $public_addr, $cluster_addr) {
	file { "osd_dep${name}.sh":
	    content => template("ceph/osd_dep.sh.erb"),
	    path => "/tmp/osd_dep${name}.sh",
	    mode => 0700,
	    owner => 'root',
	}
	exec {"/tmp/osd_dep${name}.sh ${osd_hash[$name]} /var/lib/ceph/osd/ $cluster_addr $public_addr $osd_fs": }
    }

define ceph::osd::device_array (
    $osd_fs = 'xfs',
    $raid = undef,
    $osd_dev,
    $public_addr,
    $cluster_addr,
    $parted_disk,
) {

  include ceph::osd
  include ceph::conf
    $osds_id = range("0",size($osd_dev)-1)
    $osd_devs = suffix($osd_dev,"1")
    if $raid == undef {
	if $parted_disk {
	    if $osd_fs != 'btrfs' {
		parted_disk { $osd_dev: } -> mk_xfs { $osd_devs: } -> mk_sing_osd{ $osds_id: osd_hash => $osd_devs, osd_fs => $osd_fs, public_addr => $public_addr, cluster_addr => $cluster_addr }
	    } else {
		parted_disk { $osd_dev: } -> mk_btrfs { $osd_devs: } -> mk_sing_osd{ $osds_id: osd_hash => $osd_devs, osd_fs => $osd_fs, public_addr => $public_addr, cluster_addr => $cluster_addr }
	    }
	} else {
	    if $osd_fs != 'btrfs' {
		mk_xfs { $osd_dev: parted => $parted_disk  } -> mk_sing_osd{ $osds_id: osd_hash => $osd_dev, osd_fs => $osd_fs, public_addr => $public_addr, cluster_addr => $cluster_addr }
	    } else {
		mk_btrfs { $osd_dev: parted => $parted_disk } -> mk_sing_osd{ $osds_id: osd_hash => $osd_dev, osd_fs => $osd_fs, public_addr => $public_addr, cluster_addr => $cluster_addr }
	    }
	}
    } else {
	if $osd_fs != 'btrfs' {
	    parted_disk { $osd_dev: } -> mk_md{ "mk raid ${raid}": raid_level => $raid, osd_dev => $osd_devs} -> mk_xfs{ "/dev/md0":} -> mk_sing_osd{ "0": osd_hash => ["/dev/md0"], osd_fs => $osd_fs, public_addr => $public_addr, cluster_addr => $cluster_addr }
        } else {
    	   parted_disk { $osd_dev: } -> mk_btr_raid { "mk btrfs raid": raid_level => $raid, osd_dev => $osd_devs} -> mk_sing_osd{ "0": osd_hash => [$osd_sosd[0]], osd_fs => $osd_fs, public_addr => $public_addr, cluster_addr => $cluster_addr }
        }
    }
}
