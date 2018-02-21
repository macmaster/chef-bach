#
# oozie_client.rb
# custom ruby client for oozie
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

require 'net/http'
require 'json'

module Oozie
  class ClientV1
    attr_accessor :host, :port, :user

    def initialize(host='localhost', port=11000, user='oozie')
      @host = host
      @port = port
      @user = user

      @oozie = "http://#{host}:#{port}/oozie"
    end

    def jobs(filter={}, jobtype="workflow", len=10, kill=false)
      filter = filter.map { |key, value| "#{key.to_s}=#{value}" }.join(";")
      options = "-oozie #{@oozie} -jobtype #{jobtype} -len #{len} -filter=\"#{filter}\""
      options += " -kill" if kill
      jobs_cmd = "sudo -u #{@user} oozie jobs #{options}"
      puts jobs_cmd
      return self.execute(jobs_cmd)
    end

    def run(config, user=@user)
      job_cmd = "sudo -u #{user} oozie job -oozie #{@oozie} -config #{config} -run"
      puts job_cmd
      return self.execute(job_cmd)
    end

    def execute(command)
      require 'mixlib/shellout'
      return Mixlib::ShellOut.new(command, timeout: 90).run_command
    end
  end
  
  class Client < ClientV1
  end
end
