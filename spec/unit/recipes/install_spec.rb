# frozen_string_literal: true

require 'spec_helper'

describe 'nginx::install' do
  context 'on Ubuntu 22.04 with package install method' do
    platform 'ubuntu', '22.04'

    before do
      stub_command('test -f /etc/apt/sources.list.d/nginx.list').and_return(false)
    end

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['nginx']['install_method'] = 'package'
        node.normal['nginx']['package_name'] = 'nginx'
      end
      runner.converge(described_recipe)
    end

    it 'installs nginx package' do
      expect(chef_run).to install_package('nginx')
    end

    it 'updates apt cache' do
      expect(chef_run).to update_apt_update('nginx')
    end
  end

  context 'on CentOS 8 with package install method' do
    platform 'centos', '8'

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '8') do |node|
        node.normal['nginx']['install_method'] = 'package'
        node.normal['nginx']['package_name'] = 'nginx'
      end
      runner.converge(described_recipe)
    end

    it 'installs nginx package' do
      expect(chef_run).to install_package('nginx')
    end

    it 'creates the nginx yum repository' do
      expect(chef_run).to create_yum_repository('nginx')
    end

    it 'includes yum-epel cookbook' do
      expect(chef_run).to include_recipe('yum-epel::default')
    end
  end

  context 'on Ubuntu 22.04 with source install method' do
    platform 'ubuntu', '22.04'

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['nginx']['install_method'] = 'source'
        node.normal['nginx']['version'] = '1.24.0'
        node.normal['nginx']['source']['url'] = 'https://nginx.org/download/nginx-1.24.0.tar.gz'
        node.normal['nginx']['source']['dependencies'] = %w(libpcre3-dev zlib1g-dev libssl-dev)
        node.normal['nginx']['source']['configure_options'] = ['--with-http_ssl_module']
        node.normal['nginx']['source']['prefix'] = '/usr/local/nginx'
        node.normal['nginx']['user'] = 'nginx'
        node.normal['nginx']['group'] = 'nginx'
        node.normal['nginx']['log_dir'] = '/var/log/nginx'
        node.normal['nginx']['conf_dir'] = '/etc/nginx'
        node.normal['nginx']['binary'] = '/usr/sbin/nginx'
        node.normal['nginx']['pid_file'] = '/var/run/nginx.pid'
        node.normal['nginx']['error_log'] = '/var/log/nginx/error.log'
        node.normal['nginx']['access_log'] = '/var/log/nginx/access.log'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('/usr/sbin/nginx -v 2>&1').and_return('')
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/usr/sbin/nginx').and_return(false)
    end

    it 'installs build essential' do
      expect(chef_run).to install_build_essential('install_build_tools')
    end

    it 'creates nginx group' do
      expect(chef_run).to create_group('nginx')
    end

    it 'creates nginx user' do
      expect(chef_run).to create_user('nginx')
    end

    it 'creates log directory' do
      expect(chef_run).to create_directory('/var/log/nginx')
    end

    it 'creates conf directory' do
      expect(chef_run).to create_directory('/etc/nginx')
    end
  end
end
