#
# Cookbook:: nginx
# Spec:: default
#
# Copyright:: 2023-2025, Thomas Vincent
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe 'nginx::default' do
  context 'When all attributes are default, on Ubuntu 20.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '20.04') do |node|
        node.default['nginx']['telemetry']['enabled'] = false
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'includes the install recipe' do
      expect(chef_run).to include_recipe('nginx::install')
    end

    it 'includes the configure recipe' do
      expect(chef_run).to include_recipe('nginx::configure')
    end

    it 'includes the service recipe' do
      expect(chef_run).to include_recipe('nginx::service')
    end

    it 'includes the sites recipe' do
      expect(chef_run).to include_recipe('nginx::sites')
    end

    it 'includes the security recipe' do
      expect(chef_run).to include_recipe('nginx::security')
    end

    it 'does not include the telemetry recipe when telemetry is disabled' do
      expect(chef_run).to_not include_recipe('nginx::telemetry')
    end
  end

  context 'When telemetry is enabled, on Ubuntu 20.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '20.04') do |node|
        node.default['nginx']['telemetry']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'includes the telemetry recipe when telemetry is enabled' do
      expect(chef_run).to include_recipe('nginx::telemetry')
    end
  end
end
