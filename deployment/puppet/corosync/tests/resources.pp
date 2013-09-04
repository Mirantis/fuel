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


cs_property { 'expected-quorum-votes':
  ensure => present,
  value  => '2',
} ->
cs_property { 'no-quorum-policy':
  ensure => present,
  value  => 'ignore',
} ->
cs_property { 'stonith-enabled':
  ensure => present,
  value  => false,
} ->
cs_property { 'placement-strategy':
  ensure => absent,
  value  => 'default',
} ->
cs_resource { 'bar':
  ensure          => present,
  primitive_class => 'ocf',
  provided_by     => 'pacemaker',
  primitive_type  => 'Dummy',
  operations      => {
    'monitor'  => {
      'interval' => '20'
    }
  },
} ->
cs_resource { 'blort':
  ensure          => present,
  primitive_class => 'ocf',
  provided_by     => 'pacemaker',
  primitive_type  => 'Dummy',
  multistate_hash => { type => 'master' },
  operations      => {
    'monitor' => {
      'interval' => '20'
    },
    'start'   => {
      'interval' => '0',
      'timeout'  => '20'
    }
  },
} ->
cs_resource { 'foo':
  ensure          => present,
  primitive_class => 'ocf',
  provided_by     => 'pacemaker',
  primitive_type  => 'Dummy',
} ->
cs_colocation { 'foo-with-bar':
  ensure     => present,
  primitives => [ 'foo', 'bar' ],
  score      => 'INFINITY',
} ->
cs_colocation { 'bar-with-blort':
  ensure     => present,
  primitives => [ 'bar', 'ms_blort' ],
  score      => 'INFINITY',
} ->
cs_order { 'foo-before-bar':
  ensure => present,
  first  => 'foo',
  second => 'bar',
  score  => 'INFINITY',
}
