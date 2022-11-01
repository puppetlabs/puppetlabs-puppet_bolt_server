# @summary Bolt Server
#
# This class installs and configures Bolt
#
class puppet_bolt_server::server (
  Sensitive[String] $puppet_token,
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

  file { 'puppet-token':
    ensure  => present,
    path    => '/root/.puppetlabs/token',
    content => "${puppet_token.unwrap}",
    require => Package['puppet-bolt'],
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
    require => File['puppet-token'],
  }
}
