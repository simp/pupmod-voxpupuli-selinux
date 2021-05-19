require 'spec_helper'

describe 'vox_selinux' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'config' do
        context 'invalid type' do
          let(:params) { { type: 'invalid' } }

          it { is_expected.to compile.and_raise_error(%r{Enum}) }
        end
        context 'undef type' do
          it { is_expected.to have_file_resource_count(0) }
          it { is_expected.to have_file_line_resource_count(0) }
          it { is_expected.to have_exec_resource_count(0) }
          it { is_expected.not_to contain_file_line('set-selinux-config-type-to-targeted') }
          it { is_expected.not_to contain_file_line('set-selinux-config-type-to-minimum') }
          it { is_expected.not_to contain_file_line('set-selinux-config-type-to-mls') }
        end
        context 'targeted' do
          let(:params) { { type: 'targeted' } }

          it { is_expected.to contain_file_line('set-selinux-config-type-to-targeted').with(line: 'SELINUXTYPE=targeted') }
        end
        context 'minimum' do
          let(:params) { { type: 'minimum' } }

          it { is_expected.to contain_file_line('set-selinux-config-type-to-minimum').with(line: 'SELINUXTYPE=minimum') }
        end

        context 'mls' do
          let(:params) { { type: 'mls' } }

          it { is_expected.to contain_file_line('set-selinux-config-type-to-mls').with(line: 'SELINUXTYPE=mls') }
        end
      end
    end
  end
end
