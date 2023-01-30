plan boltserver_spec::install (

) {
  $t = get_targets('*')
  wait_until_available($t)

  parallelize($t) |$target| {
    $fqdn = run_command('hostname -f', $target)
    $target.set_var('certname', $fqdn.first['stdout'].chomp)
  }

  $primary_host = $t.filter |$n| { $n.vars['role'] == 'primary' }[0]
  $compiler_host = $t.filter |$n| { $n.vars['role'] == 'compiler' }[0]

  out::message("Primary host name: ${primary_host.uri} [${primary_host.vars['certname']}]")
  out::message("Compiler host name: ${compiler_host.uri} [${compiler_host.vars['certname']}]")

  run_task('peadm::rbac_token', $primary_host, 'Create rbac token', { password => 'puppetlabs', token_lifetime => '1y' })
  $token = run_task('peadm::read_file', $primary_host, 'path' => '/root/.puppetlabs/token').first['content'].chomp
  out::message('Applying puppet_bolt_server::install to compiler')
  apply_prep($compiler_host)
  apply($compiler_host) {
    class { 'puppet_bolt_server':
      puppet_token => Sensitive($token),
    }
  }
}
