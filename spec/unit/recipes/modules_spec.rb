# frozen_string_literal: true

require 'spec_helper'

describe 'nginx::default' do
  context 'with modules enabled on Ubuntu 22.04' do
    platform 'ubuntu', '22.04'

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['nginx']['modules'] = %w(http_ssl http_v2 http_geoip http_stub_status)
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs nginx package' do
      expect(chef_run).to install_package('nginx')
    end
  end

  context 'with brotli module on Ubuntu 22.04' do
    platform 'ubuntu', '22.04'

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['nginx']['modules'] = ['ngx_brotli']
        node.normal['nginx']['brotli']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end

  context 'with geoip2 module on Rocky Linux 9' do
    platform 'rocky', '9'

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'rocky', version: '9') do |node|
        node.normal['nginx']['modules'] = ['ngx_http_geoip2_module']
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
