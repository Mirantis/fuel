#
# sanitize_bool_in_hash.rb
#

# todo: process_array
def process_array(aa)
  rv = []
  aa.each do |v|
    if v.is_a? Hash
      rv.insert(-1, process_hash(v))
    elsif v.is_a? Array
      rv.insert(-1, process_array(v))
    else
      rv.insert(-1, v)
    end
  end
  return rv
end

def process_hash(hh)
  rv = {}
  hh.each do |k, v|
    if v.is_a? String or v.is_a? Symbol
      rv[k] = case v.upcase()
        when 'TRUE', :TRUE then true
        when 'FALSE', :FALSE then false
        when 'NONE', :NONE, 'NULL', :NULL, 'NIL', :NIL, 'NILL', :NILL then nil
        else v
      end
    elsif v.is_a? Hash
      rv[k] = process_hash(v)
    elsif v.is_a? Array
      rv[k] = process_array(v)
    else
      rv[k] = v
    end
  end
  return rv
end

module Puppet::Parser::Functions
  newfunction(:sanitize_bool_in_hash, :type => :rvalue, :doc => <<-EOS
    This function get Hash, recursive convert string implementation
    of true, false, none, null, nil to Puppet/Ruby-specific
    types.

    EOS
  ) do |argv|
    if argv.size != 1
      raise(Puppet::ParseError, "sanitize_bool_in_hash(hash): Wrong number of arguments.")
    end

    return process_hash(argv[0])
  end
end

# vim: set ts=2 sw=2 et :