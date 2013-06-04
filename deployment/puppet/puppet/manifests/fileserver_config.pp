class puppet::fileserver_config(
  $puppet_confdir = '/etc/puppet',
  $folders = [{
    section=>'ssh_keys',
    path=>'/var/lib/puppet/ssh_keys',
    allow=>'*',
    deny => undef,
  },],
  $notify_service = "thin" 
){
  
  if (! defined(Service[$notify_service])) {
    service {$notify_service:}
  }

  file { "${puppet_confdir}/fileserver.conf":
      content => template("puppet/fileserver.conf.erb"),
      notify => Service[$notify_service],
  }
 

}
  