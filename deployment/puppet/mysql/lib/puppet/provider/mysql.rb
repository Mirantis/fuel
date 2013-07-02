class Puppet::Provider::Mysql < Puppet::Provider
  def connection_options
    cmd_array = []
    if @resource[:connection_host]
      cmd_array = [
        "--host=#{@resource[:connection_host]}",
        "--port=#{@resource[:connection_port]}",
        "--user=#{@resource[:connection_user]}",
        "--password=#{@resource[:connection_pass]}",
      ]
    end
    cmd_array
  end
end
