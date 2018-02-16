#
# Cookbook Name:: backup
# Recipe:: oozie_config
# Sources and uploads the oozie job configuration for each group
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
  hdfs_conf_dir = "#{node[:backup][:hdfs][:root]}/#{group}/.oozie"

  if backup[:jobs]
    backup[:jobs].each do |job|
      job_name = job[:name] ? job[:name] : File.basename(job[:path])
      job_props = {
        group: group,
        path: job[:path],
        basename: File.basename(job[:path]),
        jobname: job_name,
        hdfs: backup[:hdfs],
        startdate: backup[:start],
        enddate: backup[:end],
        timeout: node[:backup][:hdfs][:timeout],
        bandwidth: node[:backup][:hdfs][:mapper][:bandwidth],
        period: job[:period]
      }

      # oozie job.properties
      template "#{local_conf_dir}/backup-#{job_name}.properties" do
        source "backup.properties.erb"
        owner node[:backup][:user]
        group node[:backup][:user]
        mode "0755"
        action :create
        variables job_props
      end

      # oozie workflow.xml
      template "#{local_conf_dir}/workflow-#{job_name}.xml" do
        source "workflow.xml.erb"
        owner node[:backup][:user]
        group node[:backup][:user]
        mode "0755"
        action :create
        variables job_props
      end

      # workflow.xml hdfs copy
      hdfs_file "#{hdfs_conf_dir}/workflow-#{job_name}.xml" do
        hdfs node[:backup][:namenode]
        path "#{hdfs_conf_dir}/workflow-#{job_name}.xml"
        source "#{local_conf_dir}/workflow-#{job_name}.xml"
        owner node[:backup][:user]
        group group
        mode "0770"
        action :create
      end

      # oozie coordinator.xml
      template "#{local_conf_dir}/coordinator-#{job_name}.xml" do
        source "coordinator.xml.erb"
        owner node[:backup][:user]
        group node[:backup][:user]
        mode "0755"
        action :create
        variables job_props
      end

      # coordinator.xml hdfs copy
      hdfs_file "#{hdfs_conf_dir}/coordinator-#{job_name}.xml" do
        hdfs node[:backup][:namenode]
        path "#{hdfs_conf_dir}/coordinator-#{job_name}.xml"
        source "#{local_conf_dir}/coordinator-#{job_name}.xml"
        owner node[:backup][:user]
        group group
        mode "0770"
        action :create
      end
    end
  end
end
