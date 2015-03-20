class activemq::package::tarball (
  $version      = $activemq::version,
  $home         = $activemq::home,
  $user         = $activemq::user,
  $group        = $activemq::group,
  $system_user  = $activemq::system_user,
  $manage_user  = $activemq::manage_user,
  $manage_group = $activemq::manage_group,
  $src_wrapper  = $activemq::src_wrapper,
) {

  if $manage_user {
    if ! defined (User[$user]) {
      user { $user:
        ensure     => present,
        home       => "${home}/${user}",
        managehome => false,
        system     => $system_user,
        before     => Archive["apache-activemq-${version}-bin"],
      }
    }
  }

  if $manage_group {
    if ! defined (Group[$group]) {
      group { $group:
        ensure => present,
        system => $system_user,
        before => Archive["apache-activemq-${version}-bin"],
      }
    }
  }

  # puppet-archive from https://github.com/camptocamp/puppet-archive
  archive { "apache-activemq-${version}-bin":
    ensure   => present,
    url      => "${activemq::apache_mirror}/activemq/${version}/apache-activemq-${version}-bin.tar.gz",
    target   => $home,
    root_dir => "apache-activemq-${version}",
    # checksum false due to puppet-archive expecting "md5 filename" but activemq only providing "md5"
    checksum => false,
  } ->
  file { $home:
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    recurse => true,
  } ->
  file { "${home}/current":
    ensure => "${home}/apache-activemq-${version}",
    owner  => $user,
    group  => $group,
  } ->
  file { '/etc/activemq':
    ensure  => "${home}/current/conf",
  } ->
  file { '/var/log/activemq':
    ensure  => "${home}/current/data",
  } ->
  file { "${home}/current/bin/linux":
    ensure  => "${home}/current/bin/linux-x86-64",
  } ->
  file { '/var/run/activemq':
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  } ->
  file { '/etc/init.d/activemq':
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('activemq/activemq-init.d.erb'),
  } ~>
  Service['activemq']

  if $src_wrapper {
    file { 'wrapper.conf':
      path    => $activemq::wrapper,
      owner   => $user,
      group   => $group,
      mode    => '0644',
      source  => $src_wrapper,
      require => File['/etc/init.d/activemq'],
      notify  => Service['activemq'],
    }
  } else {
    file { 'wrapper.conf':
      path    => $activemq::wrapper,
      owner   => $user,
      group   => $group,
      mode    => '0644',
      content => template('activemq/wrapper.conf.erb'),
      require => File['/etc/init.d/activemq'],
      notify  => Service['activemq'],
    }
  }
}
