class activemq::service (
) {

  service { 'activemq':
    ensure     => running,
    hasrestart => true,
    hasstatus  => false,
    enable     => true,
  }
}
