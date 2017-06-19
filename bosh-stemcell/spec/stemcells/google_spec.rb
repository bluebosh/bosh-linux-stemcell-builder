require 'spec_helper'

describe 'Google Stemcell', stemcell_image: true do
  it_behaves_like 'udf module is disabled'

  context 'installed by system_parameters' do
    describe file('/var/vcap/bosh/etc/infrastructure') do
      its(:content) { should include('google') }
    end
  end

  context 'installed by bosh_disable_password_authentication' do
    describe 'disallows password authentication' do
      subject { file('/etc/ssh/sshd_config') }

      its(:content) { should match /^PasswordAuthentication no$/ }
    end
  end

  context 'installed by system_google_packages' do
    describe 'Google agent has configuration file' do
      subject { file('/etc/default/instance_configs.cfg.template') }

      it { should be_file }
      it { should be_owned_by('root') }
      its(:group) { should eq('root') }
    end

    case ENV['OS_NAME']
      when 'ubuntu'
        [
            '/etc/init/google-accounts-daemon.conf',
            '/etc/init/google-clock-skew-daemon.conf',
            '/etc/init/google-instance-setup.conf',
            '/etc/init/google-ip-forwarding-daemon.conf',
            '/etc/init/google-network-setup.conf',
            '/etc/init/google-shutdown-scripts.conf',
            '/etc/init/google-startup-scripts.conf',
            '/usr/bin/google_instance_setup',
            '/usr/bin/google_ip_forwarding_daemon',
            '/usr/bin/google_accounts_daemon',
            '/usr/bin/google_clock_skew_daemon',
            '/usr/bin/google_metadata_script_runner',
        ].each do |conf_file|
          describe file(conf_file) do
            it { should be_file }
            it { should be_owned_by('root') }
            its(:group) { should eq('root') }
          end
        end
      when 'centos', 'rhel'
        [
            '/usr/lib/systemd/system/google-accounts-daemon.service',
            '/usr/lib/systemd/system/google-clock-skew-daemon.service',
            '/usr/lib/systemd/system/google-instance-setup.service',
            '/usr/lib/systemd/system/google-ip-forwarding-daemon.service',
            '/usr/lib/systemd/system/google-network-setup.service',
            '/usr/lib/systemd/system/google-shutdown-scripts.service',
            '/usr/lib/systemd/system/google-startup-scripts.service',
            '/usr/bin/google_instance_setup',
            '/usr/bin/google_ip_forwarding_daemon',
            '/usr/bin/google_accounts_daemon',
            '/usr/bin/google_clock_skew_daemon',
            '/usr/bin/google_metadata_script_runner',
        ].each do |conf_file|
          describe file(conf_file) do
            it { should be_file }
            it { should be_owned_by('root') }
            its(:group) { should eq('root') }
          end
        end
    end
  end
end
