# frozen_string_literal: true

require 'spec_helper'

describe 'nginx::default' do
  context 'on Ubuntu 22.04' do
    platform 'ubuntu', '22.04'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs nginx package' do
      expect(chef_run).to install_package('nginx')
    end

    it 'enables nginx service' do
      expect(chef_run).to enable_service('nginx')
    end

    it 'starts nginx service' do
      expect(chef_run).to start_service('nginx')
    end

    it 'creates nginx configuration directory' do
      expect(chef_run).to create_directory('/etc/nginx')
    end

    it 'creates nginx.conf from template' do
      expect(chef_run).to create_template('/etc/nginx/nginx.conf')
    end
  end

  context 'on Rocky Linux 9' do
    platform 'rocky', '9'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs nginx package' do
      expect(chef_run).to install_package('nginx')
    end
  end

  context 'on Amazon Linux 2023' do
    platform 'amazon', '2023'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
