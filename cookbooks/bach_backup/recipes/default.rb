# Cookbook Name:: bach_backup_wrapper
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

# Resources here are run at compile time.
# This is necessary to avoid errors in bcpc-hadoop's resource search.

user node[:backup][:user] do
  action :nothing
  comment 'backup service user'
end.run_action(:create)

group 'hdfs' do
  action :nothing
  members node[:backup][:user]
  append true
end.run_action(:manage)

configure_kerberos 'backup_kerberos' do
  service_name 'bach_backup'
end
