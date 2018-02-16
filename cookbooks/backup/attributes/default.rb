#
# Cookbook Name:: backup
# Default Attributes
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

## global backup properties
default[:backup][:user] = "hdfs"
default[:backup][:root] = "/group"
default[:backup][:local][:root] = "/etc/backup"

# storage cluster
default[:backup][:namenode] = "hdfs://localhost:9000" 
default[:backup][:jobtracker] = "localhost:8032" 


## hdfs backups
default[:backup][:hdfs][:enabled] = true
default[:backup][:hdfs][:root] = "#{node[:backup][:root]}/hdfs"
default[:backup][:hdfs][:local][:root] = "#{node[:backup][:local][:root]}/hdfs"

# hdfs backup requests
## NOTE: refer to doc/hdfs_backup.json for proper data scheme.
default[:backup][:hdfs][:jobs] = {}

# hdfs backup groups
default[:backup][:hdfs][:user] = "hdfs"
default[:backup][:hdfs][:groups] = node[:backup][:hdfs][:jobs].keys

# hdfs backup tuning parameters
default[:backup][:hdfs][:timeout] = -1 # timeout in minutes before aborting distcp request
default[:backup][:hdfs][:mapper][:bandwidth] = 25 # bandlimit in MB/s per mapper


## hbase backups
default[:backup][:hbase][:enabled] = true
default[:backup][:hbase][:root] = "#{node[:backup][:root]}/hbase"
default[:backup][:hbase][:local][:root] = "#{node[:backup][:local][:root]}/hbase"

# hbase backup requests
## NOTE: refer to doc/hbase_backup.json for proper data scheme.
default[:backup][:hbase][:jobs] = {}

# hbase backup groups
default[:backup][:hbase][:user] = "hbase"
default[:backup][:hbase][:groups] = node[:backup][:hbase][:jobs].keys


## FUTURE: Hive and Phoenix backups
