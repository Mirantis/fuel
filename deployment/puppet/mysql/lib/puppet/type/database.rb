# This has to be a separate type to enable collecting
Puppet::Type.newtype(:database) do
  @doc = "Manage databases."

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the database."
  end

  newproperty(:charset) do
    desc "The characterset to use for a database"
    defaultto :utf8
    newvalue(/^\S+$/)
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
