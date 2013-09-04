#    Copyright 2013 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.


Puppet::Type.newtype(:cfg) do
    @doc = "Manage a key/value pairs in config file"
    desc @doc

    ensurable

    newparam(:key) do
      isnamevar
      desc "Key in config file"
      #
      validate do |kkk|
        if not kkk =~ /^[a-zA-Z][0-9a-zA-Z\.\-\_]*[0-9a-zA-Z]$/
          fail("Invalid key name: '#{kkk}'")
        end
      end
    end

    newproperty(:value) do
      desc "Value, that will be set to key"
    end

    newparam(:key_val_separator_char) do
      defaultto('=')
      desc "key/value separator in cfg file"
    end

    newparam(:comment_char) do
      defaultto('#')
      desc "1st non space char, that say that this line is comment"
    end

    newparam(:file) do
      desc "Config file path"
      #
      validate do |val|
        if not val =~ /^[0-9a-zA-Z\.\-\_\/]*[0-9a-zA-Z]$/
          fail("Invalid file name: '#{val}'")
        end
      end
    end
end
