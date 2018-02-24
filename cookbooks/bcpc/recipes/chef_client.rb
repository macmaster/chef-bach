#
# Cookbook Name:: bcpc
# Recipe:: chef_client
#
# This recipe configures the chef-client on both the bootstrap node
# and clients.  It injects the environment's configured proxy into the
# configuration.
#
# Most configuration parameters are set in attributes/chef_client.rb
#

#
# On the bootstrap node, the chef-client config file lives inside the
# vagrant home directory, so that it can be shared by chef-client,
# knife, and chef-shell.
#


user = ENV['SUDO_USER'] || ENV['USER'] || 'vagrant'

if node[:fqdn] == get_bootstrap
  link '/etc/chef/client.rb' do
    action :delete
    only_if { ::File.symlink?('/etc/chef/client.rb') }
  end

  directory "/home/#{user}/.chef/client.d" do
    mode 0755
    user "#{user}"
    group "#{user}"
  end

  link '/etc/chef/client.d' do
    action :delete
    only_if { ::File.symlink?('/etc/chef/client.d') }
  end

  link '/etc/chef/client.pem' do
    to "/home/#{user}/chef-bcpc/.chef/#{node[:fqdn]}.pem"
  end
end

include_recipe 'chef-client::config'

knife_rb = "/home/#{user}/chef-bcpc/.chef/knife.rb"

if node[:fqdn] == get_bootstrap
  # Manage knife.rb through chef-client::config (except the log location) as
  # well.  Allows the following:
  #   * Remove the need for running `sudo knife ...` in the bootstrap.
  #   * Upload failures in `knife cookbook upload ...` will be in STDOUT instead
  #     of being written in /var/log/chef/client.log.
  #   * Prevent a pet configuration of knife.rb in our physical cluster's
  #     bootstrap machines.
  client_rb = resources("template[#{node['chef_client']['conf_dir']}/client.rb]")
  knife_config = client_rb.variables
  knife_config[:chef_config] = knife_config[:chef_config].to_hash
  knife_config[:chef_config].delete('log_location')
  template knife_rb do
    source client_rb.source
    cookbook 'chef-client'
    owner user
    group client_rb.group
    mode client_rb.mode
    variables knife_config
  end
end


if node[:bcpc][:bootstrap][:proxy]
  #
  # We need to override the template in order to set environment
  # variables inside of the configuration.  (Knife and chef-shell
  # don't parse files inside client.d)
  #
  # bcpc/templates/default/client.rb.erb will render the original
  # upstream template, then append proxy environment variables.
  #
  chef_templates = ["#{node['chef_client']['conf_dir']}/client.rb"]
  chef_templates << knife_rb if node['fqdn'] == get_bootstrap
  chef_templates.each do |chef_template|
    edit_resource!(:template, chef_template) do
      source 'client.rb.erb'
      cookbook 'bcpc'
    end
  end
end

include_recipe 'chef-client::delete_validation'
