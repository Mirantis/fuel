class quantum::network::predefined_netwoks (
  $quantum_config     = {},
) {

#      if $tenant_network_type == 'gre' {
#        $internal_physical_network = undef
#        $external_physical_network = undef
#        $external_network_type = $tenant_network_type
#        $external_segment_id = $segment_id + 1
#      } else {
#        $internal_physical_network = 'physnet2'
#        $external_physical_network = 'physnet1'
#        $external_network_type = 'flat'
#        $external_segment_id = undef
#      }

  # $nets_and_rou = create_predefined_networks_and_routers($quantum_config)
  # notify {"networks_and_routers: ${nets_and_rou}": }
  create_predefined_networks_and_routers($quantum_config)


  Keystone_user_role<| title=="$auth_user@$auth_tenant"|> -> Quantum::Network::Setup <| |>
  Keystone_user_role<| title=="$auth_user@$auth_tenant"|> -> Quantum::Network::Provider_router <| |>

  quantum::network::setup { 'net04':
    physnet      => $internal_physical_network,
    network_type => $tenant_network_type,
    segment_id   => $segment_id,
    subnet_name  => 'subnet04',
    subnet_cidr  => $fixed_range,
    nameservers  => '8.8.4.4',
  }
  #Quantum_l3_agent_config <| |> -> Quantum::Network::Setup['net04']

  quantum::network::setup { 'net04_ext':
    tenant_name     => 'services',
    physnet         => $external_physical_network,
    network_type    => $external_network_type,
    segment_id      => $external_segment_id, # undef,
    router_external => 'True',
    subnet_name     => 'subnet04_ext',
    subnet_cidr     => $floating_range,
    subnet_gw       => $external_gateway, # undef,
    alloc_pool      => $external_alloc_pool, # undef,
    enable_dhcp     => 'False', # 'True',
    shared          => 'True',
  }
  #Quantum_l3_agent_config <| |> -> Quantum::Network::Setup['net04_ext']

  quantum::network::provider_router { 'router04':
    router_subnets => 'subnet04',
    router_extnet  => 'net04_ext',
    auth_tenant    => $quantum_config['keystone']['admin_tenant_name'],
    auth_user      => $quantum_config['keystone']['admin_user'],
    auth_password  => $quantum_config['keystone']['admin_password'],
    auth_url       => $quantum_config['keystone']['auth_url']
  }
      #Quantum::Network::Provider_router<||> -> Service<| title=='quantum-l3' |>
#
#      # NEVER!!! do not notify services about newly-created networks!!!
#      # their cleanup kill ovs-interfaces !!!
#      #
#      # Quantum::Network::Provider_router<||> ~> Service<| title=='quantum-l3' |>
#      # Quantum::Network::Setup<||> ~> Service<| title=='quantum-dhcp-service' |>
#      #
#      #todo: implement search and scheduling unscheduled networks/routers, instead restart agents:
#      #
#      # Service<| title=='quantum-server' |> ->
#      # exec {'attach-unscheduled-l3':
#      #   command => "q-agent-tools.py --agent=l3 --attach-unscheduled",
#      #   path    => ["/sbin", "/bin", "/usr/sbin", "/usr/bin"],
#      #   refreshonly => true
#      # }
#
#      # turn down the current default route metric priority
#      # TODO: make function for recognize REAL defaultroute
#      # temporary use
#      # $update_default_route_metric = "bash -c \"(/sbin/ip route delete default via ${::default_gateway} || exit 0 ) && /sbin/ip route replace default via ${::default_gateway} metric 100\""
#      # exec { 'update_default_route_metric':
#      #   command     => $update_default_route_metric,
#      #   returns     => [0, 7],
#      #   refreshonly => true,
#      #   path      => ['/usr/bin', '/bin', '/sbin', '/usr/sbin']
#      # }
#      #Quantum::Network::Provider_router['router04'] -> Exec['update_default_route_metric']
#      #Class[quantum::waistline] -> Exec[update_default_route_metric]

#      # Package[$l3_agent_package] ~> Exec['update_default_route_metric']
#
#      # exec { 'settle-down-default-route':
#      #   command     => "/bin/ping -q -W2 -c1 ${external_gateway}",
#      #   subscribe   => Exec['update_default_route_metric'],
#      #   logoutput   => 'on_failure',
#      #   refreshonly => true,
#      #   try_sleep   => 3,
#      #   tries       => 5,
#      # }
#
#    }
}
# vim: set ts=2 sw=2 et :