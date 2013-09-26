class osnailyfacter::node_netconfig (
  $mgmt_ipaddr,
  $mgmt_netmask = '255.255.255.0',
  $public_ipaddr = undef,
  $public_netmask = '255.255.255.0',
  $save_default_gateway = false,
  $default_gateway
) {
  
  if $::use_quantum {
    # quantum mode
    l23network::l3::create_br_iface { 'mgmt' :
      interface       => $::fuel_settings['management_interface'], # !!! NO $internal_int /sv !!!
      bridge          => $internal_br,
      ipaddr          => $mgmt_ipaddr,
      netmask         => $mgmt_netmask,
      dns_nameservers => $::dns_nameservers,
      gateway         => $default_gateway,
    } ->
    l23network::l3::create_br_iface { 'ex' :
      interface => $::fuel_settings['public_interface'], # !! NO $public_int /sv !!!
      bridge    => $::public_br,
      ipaddr    => $::public_ipaddr,
      netmask   => $public_netmask,
      gateway   => $default_gateway,
    }
  } else {
    # nova-network mode
    l23network::l3::ifconfig { $::public_int :
      ipaddr  => $public_ipaddr,
      netmask => $public_netmask,
      gateway => $default_gateway,
    }
    l23network::l3::ifconfig { $::internal_int :
      ipaddr          => $mgmt_ipaddr,
      netmask         => $mgmt_netmask,
      dns_nameservers => $::dns_nameservers,
      gateway         => $default_gateway,
    }
  }

  l23network::l3::ifconfig {$::fuel_settings['fixed_interface']:
    ipaddr => 'none',
  }

}
