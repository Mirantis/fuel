# This has to be a separate type to enable collecting
Puppet::Type.newtype(:database_grant) do
  @doc = "Manage a database user's rights."
  #ensurable

  autorequire :database do
    # puts "Starting db autoreq for %s" % self[:name]
    reqs = []
    matches = self[:name].match(/^([^@]+)@([^\/]+)\/(.+)$/)
    unless matches.nil?
      reqs << matches[3]
    end
    # puts "Autoreq: '%s'" % reqs.join(" ")
    reqs
  end

  autorequire :database_user do
    # puts "Starting user autoreq for %s" % self[:name]
    reqs = []
    matches = self[:name].match(/^([^@]+)@([^\/]+).*$/)
    unless matches.nil?
      reqs << "%s@%s" % [ matches[1], matches[2] ]
    end
    # puts "Autoreq: '%s'" % reqs.join(" ")
    reqs
  end

  newparam(:name, :namevar=>true) do
    desc "The primary key: either user@host for global privilges or user@host/database for database specific privileges"
  end

  newproperty(:privileges, :array_matching => :all) do
    desc "The privileges the user should have. The possible values are implementation dependent."

    def should_to_s(newvalue = @should)
      if newvalue
        unless newvalue.is_a?(Array)
          newvalue = [ newvalue ]
        end
        newvalue.collect do |v| v.downcase end.sort.join ", "
      else
        nil
      end
    end

    def is_to_s(currentvalue = @is)
      if currentvalue
        unless currentvalue.is_a?(Array)
          currentvalue = [ currentvalue ]
        end
        currentvalue.collect do |v| v.downcase end.sort.join ", "
      else
        nil
      end
    end

    # use the sorted outputs for comparison
    def insync?(is)
      if defined? @should and @should
        case self.should_to_s
        when "all"
          self.provider.all_privs_set?
        when self.is_to_s(is)
          true
        else
          false
        end
      else
        true
      end
    end
  end

  # Connect to remote host
  newparam(:connection_user) do
    desc 'Authorization user to remote host'

    defaultto 'root'

    validate do |value|
      return unless value
    end

    munge do |value|
      value ||= 'root'
    end.to_s
  end

  newparam(:connection_pass) do
    desc 'Authorization password to remote host'

    defaultto ''

    munge do |value|
      value ||= ''
    end.to_s
  end

  newparam(:connection_host) do
    desc 'Host for remote authorization'
    validate do |value|
      return unless value
      raise(ArgumentError, "Value: #{value} does not seems like IP") unless value =~ /^(\d{1,3}\.){3}\d{1,3}$/
    end
  end

  newparam(:connection_port) do
    desc 'Port for remote authorization'

    defaultto '3306'

    validate do |value|
      return unless value
      port_range = (1025..48999)
      return if value.respond_to?(:to_i) && port_range.include?(value.to_i)
      raise(ArgumentError, "#{value} is incorrect port range #{port_range.min}-#{port_range.max}")
    end

    munge do |value|
      value ||= 3306
    end.to_s
  end
end

