# frozen_string_literal: true

# Load the BoltSpec library
require 'bolt_spec/plans'

# # Configure Puppet and Bolt for testing
# enabling the `BoltSpec::Plans.init` line makes unit test fail with:
# 1) puppet_bolt_server on oraclelinux-7-x86_64 is expected to compile into a catalogue without dependency cycles
# Failure/Error: it { is_expected.to compile }
#   error during compilation: Could not parse for environment rp_env: A Resource Statement is only available when compiling a catalog (line: 2, column: 1) on node macbook-pro.localdomain
# ./spec/classes/bolt_server_spec.rb:11:in `block (4 levels) in <top (required)>'
# BoltSpec::Plans.init

# # This environment variable can be read by Ruby Bolt tasks to prevent unwanted
# # auto-execution, enabling easy unit testing.
ENV['RSPEC_UNIT_TEST_MODE'] ||= 'TRUE'

require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
