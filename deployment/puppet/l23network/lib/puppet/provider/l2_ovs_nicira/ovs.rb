require 'net/https'
require 'rubygems'
require 'json'

Puppet::Type.type(:l2_ovs_nicira).provide(:ovs) do

  def login
    conn = Net::HTTP.new(@resource[:nsx_endpoint],443)
    conn.use_ssl = true
    resp, data = conn.post('/ws.v1/login', "username=#{@resource[:nsx_username]}&password=#{@resource[:nsx_password]}")
    cookie = resp.response['set-cookie'].split('; ')[0]
    return conn, cookie
  end

  def exists?
    conn, cookie = login
    resp, data = conn.get('/ws.v1/transport-node', { 'Cookie' => cookie })
    nodes = JSON.load(data)['results']
    nodes.each { |node|
      resp, data = conn.get(node['_href'], { 'Cookie' => cookie })
      if JSON.load(data)['display_name'] == @resource[:name]
        return true
      end
    } 
    false
  end

  def create
    conn, cookie = login
    query = {
	  'display_name' => @resource[:name],
	  'credential' => {
	    'client_certificate' => {
	      'pem_encoded' => @resource[:client_certificate] 
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
    conn.post('/ws.v1/transport-node', query.to_json, { 'Cookie' => cookie , 'Content-Type' => 'application/json'})
  end

  def destroy
  end
end
