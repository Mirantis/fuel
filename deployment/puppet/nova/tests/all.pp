resources { 'nova_config':
  purge => true,
}
class { 'mysql::server': }
class { 'nova::all':
  db_password => 'password',
  db_name => 'nova',
  db_user => 'nova',
  db_host => 'localhost',

  rabbit_password => 'rabbitpassword',
  rabbit_port => '5672',
  rabbit_userid => 'rabbit_user',
  rabbit_virtual_host => '/',
  rabbit_host => 'localhost',

  image_service => 'nova.image.glance.GlanceImageService',

  glance_api_servers => 'localhost:9292',

  libvirt_type => 'qemu',
}
