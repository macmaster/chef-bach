#
# Cookbook Name:: bach_backup
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

# global backup attributes
default[:bach][:backup][:root] = "/group"

## hdfs backups
default[:bach][:backup][:hdfs][:enabled] = false

# storage cluster
default[:bach][:backup][:hdfs][:namenode] = node[:bcpc][:hadoop][:hdfs_url]
default[:bach][:backup][:hdfs][:root] = "#{node[:bach][:backup][:root]}/hdfs"

# hdfs backup groups
default[:bach][:backup][:hdfs][:groups] = %w(
	price_history
	equities
	bde
	web_development
	security
)


## hbase backups
default[:bach][:backup][:hbase][:enabled] = false

# storage cluster
default[:bach][:backup][:hbase][:namenode] = node[:bcpc][:hadoop][:hdfs_url]
default[:bach][:backup][:hbase][:root] = "#{node[:bach][:backup][:root]}/hbase"

# hbase backup groups
default[:bach][:backup][:hbase][:groups] = %w(
  hadoop
  mapred
  storm
  phoenix
  oozie
)

