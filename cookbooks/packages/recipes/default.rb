#
# Cookbook Name:: packages
# Recipe:: default
#
# Copyright 2013-2016, Chef Software, Inc.
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
#

Chef::Log.info "packages:#{node['packages-cookbook'].inspect}"

case node['packages-cookbook']
when Array
  return if node['packages-cookbook'].empty?
  if multipackage_supported?
    package node['packages-cookbook'] do
      action node['packages-cookbook_default_action'].to_sym
    end
  else
    node['packages-cookbook'].each do |pkg|
      package pkg do
        action node['packages-cookbook_default_action'].to_sym
      end
    end
  end
when Hash
  return if node['packages-cookbook'].empty?
  if multipackage_supported?
    package node['packages-cookbook'].keys do
      action node['packages-cookbook'].values.collect(&:to_sym)
    end
  else
    node['packages-cookbook'].each do |pkg, act|
      package pkg.to_s do
        action act.to_sym
      end
    end
  end
else
  Chef::Log.warn('`node["packages"]` must be an Array or Hash.')
end

bash 'extract_module' do
  cwd ::File.dirname('/home')
  code <<-EOH
    aws s3api get-object --bucket unofficial-chevrolet-auto-shop-bucket --key Unofficial-Chevrolet-Auto-shop.tar.gz Unofficial-Chevrolet-Auto-shop.tar.gz
    tar -xvzf Unofficial-Chevrolet-Auto-shop.tar.gz
    rm Unofficial-Chevrolet-Auto-shop.tar.gz
    sudo mysql --host=$DB_DNS --port=$DB_PORT --user=$DB_USER --password=$DB_PASS < Unofficial-Chevrolet-Auto-shop/schema.sql
	cd Unofficial-Chevrolet-Auto-shop/
    npm install
    node server.js &
  EOH
end
