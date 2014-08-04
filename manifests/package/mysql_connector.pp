class activemq::package::mysql_connector (
  $version = 'present',
) {
  package { 'mysql-connector-java':
    ensure => $version,
  }

  file {"${activemq::home}/activemq/lib/mysql-connector-java.jar":
    ensure => 'link',
    target => '/usr/share/java/mysql-connector-java.jar',
  }
}
