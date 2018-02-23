#
# Cookbook Name:: backup
# Recipe:: properties
# Creates the local oozie job.properties files
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

def parse_hdfs_properties(group, schedule, job)
  # override schedule parameters
  name = job[:name] ? job[:name] : File.basename(job[:path])
  hdfs_src = job[:hdfs] ? job[:hdfs] : schedule[:hdfs]
  period = job[:period] ? job[:period] : schedule[:period]

  return {
    group: group,
    path: job[:path],
    basename: File.basename(job[:path]),
    jobname: "#{group}-#{name}",
    hdfs: hdfs_src,
    period: period,
    startdate: schedule[:start],
    enddate: schedule[:end],
    timeout: node[:backup][:hdfs][:timeout],
    bandwidth: node[:backup][:hdfs][:mapper][:bandwidth]
  }
end

def parse_service_properties(service, group, schedule, job)
  case service.to_sym
  when :hdfs
    return parse_hdfs_properties(group, schedule, job)
  else
    nil
  end
end

def create_local_properties(service, path)
  properties_files = []
  node[:backup][service][:schedules].each do |group, schedule|
    if !schedule[:jobs].nil?
      schedule[:jobs].each do |job|
        job_props = parse_service_properties(service, group, schedule, job) 
        properties_file = "#{path}/#{job_props[:jobname]}.properties"
        properties_files << properties_file

        # oozie job.properties
        template "#{properties_file}" do
          source "#{service}/backup.properties.erb"
          owner node[:backup][service][:user]
          group  node[:backup][service][:user]
          mode "0775"
          action :create
          variables job_props
        end
      end
    end
  end

  # list of files created
  return properties_files
end

# removes all directories in #{path} not included in the #{filter} array.
def clean_local_properties(filter, path)
  files = Dir.glob("#{path}/*.properties").select { |entry| File.file? entry }
  files.each do |filename|
    file "#{filename}#delete" do
      path filename
      action :delete
      not_if { filter.include? filename }
    end
  end
end

node[:backup][:services].each do |service|
  if node[:backup][service][:enabled]
    oozie_config_dir = "#{node[:backup][service][:local][:oozie]}"
    properties_files = create_local_properties(service, oozie_config_dir)
    clean_local_properties(properties_files, oozie_config_dir)
  end
end

