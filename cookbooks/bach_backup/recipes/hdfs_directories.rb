#
# Cookbook Name:: bach_backup
# Recipe:: hdfs_directories
# Creates the HDFS backup storage directories
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

# create the backup root (drwxrwxrwt)
hdfs_directory "#{node[:backup][:root]}" do
  hdfs node[:backup][:namenode]
  path node[:backup][:root]
  owner node[:backup][:user]
  group node[:backup][:user]
  mode "1777"
end

def create_hdfs_group_dirs(groups, hdfs, path, owner, mode) 
  groups.map do |group|
    # group directory
    hdfs_directory "#{path}/#{group}" do
      hdfs "#{hdfs}"
      path "#{path}/#{group}"
      owner "#{owner}"
      group "#{group}"
      mode "#{mode}"
      action :create
    end

    # oozie metadata
    hdfs_directory "#{path}/#{group}/.oozie" do
      hdfs "#{hdfs}"
      path "#{path}/#{group}/.oozie"
      owner "#{owner}"
      group "#{group}"
      mode "#{mode}"
      action :create
    end
  end
end

if node[:backup][:hdfs][:enabled]
  # create the hdfs backup root (drwxr-xr-x)
  hdfs_directory "#{node[:backup][:hdfs][:root]}" do
    hdfs node[:backup][:namenode]
    path node[:backup][:hdfs][:root]
    owner node[:backup][:hdfs][:user]
    group node[:backup][:hdfs][:user]
    mode "0755"
    action :create
  end

  # create the team backup dirs (hdfs:#{group} drwxrwx---)
  create_hdfs_group_dirs(
    node[:backup][:hdfs][:groups],
    node[:backup][:namenode], 
    node[:backup][:hdfs][:root],
    node[:backup][:hdfs][:user], 
    "0770", 
  )
end

if node[:backup][:hbase][:enabled]
  # create the hbase backup root (drwxr-xr-x)
  hdfs_directory "#{node[:backup][:hbase][:root]}" do
    hdfs node[:backup][:namenode]
    path node[:backup][:hbase][:root]
    owner node[:backup][:hbase][:user]
    group node[:backup][:hbase][:user]
    mode "0755"
    action :create
  end

  # create the team backup dirs (hbase:#{group} drwxrwx---)
  create_hdfs_group_dirs(
    node[:backup][:hbase][:groups],
    node[:backup][:namenode], 
    node[:backup][:hbase][:root],
    node[:backup][:hbase][:user], 
    "0770", 
  )
end
