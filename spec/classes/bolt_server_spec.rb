# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_bolt_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          puppet_token: sensitive('secret_token_here'),
          bolt_log_level: 'trace'
        }
      end

      it { is_expected.to compile }
      it { is_expected.to have_resource_count(11) }

      context 'installs bolt' do
        it { is_expected.to contain_package('puppet-tools-release') }
        it { is_expected.to contain_package('puppet-bolt') }
      end

      context 'configures bolt' do
        it { is_expected.to contain_file('/root/.puppetlabs') }
        it { is_expected.to contain_file('/root/.puppetlabs/bolt') }
        it { is_expected.to contain_file('/root/.puppetlabs/etc') }
        it { is_expected.to contain_file('/root/.puppetlabs/etc/bolt') }
        it { is_expected.to contain_file('puppet-token') }
        it {
          is_expected.to contain_file('/root/.puppetlabs/bolt/bolt-project.yaml')
            .with_content(%r{level: trace})
        }
        it {
          is_expected.to contain_file('/root/.puppetlabs/etc/bolt/bolt-defaults.yaml')
            .with_content(%r{service-url: https://puppet.example.com:8143})
        }
        it { is_expected.to contain_file('/var/log/puppetlabs/bolt-server') }
        it { is_expected.to contain_file('/var/log/puppetlabs/bolt-server/bolt-server.log') }
      end
    end
  end
end
