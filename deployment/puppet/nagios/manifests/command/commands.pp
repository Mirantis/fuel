define nagios::command::commands( $command = false ) {

  @@nagios_command { $name:
    ensure       => present,
    command_line => $command,
    target       => "/etc/nagios3/${proj_name}/commands.cfg",
  }
}
