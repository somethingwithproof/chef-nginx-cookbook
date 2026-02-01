# frozen_string_literal: true

require 'spec_helper'

describe 'nginx::service' do
  context 'on Ubuntu 22.04' do
    platform 'ubuntu', '22.04'

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['nginx']['service_name'] = 'nginx'
        node.normal['nginx']['service_actions'] = %w(enable start)
      end
      runner.converge(described_recipe)
    end

    it 'enables the nginx service' do
      expect(chef_run).to enable_service('nginx')
    end

    it 'starts the nginx service' do
      expect(chef_run).to start_service('nginx')
    end
  end

  context 'on CentOS 8' do
    platform 'centos', '8'

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '8') do |node|
        node.normal['nginx']['service_name'] = 'nginx'
        node.normal['nginx']['service_actions'] = %w(enable start)
      end
      runner.converge(described_recipe)
    end

    it 'enables the nginx service' do
      expect(chef_run).to enable_service('nginx')
    end

    it 'starts the nginx service' do
      expect(chef_run).to start_service('nginx')
    end
  end
end
