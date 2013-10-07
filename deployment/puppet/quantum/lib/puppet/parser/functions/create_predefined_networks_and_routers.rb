require 'ipaddr'
require 'yaml'
require 'json'

class MrntQuantumNR
  def initialize(scope, cfg)
    @scope = scope
    @quantum_config = cfg
  end

  #class method
  def self.sanitize_array(aa)
    aa.reduce([]) do |rv, v|
      rv << case v.class
          when Hash  then sanitize_hash(v)
          when Array  then sanitize_array(v)
          else v
      end
    end
  end

  #class method
  def self.sanitize_hash(hh)
    rv = {}
    hh.each do |k, v|
      rv[k.to_sym] = case v.class.to_s
        when "Hash"  then sanitize_hash(v)
        when "Array" then sanitize_array(v)
        else v
      end
    end
    return rv
  end

  def default_netmask()
    "/24"
  end

  def create_resources()
  end
end

module Puppet::Parser::Functions
  newfunction(:create_predefined_networks_and_routers , :doc => <<-EOS
    This function get Hash of Quantum configuration
    and create predefined networks and routers.

    Example call:
    $config = create_predefined_networks_and_routers($quantum_settings_hash)

    EOS
  ) do |argv|
    #Puppet::Parser::Functions.autoloader.loadall
    nr_conf = MrntQuantumNR.new(self, MrntQuantumNR.sanitize_hash(argv[0]))
    nr_conf.create_resources()
  end
end
# vim: set ts=2 sw=2 et :