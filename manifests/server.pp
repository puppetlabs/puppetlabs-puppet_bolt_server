# @summary Bolt Server
#
# This class installs and configures Bolt
#
class puppet_bolt_server::server (
  # Optional[String] $package_source = 'https://yum.puppet.com/puppet-tools-release-el-8.noarch.rpm'
) {
  package { 'puppet-tools-release':
    ensure => present,
    source => "https://yum.puppet.com/puppet-tools-release-el-${facts['os']['release']['major']}.noarch.rpm",
  }

  package { 'puppet-bolt':
    name    => 'puppet-bolt',
    ensure  => present,
    require => Package['puppet-tools-release'],
  }
}
