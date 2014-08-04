class activemq::package::mysql_connector (
  $version = 'present',
) {
  package { 'mysql-connector-java':
    ensure => $version,
  }
}
