require 'net/https'
require 'rubygems'
require 'json'

Puppet::Type.type(:l2_ovs_nicira).provide(:ovs) do

  commands :vsctl => '/usr/bin/ovs-vsctl'
  commands :vspki => '/usr/bin/ovs-pki'

  @cert_dir = "/etc/openvswitch"
  @cert_path = "#{@cert_dir}/ovsclient-cert.pem"
  @privkey_path = "#{@cert_dir}/ovsclient-privkey.pem"
  @cacert_path = "#{@cert_dir}/vswitchd.cacert"

  def generate_cert
    if not File.exists? @cert_path
      old_dir = Dir.pwd
      Dir.chdir @cert_dir
      vspki("init --force")
      vspki("req+sign ovsclient controller")
      vsctl("-- --bootstrap set-ssl #{@cert_path} #{@privkey_path} #{@cacert_path}")
      vsctl("set-manager ssl:#{@resource[:nsx_endpoint]}")
      Dir.chdir old_dir
    end
  end

  def get_cert
    if File.exists? @cert_path
      cert_file = File.open(@cert_path, "r")
      cert_contents = cert_file.read
      cert = cert_contents.gsub(/.*?(?=-*BEGIN CERTIFICATE-*)/m, "")
      return cert
    end
    return nil
  end

  def login
    conn = Net::HTTP.new(@resource[:nsx_endpoint],443)
    conn.use_ssl = true
    resp, data = conn.post('/ws.v1/login', "username=#{@resource[:nsx_username]}&password=#{@resource[:nsx_password]}")
    cookie = resp.response['set-cookie'].split('; ')[0]
    return conn, cookie
  end

  def get_uuid(display_name)
    resp, data = @conn.get('/ws.v1/transport-node', { 'Cookie' => @cookie })
    nodes = JSON.load(data)['results']
    nodes.each { |node|
      resp, data = @conn.get(node['_href'], { 'Cookie' => @cookie })
      if JSON.load(data)['display_name'] == @resource[:name]
        return JSON.load(data)['uuid']
      end
    } 
    return nil
  end

  def exists?
    @conn, @cookie = login
    query_result = get_uuid(@resource[:name])
    if query_result != nil
      return true
    end
    return false
  end

  def create
    generate_cert
    cert = get_cert
    query = {
	  'display_name' => @resource[:name],
	  'credential' => {
	    'client_certificate' => {
	      'pem_encoded' => cert 
	    },
	    'type' => 'SecurityCertificateCredential'
	  },
	  'transport_connectors' => [
	    {
	      'transport_zone_uuid' => @resource[:transport_zone_uuid],
	      'ip_address' => @resource[:ip_address],
	      'type' => @resource[:connector_type]
	    }
	  ],
	  'integration_bridge_id' => @resource[:integration_bridge]
    }
    @conn.post('/ws.v1/transport-node', query.to_json, { 'Cookie' => @cookie , 'Content-Type' => 'application/json'})
  end

  def destroy
    uuid = get_uuid(@resource[:name])
    if uuid != nil
      @conn.delete("/ws.v1/transport-node/#{uuid}", { 'Cookie' => @cookie})
    end
  end
end
