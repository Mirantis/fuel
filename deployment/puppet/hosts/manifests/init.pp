class hosts ($used_hosts = '') {
    file {"/etc/hosts":
	ensure => present,
	mode => 644,
	owner => root,
	group => root,
	content => template("hosts/hosts.erb"),
    }
}
