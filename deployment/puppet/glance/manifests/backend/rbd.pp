#
# configures the storage backend for glance
# as a ceph rbd
#
#  $rbd_store_user - Optional. Default: 'images',
#
#  $rbd_store_pool - Optional. Default:'images',
#
#  $show_image_direct_url - Optional. Default: 'True',
#
class glance::backend::rbd(
    $rbd_store_user = 'images',
    $rbd_store_pool = 'images',
    $show_image_direct_url = 'True',
) inherits glance::api {
  glance_api_config {
    'DEFAULT/default_store': value => 'rbd';
    'DEFAULT/rbd_store_user':         value => $rbd_store_user;
    'DEFAULT/rbd_store_pool':          value => $rbd_store_pool;
    'DEFAULT/show_image_direct_url': value => $show_image_direct_url;
  }

}
