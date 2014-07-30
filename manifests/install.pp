class activemq::install (
  $package_type,
  $version,
) {
  class { "activemq::package::${package_type}":
    version =>  $version,
  }
}
