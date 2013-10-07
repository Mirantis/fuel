module Puppet::Parser::Functions
  newfunction(:validate_schema, :type => :rvalue, :doc => <<-EOS
Validate input hash from facts for compliance with data structure.
Raise Puppet::ParseError if error is found
    EOS
  ) do |args|
    require 'rubygems'
    require 'kwalify'

    raise(Puppet::ParseError, "validate_schema(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if args.size != 1

    yaml_settings = args[0]
    unless yaml_settings.is_a?(Hash)
      raise(Puppet::ParseError, 'validate_schema(): Requires hash to work with')
    end

    do_raise = args[1]
    do_raise = true if do_raise.nil?

    schema_dir_path = File.expand_path(File.dirname(__FILE__))
    schema_path = File.join(schema_dir_path, "deploy_schema.yaml")
    schema_hash = YAML.load_file(schema_path)
    validator = Kwalify::Validator.new(schema_hash)
    errors = validator.validate(yaml_settings)

    # Check structure and basic types for expected params
    messages = []
    errors.each do |e|
      msg = "[#{e.path}] #{e.message}"
      if e.message.include?("is undefined")
        Puppet.debug msg
        messages << "DEBUG: #{msg}"
      else
        Puppet.err msg
        messages << "ERROR: #{msg}"
      end
    end

    result = true
    if errors.select {|e| !e.message.include?("is undefined") }.size > 0
      raise Puppet::ParseError, "Data validation failed. #{$/} #{messages.join($/)}" if do_raise
      result = false
    end

    result && ValidationSchema.yaml_schema_validation(yaml_settings, do_raise)
  end
end

module ValidationSchema
  require 'puppet'

  def self.yaml_schema_validation(settings, do_raise)
    result = true
    if settings['quantum']
      settings['nodes'].each do |node|
        ['public_br', 'internal_br'].each do |br|
          if node[br].nil? || node[br].empty?
            msg = "Node #{node['uid']} required 'public_br' and 'internal_br'
                   when quantum is 'true'"
            result = raise_or_send_debug(do_raise, msg)
          end
        end
      end

      errors = []
      ['quantum_parameters', 'quantum_access'].each do |param|
        errors << param if !settings[param] || settings[param].empty?
      end

      errors.each do |field|
        msg = "#{field} is required when quantim is true"
        result = raise_or_send_debug(do_raise, msg)
      end

      if !is_cidr_notation?(settings['floating_network_range'])
        msg = "'floating_network_range' is required CIDR notation when quantum is 'true'"
        result = raise_or_send_debug(do_raise, msg)
      end

      if !is_cidr_notation?(settings['floating_network_range'])
        msg = "'floating_network_range' is required CIDR notation"
        result = raise_or_send_debug(do_raise, msg)
      end
    else
      if !settings['floating_network_range'].is_a?(Array)
        msg = "'floating_network_range' is required array of IPs when quantum is 'false'"
        result = raise_or_send_debug(do_raise, msg)
      end
    end

    if !is_cidr_notation?(settings['fixed_network_range'])
      msg = "'fixed_network_range' is required CIDR notation, but got #{settings['fixed_network_range']}"
      result = raise_or_send_debug(do_raise, msg)
    end
  end

  def self.raise_or_send_debug(do_raise, msg)
    raise Puppet::ParseError, msg if do_raise
    Puppet.err msg
    false
  end

  def self.is_cidr_notation?(value)
    cidr = Regexp.new('^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(\d|[1-2]\d|3[0-2]))$')
    !cidr.match(value).nil?
  end
end
