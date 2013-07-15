# Class: nova::volume::san
#
# This class assumes that you have already configured your
# volume group - either by another module or during the server
# provisioning
#
# SanISCSIDriver(nova.volume.driver.ISCSIDriver):
# SolarisISCSIDriver(SanISCSIDriver):
# HpSanISCSIDriver(SanISCSIDriver):
# SolidFireSanISCSIDriver(SanISCSIDriver):
#

class nova::volume::san (
  $volume_driver   = 'nova.volume.san.SolarisISCSIDriver',
  $san_ip          = '127.0.0.1',
  $san_login       = 'cluster_operator',
  $san_password    = '007',
  $san_private_key = undef,
  $san_clustername = 'storage_cluster'
) {

  if $san_private_key {
    nova_config { 'DEFAULT/san_private_key': value => $san_private_key }
  } else {
    nova_config {
      'DEFAULT/san_login':    value => $san_login;
      'DEFAULT/san_password': value => $san_password;
    }
  }

  nova_config {
    'DEFAULT/volume_driver':   value => $volume_driver;
    'DEFAULT/san_ip':          value => $san_ip;
    'DEFAULT/san_clustername': value => $san_clustername;
  }

}
