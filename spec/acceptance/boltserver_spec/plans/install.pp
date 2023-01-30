plan boltserver_spec::install (
) {
  $t = get_targets('*')
  wait_until_available($t)

  # determine certnames
  parallelize($t) |$target| {
    $fqdn = run_command('hostname -f', $target)
    $target.set_var('certname', $fqdn.first['stdout'].chomp)
  }

  # filter out the primary and the compiler
  $primary_host = $t.filter |$n| { $n.vars['role'] == 'primary' }[0]
  $compiler_host = $t.filter |$n| { $n.vars['role'] == 'compiler' }[0]

  out::message("Primary host name: ${primary_host.uri} [${primary_host.vars['certname']}]")
  out::message("Compiler host name: ${compiler_host.uri} [${compiler_host.vars['certname']}]")

  # generate an rbac token
  run_task('peadm::rbac_token', $primary_host, 'Create rbac token', { password => 'puppetlabs', token_lifetime => '1y' })
  $token = run_task('peadm::read_file', $primary_host, 'path' => '/root/.puppetlabs/token').first['content'].chomp

  # apply the puppet_bolt_server class
  apply_prep($compiler_host)
  apply($compiler_host) {
    class { 'puppet_bolt_server':
      puppet_token => Sensitive($token),
    }
  }

  # run a plan using bolt
  $plandir = '/tmp/local_plan'
  run_command("rm -rf ${plandir}", $compiler_host)
  upload_file('boltserver_spec/local_plan', $plandir, $compiler_host)
  $out = run_script('boltserver_spec/run_local_plan.sh', $compiler_host, arguments => [$plandir, 'local_plan::test'])

  # parse the output
  $string = $out.first['stdout']
  $clean_string = regsubst($string,'.*\[','[', 'M')
  $json = parsejson($clean_string)
  if $json.length == 0 {
    fail_plan('No results returned from bolt plan')
  }
  out::message('Acceptance test successful')
}
