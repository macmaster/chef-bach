#
# Cookbook Name:: bach_backup
# Recipe:: default
#
# Copyright 2018, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# print node information
puts "operating system: #{node['platform']} #{node['platform_version']}"
puts "ip address: #{node['ipaddress']}"
puts "mac address: #{node['macaddress']}"
puts "fqdn: #{node['fqdn']}"
puts node['recipes']
puts node['lsb']

# hdfs clusters
puts "local hdfs: #{node[:bcpc][:hadoop][:hdfs_url]}"
puts "storage hdfs: #{node[:bach][:backup][:hdfs][:namenode]}"
puts "storage hbase: #{node[:bach][:backup][:hbase][:namenode]}"

# print hdfs backup groups
puts "hdfs backup groups:"
puts node['bach']['backup']['hdfs']['groups'].inspect

# print hbase backup groups
puts "hbase backup groups:"
puts node['bach']['backup']['hbase']['groups'].inspect

# create the backup root (drwxrwxrwt)
Chef::Resource::RubyBlock.send(:include, Bcpc_Hadoop::Helper)
ruby_block "create_backup_root" do
  block do
    new_dir_creation(
      node[:bach][:backup][:hdfs][:namenode], 
      node[:bach][:backup][:root],
      "hdfs:hdfs", 
      "1777", 
      node.run_context
    )
  end
  action :run
end

