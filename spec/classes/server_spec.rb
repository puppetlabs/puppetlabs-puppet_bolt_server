# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_bolt_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { { puppet_token: sensitive('secret_token_here') } }

      it { is_expected.to compile }
      it { is_expected.to have_resource_count(5) }

      context 'installs bolt' do
        it { is_expected.to contain_package('puppet-tools-release') }
        it { is_expected.to contain_package('puppet-bolt') }
      end

      context 'configures bolt' do
        it { is_expected.to contain_file('puppet-token') }
        it { is_expected.to contain_file('/root/.puppetlabs/bolt/bolt-project.yaml') }
        it { is_expected.to contain_file('/root/.puppetlabs/etc/bolt/bolt-defaults.yaml') }
      end
    end
  end
end
