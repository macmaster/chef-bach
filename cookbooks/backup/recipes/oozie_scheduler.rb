#
# Cookbook Name:: backup
# Recipe:: oozie_scheduler
# Launches the oozie coordinators to schedule periodic backups
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

node[:backup][:hdfs][:jobs].each do |group, backup|
  local_conf_dir = "#{node[:backup][:hdfs][:local][:root]}/#{group}"

  if backup[:jobs]
    backup[:jobs].each do |job|
      job_name = job[:name] ? job[:name] : File.basename(job[:path])

      # restart oozie coordinators
      oozie_job "backup.hdfs.#{group}.#{job_name}" do
        url node[:backup][:oozie]
        config "#{local_conf_dir}/backup-#{job_name}.properties"
        user node[:backup][:hdfs][:user]
        action :run
      end
    end
  end
end
