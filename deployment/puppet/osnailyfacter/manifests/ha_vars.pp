$vips = { # Do not convert to ARRAY, It cant work in 2.7
  public_old => {
    nic    => $::public_int,
    ip     => $public_vip,
  },
  management_old => {
    nic    => $::internal_int,
    ip     => $management_vip,
  },
}

$vip_keys = keys($vips)


if $node[0]['role'] == 'primary-controller' {
  $primary_controller = true
} else {
  $primary_controller = false
}


