# @summary Bolt Server
#
# This class installs and configures Bolt
#
class puppet_bolt_server (
  Sensitive[String] $puppet_token,
  # Optional[String]  $puppet_token = undef,
) {
  package { 'puppet-tools-release':
    ensure => present,
    source => "https://yum.puppet.com/puppet-tools-release-el-${facts['os']['release']['major']}.noarch.rpm",
  }

  package { 'puppet-bolt':
    ensure  => present,
    name    => 'puppet-bolt',
    require => Package['puppet-tools-release'],
  }

  file { 'puppet-token':
    ensure  => file,
    path    => '/root/.puppetlabs/token',
    content => $puppet_token.unwrap,
  }

  file { '/root/.puppetlabs/etc/bolt/bolt-defaults.yaml':
    ensure  => file,
    content => to_yaml( {
        'analytics'        => false,
        'inventory-config' => {
          'transport' => 'pcp',
          'pcp'       => {
            'cacert'           => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
            'service-url'      => "https://${facts['puppet_server']}:8143",
            'token-file'       => '~/.puppetlabs/token',
            'task-environment' => 'production',
          },
        },
        'puppetdb'         => {
          'server_urls' => ['http://localhost:8080'],
        },
    }),
    require => File['puppet-token'],
  }
}
