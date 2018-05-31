# Cookbook Name:: bach_backup_wrapper
# Override Attributes
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

## override global backup properties
force_default[:backup][:user] = "bach_backup"
force_default[:backup][:root] = "/archive"
force_default[:backup][:local][:root] = "/etc/archive"


# storage cluster
set_hosts # set bcpc hadoop hosts
force_default[:backup][:namenode] = "hdfs://#{node.chef_environment}"
force_default[:backup][:jobtracker] = "f-bcpc-vm2.bcpc.example.com:8032" # node[:bcpc]...

force_default[:backup][:oozie] = "http://f-bcpc-vm1.bcpc.example.com:11000/oozie"

puts "oozie url: #{get_oozie_url}"

# Mapreduce Queue
force_default[:backup][:queue] = "root.default.#{node[:backup][:user]}"

# hdfs backup jobs list
## NOTE: refer to file/default/hdfs_jobs.yml for proper data scheme.
## TODO: eventually, refactor the cookbook to source these properties from a relational db (mysql)
## force_default[:backup][:hdfs][:schedules] = YAML.load_file(File.join(
##   Chef::Config[:file_cache_path],
##   'cookbooks',
##   'bach_backup',
##   'files/default/hdfs/jobs.yml'
## ))
### force_default[:backup][:hdfs][:groups] = node[:backup][:hdfs][:jobs].keys

force_default[:backup][:hdfs][:schedules] = {
  hdfs: {
    hdfs: 'hdfs://Test-Laptop',
    start: '2018-02-16T12:00Z',
    end: '2018-06-16T06:00Z',
    jobs: [
      { path: '/tmp', period: 360, },
      { path: '/user', period: 480, },
    ]
  },
  ubuntu: {
    hdfs: 'hdfs://Test-Laptop',
    start: '2018-02-16T12:00Z',
    end: '2018-06-16T06:00Z',
    jobs: [
      { path: '/tmp', period: 1440, },
      { path: '/user', period: 720, },
    ]
  },
  # bach: {
  #   hdfs: 'hdfs://Test-Laptop',
  #   start: '2018-02-16T12:00Z',
  #   end: '2018-06-16T06:00Z',
  #   period: 120,
  #   jobs: [
  #     { path: '/tmp', },
  #     { path: '/user', },
  #   ]
  # },
}

