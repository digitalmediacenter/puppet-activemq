class activemq::service (
) inherits activemq::params {

  service { 'activemq':
    ensure     => running,
    name       => 'activemq',
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => Anchor['activemq::package::end'],
  }
}
