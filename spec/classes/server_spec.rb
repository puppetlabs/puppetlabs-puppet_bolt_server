# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_bolt_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { {
        puppet_token: sensitive('secret_token_here')
       }
      }

      it { is_expected.to compile }
    end
  end
end
