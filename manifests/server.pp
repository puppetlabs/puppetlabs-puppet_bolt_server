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

  file { '/root/.puppetlabs/etc/bolt/bolt-defaults.yaml':
    ensure  => present,
    content => to_yaml({
      'analytics'   => false,
      'inventory-config'  => {
        'transport' => 'pcp',
        'pcp'       => {
          'cacert'           => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
          'service-url'      => 'https://ip-10-138-1-227.eu-central-1.compute.internal:8143',
          'token-file'       => '~/.puppetlabs/token',
          'task-environment' => 'production',
        },
      },
      'puppetdb' => {
        'server_urls' => ['http://localhost:8080'],
      },
    }),
    require => Package['puppet-bolt'],
  }
}
