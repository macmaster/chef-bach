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

default[:bach][:backup][:hdfs][:enabled] = false
default[:bach][:backup][:hdfs][:groups] = %w(
	price_history
	equities
	bde
	web_development
	security
)

default[:bach][:backup][:hdfs][:src][:namenode] = "hdfs://Test-Laptop"
default[:bach][:backup][:hdfs][:src][:backup_root] = "/backup/hdfs"

default[:bach][:backup][:hdfs][:dest][:namenode] = "hdfs://Test-Laptop"
default[:bach][:backup][:hdfs][:dest][:backup_root] = "/backup/hdfs"

default[:bach][:backup][:hdfs][:jobtracker] = default[:bach][:backup][:hdfs][:src][:namenode]
