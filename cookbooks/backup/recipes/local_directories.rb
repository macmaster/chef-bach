#
# Cookbook Name:: backup
# Recipe:: local_directories
# Creates the local backup configuration directories
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

# create the local configuration root
# holds local copies of the oozie configurations
directory "#{node[:backup][:local][:root]}" do
  owner node[:backup][:user]
  group node[:backup][:user]
  mode "0755"
  action :create
end

def create_local_group_dirs(groups, path, user, mode)
  threads = groups.map do |group|
    # local oozie metadata
    directory "#{path}/#{group}" do
      owner "#{user}"
      group "#{user}"
      mode "#{mode}"
      action :create
    end
  end
end

def clean_local_group_dirs(filter, path)
  group_dirs = Dir.glob("#{path}/*").select { |entry| File.directory? entry }
  group_dirs.each do |dir|
    directory "#{dir}#delete" do
      path dir
      recursive true
      action :delete
      not_if { filter.include? File.basename(dir) }
    end
  end
end

if node[:backup][:hdfs][:enabled]
  # create the hdfs backup root (drwxr-xr-x)
  directory "#{node[:backup][:hdfs][:local][:root]}" do
    owner node[:backup][:user]
    group node[:backup][:user]
    mode "0755"
    action :create
  end

  # clean the stale team conf dirs
  clean_local_group_dirs(
    node[:backup][:hdfs][:groups],
    node[:backup][:hdfs][:local][:root]
  )

  # create the local team backup conf dirs (/etc/backup)
  create_local_group_dirs(
    node[:backup][:hdfs][:groups],
    node[:backup][:hdfs][:local][:root],
    node[:backup][:user], 
    "0755"
  )
end

if node[:backup][:hbase][:enabled]
  # create the hbase backup root (drwxr-xr-x)
  directory "#{node[:backup][:hbase][:local][:root]}" do
    owner node[:backup][:user]
    group node[:backup][:user]
    mode "0755"
    action :create
  end
  
  # clean the stale team conf dirs
  clean_local_group_dirs(
    node[:backup][:hbase][:groups],
    node[:backup][:hbase][:local][:root]
  )

  # create the local team backup conf dirs (/etc/backup)
  create_local_group_dirs(
    node[:backup][:hbase][:groups],
    node[:backup][:hbase][:local][:root],
    node[:backup][:user], 
    "0755"
  )
end
