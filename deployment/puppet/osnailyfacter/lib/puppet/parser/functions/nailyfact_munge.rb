module Puppet::Parser::Functions
   newfunction(:nailyfact_munge, :type => :statement, :arity => -1) do |args| 

        boolean_vars=args[0]

        Puppet::Parser::Functions.function('str2bool')

        catalog_vars = to_hash

        nf_vars = catalog_vars.select do |key,value|
            key =~ /^nf_\w+$/
        end

        vars = {}

        nf_vars.each do |nf_var_name,nf_var_value|
            var = nf_var_name.sub(/^nf_/,'')
            vars[var]=nf_var_value
        end

        Puppet.debug(vars.inspect)

        vars.each do |var_name,var_value|
            if boolean_vars.include?(var_name)
                self[var_name]=function_str2bool([var_value])
            else
                self[var_name]=var_value
            end
        end
   end
end
