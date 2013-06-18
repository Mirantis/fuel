Puppet::Type.newtype(:ceph_mk_osd) do

  @doc = "Manage creation/deletion of ceph osd."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The device of the osd."
  end

  newparam(:osd_data) do
    desc 'osd_data pth'
  end
end
