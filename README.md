# puppet_bolt_server

This module installs and configures Bolt to use a local PuppetDB and the PCP transport

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with puppet_bolt_server](#setup)
    * [What puppet_bolt_server affects](#what-puppet_bolt_server-affects)
1. [Installation - Step by step guide](#installation)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)

## Description

The goal of this module is to configure a dedicated Puppet Enterprise compiler to become a Bolt Server, with the intention of helping Orchestrator by taking the majority of the load when performing multiple concurrent plans runs. A compiler is ideal because it already has access to Puppet Enterprise, code manager and to its local PuppetDB.

## Setup

### What puppet_bolt_server affects

The `puppet_bolt_server` module will perform the following activities:

* Install Bolt in the server
* Create the `/root/.puppetlabs/etc/bolt/bolt-defaults.yaml` file with custom configuration to:
    * Use the PCP protocol
    * Use the local PuppetDB
    * Consume a Puppet token

## Installation

**Quickstart:** Configure the `puppet_bolt_server` using the PE Console

This setup will help you to quickly configure the `puppet_bolt_server` in your existing PE server.

1. Add the [puppetlabs_puppet_bolt_server](https://github.com/puppetlabs/puppetlabs-puppet_bolt_server) to your control repo.
1. Add a new Node Group from the PE Console

```
  Parent name: PE Infrastructure
  Group name: Bolt Server
  Environment: production
```

1. Add the class `puppet_bolt_server` to the Bolt Sever group created in the step above.
1. Add your dedicated compiler to the group using the Rules tab.
1. Add your puppet token (Sensitive string) in the Configuration data tab
    1. Tip: Generate a token with a lifetime of 1 year: `puppet access login --lifetime 1y`

```
  Class: puppet_bolt_server
  Parameter: puppet_token
  Value: 'insert-your-puppet-token-here'
```

1. Commit your changes.
1. Run Puppet on this Node Group.

## Usage

After Puppet applies the changes described in the installation steps, you should end up with the following files in the Bolt server:

- `/root/.puppetlabs/etc/bolt/bolt-defaults.yaml`
- `/root/.puppetlabs/token`

To test that everything was configured properly, we can run any Bolt plan that runs a PuppetDB query, for example:

```
# /root/Projects/local_plan/plans/test.pp

plan local_plan::test(
){
  $query_results = puppetdb_query("nodes[]{}")
  out::message("Hello world from the Bolt Server, query results: ${query_results}")
}
```

Run the Bolt plan:

`bolt plan run local_plan::test`

We should see the PuppetDB query results in the terminal, and if we inspect the `puppetdb-access.log` there should be a log with a call to the local PuppetDB with a 200 Ok HTTP status:

```
$ less /var/log/puppetlabs/puppetdb/puppetdb-access.log

127.0.0.1 - - [01/Nov/2022:15:56:21 +0000] "POST /pdb/query/v4 HTTP/1.1" 200 1793 "-" "HTTPClient/1.0 (2.8.3, ruby 2.7.6 (2022-04-12))" 99 21 -
```


## Limitations

- This first version of the `puppet_bolt_server` can only run on RHEL 7 and 8 based systems.
- Requires Puppet ">= 6.21.0 < 8.0.0"
- **Warning** There is no rate limit to run Plans, we tested this module in our lab and it successfully handled up to 200 concurrent plans with a Bolt Server with the following specs:
    - 8 GB RAM
    - CPU Intel Xeon Platinum 8000 series, 4-cores

