#
# Cookbook Name:: backup
# custom oozie job resource
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

resource_name :oozie_job

property :name, String, name_property: true
property :url, String, required: true
property :config, String, required: true
property :user, String

action :run do
  require "mixlib/shellout"
  Chef::Log.info("Starting oozie job: #{name}")

  # start the service
  oozie_cmds = ["sudo -u #{user} oozie job -config #{config} -oozie #{url} -run"]
  Mixlib::ShellOut.new(oozie_cmds.join(" && "), timeout: 90).run_command.error!
end

action :kill do
  require "mixlib/shellout"
  Chef::Log.info("Killing oozie job: #{name}")

  # kill the service (if it exists)
  ## TODO: check if the service exists. set -kill's optionarg to job_id
  oozie_cmds = ["sudo -u #{user} oozie job -config #{config} -oozie #{url} -kill"]
  Mixlib::ShellOut.new(oozie_cmds.join(" && "), timeout: 90).run_command.error!
end

action :nothing do
end
