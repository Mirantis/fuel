# == Define: l23network::l2::splinters
#
# Splinters will check if the passed interface(name) is known to possibly have
#  issues and will turn on splinters.
#
# This requires that $::use_vlan_splinters is true (defaults to false)
#
# ===Parameters
#
# [*interface*] (optional) the name of the interface to test, defaults to $name

#
define l23network::l2::splinters (
	$interface = $name
  ) {

  # This is a list of drivers that might need splinters to work with older kernels.
  # From http://openvswitch.org/cgi-bin/ovsman.cgi?page=utilities%2Fovs-vlan-bug-workaround.8.in

  $drivers = ['8139cp', 'acenic', 'amd8111e', 'atl1c', 'ATL1E', 'atl1', 'atl2',
              'be2net', 'bna', 'bnx2', 'bnx2x', 'cnic', 'cxgb', 'cxgb3',
              'e1000', 'e1000e', 'enic', 'forcedeth', 'igb', 'igbvf', 'ixgb',
              'ixgbe', 'jme', 'ml4x_core', 'ns83820', 'qlge', 'r8169', 'S2IO',
              'sky2', 'starfire', 'tehuti', 'tg3', 'typhoon', 'via-velocity',
              'vxge', 'gianfar', 'ehea', 'stmmac', 'vmxnet3']
  $grep_test = join($drivers, ' -e ')

  exec { "inspect interface and enable splinters on interface ${interface}":
          command   => "ovs-vsctl set interface ${interface} other-config:enable-vlan-splinters=true",
          logoutput => on_failure,
          onlyif    => "ethtool -i ${interface} | /bin/grep -q -e ${grep_test}",
          path      => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
          require   => Package[$::l23network::params::ovs_packages]
  }
}

