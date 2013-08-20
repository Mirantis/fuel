
if $cinder_nodes {
   $cinder_nodes_array = parsejson($::cinder_nodes)
}
else {
  $cinder_nodes_array = []
}


$cinder_iscsi_bind_addr = $::storage_address
