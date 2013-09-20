Facter.add("heat_version_rh") do
  setcode do
# heat to be installed
    Facter::Util::Resolution.exec('/usr/bin/yum list | grep heat-common | awk \'{ print $2 }\'')
  end
end