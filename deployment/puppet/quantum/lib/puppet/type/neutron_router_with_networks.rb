Puppet::Type.newtype(:neutron_router_with_networks) do

  @doc = "Recursive create networks and subnets for given router"

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The router name'
  end

  newparam(:config) do
    desc "Quantum config hash"
    defaultto {}
  end

  # Require the Quantum service to be running
  autorequire(:package) do
    ['python-quantumclient']
  end

end
