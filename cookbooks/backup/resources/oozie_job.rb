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
provides :oozie_job

property :name, String, name_property: true
property :url, String, required: true
property :config, String, required: true
property :user, String

action_class do
  require 'uri'
  include Oozie
end

action :run do
  Chef::Log.info("Starting oozie job: #{name}")
  client = Oozie::Client.new(URI(url).host, URI(url).port, user)

  # check if the job is already running
  jobs_cmd = client.jobs({ name: name, status: "RUNNING" }, "coordinator", 1) 

  # start the service
  if jobs_cmd.stdout.match(/(\S+)\s+#{name}/).nil?
    run_cmd = client.run(config, user)
    run_cmd.error!
  end
end

action :kill do
  Chef::Log.info("Killing oozie job: #{name}")
  client = Oozie::Client.new(URI(url).host, URI(url).port, user)

  # kill the service (if it exists)
  jobs_cmd = client.jobs({ name: name }, "coordinator", 100, true) 
  jobs_cmd.error!
end

action :nothing do
end
