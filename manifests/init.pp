# Copyright 2011 MaestroDev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This activemq class is currently targeting an X86_64 deploy, adjust as needed

class activemq (
  $apache_mirror                 = $activemq::params::apache_mirror,
  $version                       = '5.10.0',
  $home                          = $activemq::params::home,
  $user                          = $activemq::params::user,
  $group                         = $activemq::params::group,
  $system_user                   = $activemq::params::system_user,
  $manage_user                   = $activemq::params::manage_user,
  $manage_group                  = $activemq::params::manage_group,
  $max_memory                    = $activemq::params::max_memory,
  $console                       = $activemq::params::console,
  $package_type                  = $activemq::params::package_type,
  $architecture_flag             = $activemq::params::architecture_flag,
  $src_activemqxml               = undef,
  $src_brokerks                  = undef,
  $src_brokerlocalhostcert       = undef,
  $src_brokerts                  = undef,
  $src_camelxml                  = undef,
  $src_clientks                  = undef,
  $src_clientts                  = undef,
  $src_credentialsencproperties  = undef,
  $src_credentialsproperties     = undef,
  $src_groupsproperties          = undef,
  $src_jettyrealmproperties      = undef,
  $src_jettyxml                  = undef,
  $src_jmxaccess                 = undef,
  $src_jmxpassword               = undef,
  $src_log4jproperties           = undef,
  $src_loggingproperties         = undef,
  $src_loginconfig               = undef,
  $src_usersproperties           = undef,
  $src_wrapper                   = undef,
) inherits activemq::params {

  validate_re($package_type, '^rpm$|^tarball$')

  if $src_activemqxml and (!$console or defined(Class['activemq::stomp'])) {
    fail('If you set src_activemqxml, console needs to be true and activemq::stomp must not be defined.')
  }

  if $src_wrapper and $max_memory {
    notice('Since src_wrapper is set, you need to manage max_memory yourself!')
  }

  if $src_wrapper and $package_type != 'tarball' {
    fail('src_wrapper will only be set if package_type is set to tarball')
  }

  $wrapper = $package_type ? {
    'tarball' => "${home}/current/bin/linux-x86-${architecture_flag}/wrapper.conf",
    'rpm'     => '/etc/activemq/activemq-wrapper.conf',
  }

  case $package_type {
    'tarball': {
      anchor { 'activemq::package::begin': } -> Class['activemq::package::tarball'] -> anchor { 'activemq::package::end': }
      class { 'activemq::package::tarball':
        version     => $version,
        src_wrapper => $src_wrapper,
      }
    }
    'rpm': {
      anchor { 'activemq::package::begin': } -> Class['activemq::package::rpm'] -> anchor { 'activemq::package::end': }
      class { 'activemq::package::rpm':
        version => $version,
      }
    }
    default: {
      fail("Invalid ActiveMQ package type: ${package_type}")
    }
  }

  if ! $console {
    augeas { 'activemq-console':
      changes => [ 'rm beans/import' ],
      incl    => "${home}/conf/activemq.xml",
      lens    => 'Xml.lns',
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }

  if $max_memory != undef and $src_wrapper == undef {
    augeas { 'activemq-maxmemory':
      changes => [ "set wrapper.java.maxmemory ${max_memory}" ],
      incl    => $wrapper,
      lens    => 'Properties.lns',
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }

  if $src_activemqxml {
    file { "${home}/current/conf/activemq.xml":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_activemqxml,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_brokerks {
    file { "${home}/current/conf/broker.ks":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_brokerks,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_brokerlocalhostcert {
    file { "${home}/current/conf/broker-localhost.cert":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_brokerlocalhostcert,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_brokerts {
    file { "${home}/current/conf/broker.ts":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_brokerts,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_camelxml {
    file { "${home}/current/conf/camel.xml":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_camelxml,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_clientks {
    file { "${home}/current/conf/client.ks":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_clientks,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_clientts {
    file { "${home}/current/conf/client.ts":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_clientts,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_credentialsencproperties {
    file { "${home}/current/conf/credentials-enc.properties":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_credentialsencproperties,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_credentialsproperties {
    file { "${home}/current/conf/credentials.properties":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_credentialsproperties,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_groupsproperties {
    file { "${home}/current/conf/groups.properties":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_groupsproperties,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_jettyrealmproperties {
    file { "${home}/current/conf/jetty-realm.properties":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_jettyrealmproperties,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_jettyxml {
    file { "${home}/current/conf/jetty.xml":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_jettyxml,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_jmxaccess {
    file { "${home}/current/conf/jmx.access":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_jmxaccess,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_jmxpassword {
    file { "${home}/current/conf/jmx.password":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_jmxpassword,
      mode    => '0600',
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  } else {
    file { "${home}/current/conf/jmx.password":
      ensure  => file,
      owner   => $user,
      group   => $group,
      mode    => '0600',
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_log4jproperties {
    file { "${home}/current/conf/log4j.properties":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_log4jproperties,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_loggingproperties {
    file { "${home}/current/conf/logging.properties":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_loggingproperties,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_loginconfig {
    file { "${home}/current/conf/login.config":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_loginconfig,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }
  if $src_usersproperties {
    file { "${home}/current/conf/users.properties":
      ensure  => file,
      owner   => $user,
      group   => $group,
      source  => $src_usersproperties,
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }



  class { 'activemq::service': }
}
