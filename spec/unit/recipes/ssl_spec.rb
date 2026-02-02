# frozen_string_literal: true

require 'spec_helper'

describe 'nginx::default' do
  context 'with SSL enabled on Ubuntu 22.04' do
    platform 'ubuntu', '22.04'

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['nginx']['ssl']['enabled'] = true
        node.normal['nginx']['ssl']['certificate'] = '/etc/ssl/certs/server.crt'
        node.normal['nginx']['ssl']['certificate_key'] = '/etc/ssl/private/server.key'
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs nginx package' do
      expect(chef_run).to install_package('nginx-core')
    end

    it 'enables nginx service' do
      expect(chef_run).to enable_service('nginx')
    end
  end

  context 'with HTTP/2 and TLS 1.3 on Ubuntu 24.04' do
    platform 'ubuntu', '24.04'

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04') do |node|
        node.normal['nginx']['ssl']['enabled'] = true
        node.normal['nginx']['ssl']['protocols'] = 'TLSv1.2 TLSv1.3'
        node.normal['nginx']['http2']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
