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
# @param bolt_log_level
#   This Enum (String) configures the log level in the bolt-project configuration file
#   By default the log level is set to 'debug'
#   For more information, please read the Bolt logs doc:
#     https://puppet.com/docs/bolt/latest/logs.html#log-levels
#
class puppet_bolt_server (
  Sensitive[String] $puppet_token,
  Enum['trace', 'debug', 'info', 'warn', 'error', 'fatal'] $bolt_log_level  = 'debug',
) {
  package { 'puppet-tools-release':
    ensure => present,
    source => "https://yum.puppet.com/puppet-tools-release-el-${facts['os']['release']['major']}.noarch.rpm",
  }

  package { 'puppet-bolt':
    ensure  => '3.26.2',
    name    => 'puppet-bolt',
    require => Package['puppet-tools-release'],
  }

  $pl_root = '/root/.puppetlabs'
  file { [$pl_root, "${pl_root}/bolt", "${pl_root}/etc", "${pl_root}/etc/bolt"]:
    ensure => directory,
  }

  file { 'puppet-token':
    ensure  => file,
    path    => '/root/.puppetlabs/token',
    content => $puppet_token.unwrap,
    require => File[$pl_root],
  }

  $pl_logs_base = '/var/log/puppetlabs'
  file { "${pl_logs_base}/bolt-server":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    recurse => true,
    mode    => '0750',
  }

  file { "${pl_logs_base}/bolt-server/bolt-server.log":
    ensure  => file,
    require => File["${pl_logs_base}/bolt-server"],
  }

  file { '/root/.puppetlabs/bolt/bolt-project.yaml':
    ensure  => file,
    content => to_yaml( {
        'modulepath' => [
          '/etc/puppetlabs/code/environments/production/site-modules',
          '/etc/puppetlabs/code/environments/production/modules',
        ],
        'log'        => {
          'bolt-debug.log'                                  => disable,
          '/var/log/puppetlabs/bolt-server/bolt-server.log' => {
            'append' => true,
            'level'  => $bolt_log_level,
          },
        },
    }),
    require => File["${pl_root}/bolt"],
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
    require => File['puppet-token', "${pl_root}/etc/bolt"],
  }
}
