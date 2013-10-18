# Fact: adv_netconfig_done
#
# Purpose: check existing fingerprint file
#
Facter.add(:adv_netconfig_filepath) do
  setcode do
    '/root/openstack_fuel_netconfig_done.uuid'
  end
end

Facter.add(:adv_netconfig_done) do
  setcode do
    filename = Facter.value(:adv_netconfig_filepath)
    begin
      ff = File.open(filename, 'r')
      ff.close()
      rv = true
    rescue Exception => e
      rv = false
    end
    rv
  end
end
# vim: set ts=2 sw=2 et :