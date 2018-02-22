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

default[:backup][:cookbook] = 

## global backup properties
default[:backup][:user] = "hdfs"
default[:backup][:root] = "/backup"
default[:backup][:local][:root] = "/etc/backup"

# storage cluster
default[:backup][:namenode] = "hdfs://localhost:9000"
default[:backup][:jobtracker] = "localhost:8032"
default[:backup][:oozie] = "http://localhost:11000/oozie"


## hdfs backups
default[:backup][:hdfs][:enabled] = true
default[:backup][:hdfs][:root] = "#{node[:backup][:root]}/hdfs"
default[:backup][:hdfs][:local][:root] = "#{node[:backup][:local][:root]}/hdfs"

# hdfs backup requests
## NOTE: refer to files/default/hdfs/jobs.yaml for the proper data scheme.
## example jobs list:
# default[:backup][:hdfs][:jobs] = YAML.load_file(File.join(
#   Chef::Config[:file_cache_path],
#   'cookbooks',
#   'backup',
#   'files/default/hdfs/jobs.yml'
# ))

# empty jobs list
default[:backup][:hdfs][:jobs] = {}

# hdfs backup groups
default[:backup][:hdfs][:user] = "hdfs"
default[:backup][:hdfs][:groups] = default[:backup][:hdfs][:jobs].keys

## hdfs backup tuning parameters

# timeout in minutes before aborting distcp request
default[:backup][:hdfs][:timeout] = -1

# bandlimit in MB/s per mapper
default[:backup][:hdfs][:mapper][:bandwidth] = 25

## FUTURE: HBase, Hive, and Phoenix backups
