require 'ipaddr'
begin
  require 'puppet/parser/functions/lib/prepare_cidr.rb'
rescue LoadError => e
  # puppet apply does not add module lib directories to the $LOAD_PATH (See
  # #4248). It should (in the future) but for the time being we need to be
  # defensive which is what this rescue block is doing.
  rb_file = File.join(File.dirname(__FILE__),'lib','prepare_cidr.rb')
  load rb_file if File.exists?(rb_file) or raise e
end
begin
  require 'puppet/parser/functions/lib/sanitize_hash.rb'
rescue LoadError => e
  # puppet apply does not add module lib directories to the $LOAD_PATH (See
  # #4248). It should (in the future) but for the time being we need to be
  # defensive which is what this rescue block is doing.
  rb_file = File.join(File.dirname(__FILE__),'lib','sanitize_hash.rb')
  load rb_file if File.exists?(rb_file) or raise e
end

Puppet::Parser::Functions::newfunction(:get_network_role_property, :type => :rvalue, :doc => <<-EOS
    This function get get network config Hash, network_role name and mode --
    and return information about network role.

    ex: get_network_role_property(hash, 'admin', 'interface')

    You can use following modes:
      interface -- network interface for the network_role
      ipaddr -- IP address for the network_role
      cidr -- CIDR-notated IP addr and mask for the network_role
      netmask -- string, contains dotted nemmask
      ipaddr_netmask_pair -- list of ipaddr and netmask

    EOS
  ) do |argv|
  if argv.size == 3
    mode = argv[2].to_s().upcase()
  else
      raise(Puppet::ParseError, "get_network_role_property(cfg_hash, role_name): Wrong number of arguments.")
  end
  cfg = sanitize_hash(argv[0])
  network_role = argv[1].to_sym()

  if !cfg[:roles] || !cfg[:endpoints] || cfg[:roles].class.to_s() != "Hash" || cfg[:endpoints].class.to_s() != "Hash"
      raise(Puppet::ParseError, "get_network_role_property(cfg_hash, role_name): Invalid cfg_hash format.")
  end

  # search interface for role
  interface = cfg[:roles][network_role]
  if !interface
      raise(Puppet::ParseError, "get_network_role_property(cfg_hash, role_name): Undefined network_role '#{network_role}'.")
  end

  # get endpoint configuration hash for interface
  ep = cfg[:endpoints][interface.to_sym()]
  if !ep
      raise(Puppet::ParseError, "get_network_role_property(cfg_hash, role_name): Can't find interface '#{interface}' in endpoints for network_role '#{network_role}'.")
  end

  if mode == 'INTERFACE'
    return interface.to_s
  end

  case ep[:IP].class().to_s()
    when "Array"
      ipaddr_cidr = ep[:IP][0] ? ep[:IP][0] : nil
    when "String"
      #raise(Puppet::ParseError, "get_network_role_property(cfg_hash, role_name): Can't determine dynamic or empty IP address for endpoint '#{interface}' (#{ep[:IP]}).")
      ipaddr_cidr = nil
    else
      raise(Puppet::ParseError, "get_network_role_property(cfg_hash, role_name): invalid IP address for endpoint '#{interface}'.")
  end

  if ipaddr_cidr == nil
    return nil
  end

  case mode
    when 'CIDR'
      return ipaddr_cidr
    when 'NETMASK'
      return IPAddr.new('255.255.255.255').mask(prepare_cidr(ipaddr_cidr)[1]).to_s()
    when 'IPADDR'
      return prepare_cidr(ipaddr_cidr)[0].to_s()
    when 'IPADDR_NETMASK_PAIR'
      return prepare_cidr(ipaddr_cidr)[0].to_s(), IPAddr.new('255.255.255.255').mask(prepare_cidr(ipaddr_cidr)[1]).to_s()
    end



end

# vim: set ts=2 sw=2 et :