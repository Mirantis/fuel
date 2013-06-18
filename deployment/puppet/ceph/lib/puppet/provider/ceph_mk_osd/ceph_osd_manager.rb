require 'facter'

Puppet::Type.type(:ceph_mk_osd).provide(:ceph_osd_manager) do
  desc "Manage nova admin user"

  optional_commands :ceph_osd_manager => 'ceph-osd-manager'

  def create
	notice("start creatin osd")
	uuid = Facter::Util::Resolution.exec("/sbin/blkid #{resource[:name]} -o value -s UUID")
	id = Facter::Util::Resolution.exec("ceph osd create #{uuid}")
	notice("osd id: #{id}")
	Puppet.warning(Facter::Util::Resolution.exec("ceph-osd -c /etc/ceph/ceph.conf -i #{id} --mkfs --mkkey --osd-uuid #{uuid}"))
	Puppet.warning(Facter::Util::Resolution.exec("ceph auth add osd.#{id} osd 'allow *' mon 'allow rwx' -i #{resource[:osd_data]}/keyring"))
	honame = Facter::Util::Resolution.exec("/bin/hostname")
	Facter::Util::Resolution.exec("ceph osd crush set #{resource[:osd_data]} 1 root=default host=#{honame}")
	Facter::Util::Resolution.exec("/etc/init.d/ceph start osd.#{id}")
  end

  def destroy
	Facter::Util::Resolution.exec("/etc/init.d/ceph stop osd.#{id}")
  end
    
  def exists?
	notice("start exists")
	#uuid = Facter::Util::Resolution.exec("/sbin/blkid #{resource[:name]} -o value -s UUID")
	#return !Facter::Util::Resolution.exec("/usr/bin/ceph osd dump | grep #{uuid}").nil?
        return true
  end

end

