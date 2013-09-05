module Puppet::Parser::Functions
  newfunction(:has_role, :type => :rvalue) do |args|
    args[0].include?(args[1]) 
  end
end
