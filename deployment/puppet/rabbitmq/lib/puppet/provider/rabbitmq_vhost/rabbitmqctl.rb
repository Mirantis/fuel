Puppet::Type.type(:rabbitmq_vhost).provide(:rabbitmqctl) do

  #TODO: change optional_commands -> commands when puppet >= 3.0
  optional_commands :rabbitmqctl => 'rabbitmqctl'
  defaultfor :feature => :posix

  def self.instances
    rabbitmqctl('list_vhosts').split(/\n/)[1..-2].map do |line|
      if line =~ /^(\S+)$/
        new(:name => $1)
      else
        raise Puppet::Error, "Cannot parse invalid user line: #{line}"
      end
    end
  end

  def create
    rabbitmqctl('add_vhost', resource[:name])
  end

  def destroy
    rabbitmqctl('delete_vhost', resource[:name])
  end

  def exists?
    out = rabbitmqctl('list_vhosts').split(/\n/)[1..-2].detect do |line|
      line.match(/^#{Regexp.escape(resource[:name])}$/)
    end
  end

end
