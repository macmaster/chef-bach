#
# Cookbook Name:: backup
# Custom hdfs directory resource
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

resource_name :hdfs_directory

property :hdfs, String, required: true
property :path, String, name_property: true
property :owner, String
property :group, String
property :mode, String
property :source, String

action :create do
  require "mixlib/shellout"
  Chef::Log.info("HDFS dir #{path} creation")

  # create the directory
  hdfs_cmds = ["sudo -u hdfs hdfs dfs -mkdir -p #{hdfs}/#{path}"]

  # set the owner and group
  if !(owner.nil? || group.nil?)
    hdfs_cmds << "sudo -u hdfs hdfs dfs -chown #{owner}:#{group} #{hdfs}/#{path}"
  elsif !owner.nil?
    hdfs_cmds << "sudo -u hdfs hdfs dfs -chown #{owner} #{hdfs}/#{path}"
  elsif !group.nil?
    hdfs_cmds << "sudo -u hdfs hdfs dfs -chgrp #{group} #{hdfs}/#{path}"
  end

  # set permissions
  if !mode.nil?
    hdfs_cmds << "sudo -u hdfs hdfs dfs -chmod #{mode} #{hdfs}/#{path}"
  end

  Mixlib::ShellOut.new(hdfs_cmds.join(" && "), timeout: 90).run_command.error!
end

action :put do
  require "mixlib/shellout"
  Chef::Log.info("Copying #{path} to HDFS")
  Mixlib::ShellOut.new("sudo -u hdfs hdfs dfs -put -f -p #{source} #{hdfs}/#{path}", timeout: 90).run_command.error!
end

action :delete do
  require "mixlib/shellout"
  Chef::Log.info("HDFS dir #{path} deletion")

  # speculative, recursive delete. (ignores error)
  Mixlib::Shellout.new("sudo -u hdfs hdfs dfs -rm -r -f", timeout: 90).run_command
end

action :nothing do
end
