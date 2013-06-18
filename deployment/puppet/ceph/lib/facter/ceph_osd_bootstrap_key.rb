# Fact: ceph_osd_bootstrap_key
#
# Purpose:
#
# Resolution:
#
# Caveats:
#

require 'facter'

## ceph_osd_bootstrap_key
## Fact that gets the ceph key "client.bootstrap-osd"

Facter.add(:ceph_admin_key) do
  setcode do
    Facter::Util::Resolution.exec("ceph auth get-key client.admin")
  end
end


#Facter.add(:fsid) do
#  setcode do
#    Facter::Util::Resolution.exec("uuidgen")
#  end
#end
## blkid_uuid_#{device} / ceph_osd_id_#{device}
## Facts that export partitions uuids & ceph osd id of device


# Load the osds/uuids from ceph
