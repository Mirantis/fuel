Puppet::Type.type(:make_fingerprint).provide(:simple) do

  def exists?
    begin
      ff = File.open(@resource[:name], 'r')
      ff.close()
      rv = true
    rescue Exception => e
      rv = false
    end
    rv
  end

  def create()
    tt = Time.new()
    begin
      File.open(@resource[:name], 'w') do |fh|
        fh.puts(tt.strftime("%Y-%m-%d %H:%M:%S"))
      end
      rv = true
    rescue Exception => e
      rv = false
    end
    rv
  end

  def destroy()
    File.delete(@resource[:name])
  end

end
# vim: set ts=2 sw=2 et :