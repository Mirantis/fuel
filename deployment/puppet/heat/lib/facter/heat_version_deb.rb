Facter.add("heat_version_deb") do
  setcode do
# heat to be installed
    Facter::Util::Resolution.exec('/usr/bin/apt-get -s install heat-common | grep heat-common | grep Inst | awk \'{ print $3 }\' | awk -F\':\' \'{ print $2 }\' ')
  end
end