Puppet::Type.newtype(:make_fingerprint) do
    @doc = "Make fingerprint as file"
    desc @doc

    ensurable

    newparam(:name) do
      desc "filename for fingerprint"
      #
      munge do |val|
        val.to_s
      end
    end

end
# vim: set ts=2 sw=2 et :