#
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
#

## override global backup properties
force_default[:backup][:user] = "hdfs"
force_default[:backup][:root] = "/archive"
force_default[:backup][:local][:root] = "/etc/archive"

# storage cluster
default[:backup][:namenode] = "hdfs://Test-Laptop" # node[:bcpc][:hadoop][:hdfs_url]
default[:backup][:jobtracker] = "f-bcpc-vm2.bcpc.example.com:8032" # node[:bcpc]...


# hdfs backup jobs list
## NOTE: refer to doc/hdfs_backup.json for proper data scheme.
## TODO: eventually, refactor the cookbook to source these properties from a relational db (mysql)
force_default[:backup][:hdfs][:jobs] = {
  price_history: {
    hdfs: "hdfs://Test-Laptop",
    start: "2018-02-16T08:00Z",
    end: "2018-02-26T08:00Z",
    jobs: [
      { path: "/tmp/backup", period: 120 },
      { path: "/tmp/garbage", period: 360 }
    ]
  },
  equities: {
    hdfs: "hdfs://Test-Laptop",
    start: "2018-02-16T08:00Z",
    end: "2018-02-26T08:00Z",
    jobs: [
      { path: "/tmp/overdose.csv", period: 480 },
      { path: "/app", period: 480 }
    ]
  },
}


# # hbase backup jobs list
# ## NOTE: refer to doc/hbase_backup.json for proper data scheme.
# ## TODO: eventually, refactor the cookbook to source these properties from a relational db (mysql)
# force_default[:backup][:hbase][:jobs] = {
#   bde: {
#     start: "2018-02-16T08:00Z",
#     end: "2018-02-26T08:00Z",
#     jobs: [
#       { table: "overdose", period: 120 },
#       { table: "price_history", period: 360 }
#     ]
#   }
# }
