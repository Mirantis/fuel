
$swift_proxy_nodes = merge_arrays(filter_nodes($nodes_hash,'role','primary-swift-proxy'),filter_nodes($nodes,'role','swift-proxy'))
$swift_proxies = nodes_to_hash($swift_proxy_nodes,'name','storage_address')
$swift_storages = filter_nodes($nodes_hash, 'role', 'storage')

if $node[0]['role'] == 'primary-swift-proxy' {
  $primary_proxy = true
} else {
  $primary_proxy = false
}

$master_swift_proxy_nodes = filter_nodes($nodes_hash,'role','primary-swift-proxy')
$master_swift_proxy_ip = $master_swift_proxy_nodes[0]['internal_address']

$swift_local_net_ip      = $::storage_address
