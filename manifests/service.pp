class activemq::service (
) {

  service { 'activemq':
    ensure     => running,
    name       => 'activemq',
    hasrestart => true,
    hasstatus  => false,
    enable     => true,
  }
}
