# Cookbook Name:: backup
# HBase Backup Attributes
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

### hbase backups
default[:backup][:hbase][:user] = node[:backup][:user]
default[:backup][:hbase][:root] = "#{node[:backup][:root]}/hbase"
default[:backup][:hbase][:local][:root] = "#{node[:backup][:local][:root]}/hbase"

# local oozie config dir
default[:backup][:hbase][:local][:oozie] =
  "#{node[:backup][:hbase][:local][:root]}/oozie"

### hbase backup requests
default[:backup][:hbase][:schedules] = {}

## NOTE: refer to files/default/hbase/jobs.yml for the proper data scheme.
# default[:backup][:hbase][:schedules] = YAML.load_file(File.join(
#   Chef::Config[:file_cache_path],
#   'cookbooks',
#   'backup',
#   'files/default/hbase/jobs.yml'
# ))
