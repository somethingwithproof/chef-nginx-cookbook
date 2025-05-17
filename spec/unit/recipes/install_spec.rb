#
# Cookbook:: nginx
# Spec:: install
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

describe 'nginx::install' do
  context 'When all attributes are default, on Ubuntu 20.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '20.04').converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs nginx using the nginx_install resource' do
      expect(chef_run).to install_nginx_install('default')
    end
  end

  context 'When using package installation method, on Ubuntu 20.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '20.04') do |node|
        node.default['nginx']['install_method'] = 'package'
        node.default['nginx']['version'] = '1.18.0'
      end.converge(described_recipe)
    end

    it 'installs nginx using the package method' do
      expect(chef_run).to install_nginx_install('default').with(
        install_method: 'package',
        version: '1.18.0'
      )
    end
  end

  context 'When using source installation method, on Ubuntu 20.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '20.04') do |node|
        node.default['nginx']['install_method'] = 'source'
        node.default['nginx']['version'] = '1.20.0'
        node.default['nginx']['source']['configure_flags'] = ['--with-http_ssl_module']
      end.converge(described_recipe)
    end

    it 'installs nginx using the source method' do
      expect(chef_run).to install_nginx_install('default').with(
        install_method: 'source',
        version: '1.20.0',
        configure_flags: ['--with-http_ssl_module']
      )
    end
  end
end
