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

Chef::Resource::RubyBlock.send(:include, Bcpc_Hadoop::Helper)

# create the hdfs backup root (drwxr-xr-x)
ruby_block "create_hdfs_backup_root" do
  block do
    new_dir_creation(
      node[:bach][:backup][:hdfs][:namenode], 
      node[:bach][:backup][:hdfs][:root],
      "hdfs:hdfs", 
      "0755", 
      node.run_context
    )
  end
  action :run
end

# create the team backup dirs (hdfs:#{group} drwxrwx---)
ruby_block "create_hdfs_backup_groups" do
  block do
    node['bach']['backup']['hdfs']['groups'].each do |group|
      new_dir_creation(
        node[:bach][:backup][:hdfs][:namenode], 
        "#{node[:bach][:backup][:hdfs][:root]}/#{group}",
        "hdfs:#{group}", 
        "0770", 
        node.run_context
      )
    end
  end
  action :run
end

