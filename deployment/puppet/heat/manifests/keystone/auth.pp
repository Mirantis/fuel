class heat::keystone::auth(
  $password,
  $auth_name        = 'heat',
  $public_address   = '127.0.0.1',
  $admin_address    = '127.0.0.1',
  $internal_address = '127.0.0.1',
  $heat_port        = '8004',
  $region           = 'RegionOne',
  $tenant           = 'services',
  $email            = 'heat@localhost'
) {

  notify {"Keystone":}
  keystone_user { $auth_name:
    ensure   => present,
    password => $password,
    email    => $email,
    tenant   => $tenant,
  }

  keystone_user_role { "${auth_name}@${tenant}":
    ensure  => present,
    roles   => 'admin',
  }
  keystone_service { $auth_name:
    ensure      => present,
    type        => 'orchestration',
    description => 'Openstack_HEAT_Service',
  }

  keystone_endpoint { "$region/$auth_name":
    ensure       => present,
    region       => $region,
    public_url   => "http://${public_address}:${heat_port}/v1/%(tenant_id)s",
    internal_url => "http://${internal_address}:${heat_port}/v1/%(tenant_id)s",
    admin_url    => "http://${admin_address}:${heat_port}/v1/%(tenant_id)s",
  }
}
