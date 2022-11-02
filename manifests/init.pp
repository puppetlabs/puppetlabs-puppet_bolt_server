# @summary
#   This Bolt Server module will install and configure Bolt to use the PCP protocol
#
# @example Basic usage
#   include puppet_bolt_server
#
# @param puppet_token
#   This should be a token with permissions to launch Orchestrator jobs.  
#   Generate a token with a lifetime of 1 year: puppet access login --lifetime 1y 
#
class puppet_bolt_server (
  Sensitive[String] $puppet_token,
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
    content => to_yaml ( {
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
