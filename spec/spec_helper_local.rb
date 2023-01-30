# frozen_string_literal: true

# Load the BoltSpec library
require 'bolt_spec/plans'

# Configure Puppet and Bolt for testing
BoltSpec::Plans.init

# This environment variable can be read by Ruby Bolt tasks to prevent unwanted
# auto-execution, enabling easy unit testing.
ENV['RSPEC_UNIT_TEST_MODE'] ||= 'TRUE'

require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
