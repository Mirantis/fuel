Puppet::Type.newtype(:ring_object_device) do
  require 'ipaddr'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      # Commit 103b68b changed acceptable format from address:port/device to just address:port.
      address = value.split(':')
      raise(Puppet::Error, "invalid name #{value}: should contain address:port") unless address.size == 2
      IPAddr.new(address[0])
    end
  end

  newparam(:mountpoints) do
    desc "mountpoints and weight "
  end

  newproperty(:zone) do
  end

  # Commit 103b68b removed weight but I don't know why.

  newproperty(:meta) do
  end

  [:id, :partitions, :balance].each do |param|
    newproperty(param) do
      validate do |value|
        raise(Puppet::Error, "#{param} is a read only property, cannot be assigned")
      end
    end
  end

  autorequire(:exec) do
    ['create_object']
  end

end
