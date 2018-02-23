#
# Cookbook Name:: backup
# Recipe:: bootstrap
# Creates the local backup bootstrap directory
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

# create the local configuration root
# holds local copies of the oozie configurations
directory "#{node[:backup][:local][:root]}" do
  owner node[:backup][:user]
  group node[:backup][:user]
  mode "0755"
  action :create
end

node[:backup][:services].each do |service|
  if node[:backup][service][:enabled]
    # create the service backup root (drwxr-xr-x)
    directory "#{node[:backup][service][:local][:root]}" do
      owner node[:backup][:user]
      group node[:backup][service][:user]
      mode "0755"
      action :create
    end
    
    # create the oozie config directory (drwxr-xr-x)
    directory "#{node[:backup][service][:local][:oozie]}" do
      owner node[:backup][:user]
      group node[:backup][service][:user]
      mode "0755"
      action :create
    end

    # oozie workflow.xml
    template "#{node[:backup][service][:local][:oozie]}/workflow.xml" do
      source "#{service}/workflow.xml.erb"
      owner node[:backup][:user]
      group node[:backup][service][:user]
      mode "0755"
      action :create
    end

    # oozie coordinator.xml
    template "#{node[:backup][service][:local][:oozie]}/coordinator.xml" do
      source "#{service}/coordinator.xml.erb"
      owner node[:backup][:user]
      group node[:backup][service][:user]
      mode "0755"
      action :create
    end

    # oozie groups.xml
    # creates the hdfs group directories under bootstrap dir.
    template "#{node[:backup][service][:local][:oozie]}/groups.xml" do
      source "#{service}/groups.xml.erb"
      owner node[:backup][:user]
      group node[:backup][service][:user]
      mode "0755"
      action :create
      variables(
        service: service,
        groups: node[:backup][service][:schedules].keys,
        mode: '-rwxrwx---'
      )
    end

    # oozie groups.properties
    template "#{node[:backup][service][:local][:oozie]}/groups.properties" do
      source "#{service}/groups.properties.erb"
      owner node[:backup][:user]
      group node[:backup][service][:user]
      mode "0755"
      action :create
    end
  end
end
