require 'forwardable'
require 'puppet/parser'
require 'puppet/parser/templatewrapper'
require 'puppet/resource/type_collection_helper'
require 'puppet/util/methodhelper'

def sanitize_hash(cfg)
  def process_array(aa)
    rv = []
    aa.each do |v|
      if v.is_a? Hash
        rv.insert(-1, process_hash(v))
      elsif v.is_a? Array
        rv.insert(-1, process_array(v))
      else
        rv.insert(-1, v)
      end
    end
    return rv
  end
  def process_hash(hh)
    rv = {}
    hh.each do |k, v|
      #info("xx>>#{k}--#{k.to_sym}<<")
      if v.is_a? Hash
        rv[k.to_sym] = process_hash(v)
      elsif v.is_a? Array
        rv[k.to_sym] = process_array(v)
      else
        rv[k.to_sym] = v
      end
    end
    return rv
  end
  process_hash(cfg)
end

def sanitize_transformation(trans)
  action = trans[:action].downcase()
  # Setup defaults
  rv = case action
    when "add-br" then {
      :name => nil,
      #:stp_enable => true,
      :skip_existing => true
    }
    when "add-port" then {
      :name => nil,
      :bridge => nil,
      :type => "internal",
      :tag => 0,
      :trunks => [],
      :port_properties => [],
      :interface_properties => [],
      :skip_existing => true
    }
    when "add-bond" then {
      :name => nil,
      :bridge => nil,
      :type => "internal",
      :interfaces => [],
      :tag => 0,
      :trunks => [],
      :properties => [],
      #:port_properties => [],
      #:interface_properties => [],
      :skip_existing => true
    }
    when "add-patch" then {
      :peers => [],
      :bridges => [],
      :tags => [0, 0],
      :trunks => [],
    }
    else
      raise(Puppet::ParseError, "Unknown transformation: '#{action}'.")
  end
  rv[:action] = action
  rv.each do |k,v|
    if trans[k]
      rv[k] = trans[k]
    end
  end
  # Check for incorrect parameters
  if not rv[:name].is_a? String and action != "add-patch"
    raise(Puppet::ParseError, "Unnamed transformation: '#{action}'.")
  end
  name = rv[:name]
  if not rv[:bridge].is_a? String and not ["add-patch", "add-br"].index(action)
    raise(Puppet::ParseError, "Undefined bridge for transformation '#{action}' with name '#{name}'.")
  end
  if action == "add-patch"
    if not rv[:bridges].is_a? Array  or  rv[:bridges].size() != 2
      raise(Puppet::ParseError, "Transformation patch '#{name}' have wrong 'bridges' parameter.")
    end
    if not rv[:peers].is_a? Array  or  rv[:peers].size() != 2
      raise(Puppet::ParseError, "Transformation patch '#{name}' have wrong 'peers' parameter.")
    end
  end
  if action == "add-bond"
    if not rv[:interfaces].is_a? Array or rv[:interfaces].size() != 2
      raise(Puppet::ParseError, "Transformation bond '#{name}' have wrong 'interfaces' parameter.")
    end
    # rv[:interfaces].each do |i|
    #   if
    # end
  end
  return rv
end



Puppet::Parser::Functions::newfunction(:config_network_from_json_v1, :type => :rvalue, :doc => <<-EOS
    This function get Hash of network interfaces and endpoints configuration
    and realized it.

    EOS
  ) do |argv|

    if argv.size != 1
      raise(Puppet::ParseError, "config_network_from_json_v1(hash): Wrong number of arguments.")
    end

    config_hash = sanitize_hash(argv[0])

    # define internal puppet parameters for creating resources
    res_factory = {
      :br      => { :name_of_resource => 'l23network::l2::bridge' },
      :port    => { :name_of_resource => 'l23network::l2::port' },
      :bond    => { :name_of_resource => 'l23network::l2::bond' },
      #:patch   => { :name_of_resource => 'l23network::l2::path' },
      :ifconfig=> { :name_of_resource => 'l23network::l3::ifconfig' }
    }
    res_factory.each do |k, v|
      if v[:name_of_resource].index('::')
        # operate by Define
        res_factory[k][:resource] = lookuptype(v[:name_of_resource].downcase())  # may be find_definition(k.downcase())
        res_factory[k][:type_of_resource] = :define
      else
        # operate by custom Type
        res_factory[k][:resource] = Puppet::Type.type(v[:name_of_resource].to_sym())
        res_factory[k][:type_of_resource] = :type
      end
    end

    transformation_success = []
    config_hash[:transformations].each do |t|
      action = t[:action].strip()
      if action.start_with?('add-')
        action = t[:action][4..-1].to_sym()
      else
        action = t[:action].to_sym()
      end

      trans = sanitize_transformation(t)

      resource = res_factory[action][:resource]
      p_resource = Puppet::Parser::Resource.new(
          res_factory[action][:name_of_resource],
          trans[:name],
          :scope => self,
          :source => resource
      )
      # {:name => title}.merge(params).each do |k,v|
      trans.select{|k,v| k != :action}.each do |k,v|
        p_resource.set_parameter(k,v)
      end
      resource.instantiate_resource(self, p_resource)
      compiler.add_resource(self, p_resource)
      transformation_success.insert(-1, "#{t[:action].strip()}(#{trans[:name]})")
    end

    return transformation_success.join(" -> ")
end

# vim: set ts=2 sw=2 et :