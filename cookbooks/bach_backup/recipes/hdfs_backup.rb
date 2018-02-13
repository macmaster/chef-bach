#
# Cookbook Name:: bach_backup
# Recipe:: default
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

# create the hdfs backup root
directory "#{ENV['HOME']}/backup/hdfs" do
	owner 'rmacmaster'
	group 'rmacmaster'
	mode 0o0755
  recursive true
	action :create
end

puts "hdfs backup groups:"
puts node['bach']['backup']['hdfs']['groups'].inspect
node['bach']['backup']['hdfs']['groups'].each do |group|
	directory "#{ENV['HOME']}/backup/hdfs/#{group}" do
		owner 'rmacmaster'
		group 'rmacmaster'
		mode 0o0775
		recursive true
		action [:delete, :create]
	end
end

