plan boltserver_spec::install ()
{
  $t = get_targets('*')
  wait_until_available($t)

  parallelize($t) |$target| {
    $fqdn = run_command('hostname -f', $target)
    $target.set_var('certname', $fqdn.first['stdout'].chomp)
  }

  $primary_host = $t.filter |$n| { $n.vars['role'] == 'primary' }
  $compiler_hosts = $t.filter |$n| { $n.vars['role'] == 'compiler' }

  out::message("Primary host: ${primary_host.name}")
  out::message("Compiler hosts: ${compiler_hosts}")
}
