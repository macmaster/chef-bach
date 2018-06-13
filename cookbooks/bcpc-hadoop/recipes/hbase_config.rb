# vim: tabstop=2:shiftwidth=2:softtabstop=2
# Cookbook Name : bcpc-hadoop
# Recipe Name : hbase_config
# Description : To setup habse related configuration only

directory "/etc/hbase/conf.#{node.chef_environment}" do
  owner "root"
  group "root"
  mode 00755
  action :create
  recursive true
end

bash "update-hbase-conf-alternatives" do
  code(%Q{
    update-alternatives --install /etc/hbase/conf hbase-conf /etc/hbase/conf.#{node.chef_environment} 50
    update-alternatives --set hbase-conf /etc/hbase/conf.#{node.chef_environment}
  })
end

if get_nodes_for("powerdns", "bcpc").length > 0
 dns_server = node[:bcpc][:management][:vip]
else
 dns_server = node[:bcpc][:dns_servers][0]
end

template '/etc/hbase/conf/hadoop-metrics2-hbase.properties' do
  source 'hb_hadoop-metrics2-hbase.properties.erb'
  mode 0644
end

# thse are rendered as is
%w{
  log4j.properties
  hbase-policy.xml }.each do |t|
  template "/etc/hbase/conf/#{t}" do
    source "hb_#{t}.erb"
    mode 0644
  end
end

# thse are rendered as is
%w{
  hbase-client.jaas
  hbase-server.jaas
  regionserver.jaas}.each do |t|
  template "/etc/hbase/conf/#{t}" do
    source "hb_#{t}.erb"
    mode 0644
    only_if { node[:bcpc][:hadoop][:kerberos][:enable] }
  end
end

subnet = node["bcpc"]["management"]["subnet"]

#
# Add common hbase-site.xml properties
#
generated_values = {
  'hbase.zookeeper.quorum' =>
    node[:bcpc][:hadoop][:zookeeper][:servers].map{ |s| float_host(s[:hostname])}.join(","),
  'hbase.zookeeper.property.clientPort' => "#{node[:bcpc][:hadoop][:zookeeper][:port]}",
  'hbase.master.hostname' => float_host(node[:fqdn]),
  'hbase.regionserver.hostname' => float_host(node[:fqdn]),
  'hbase.regionserver.dns.interface' =>
      node["bcpc"]["networks"][subnet]["floating"]["interface"],
  'hbase.master.dns.interface' =>
      node["bcpc"]["networks"][subnet]["floating"]["interface"],
  'dfs.client.read.shortcircuit' => node["bcpc"]["hadoop"]["hbase"]["shortcircuit"]["read"].to_s
}

# this configuration parameter only belongs in master
if node.roles.include? 'BCPC-Hadoop-Head-HBase' then
  generated_values['hbase.master.wait.on.regionservers.mintostart'] =
      "#{node[:bcpc][:hadoop][:rs_hosts].length/2+1}"
end

#
# Initialize hbase-site list properties
#
list_properties = [
  'hbase.coprocessor.region.classes',
  'hbase.coprocessor.regionserver.classes',
  'hbase.coprocessor.master.classes',
  'hbase.master.logcleaner.plugins',
  'hbase.master.hfilecleaner.plugins',
  'hbase.procedure.master.classes',
  'hbase.procedure.regionserver.classes'
]
list_properties.each { |prop| generated_values[prop] = [] }

#
# Any hbase-site.xml property related to Kerberos need to go here
#
if node[:bcpc][:hadoop][:kerberos][:enable] == true then
  generated_values['hbase.security.authorization'] = 'true'
  generated_values['hbase.superuser'] = node[:bcpc][:hadoop][:hbase][:superusers].join(',')
  region_classes = [
     'org.apache.hadoop.hbase.security.token.TokenProvider',
     'org.apache.hadoop.hbase.security.access.SecureBulkLoadEndpoint',
     'org.apache.hadoop.hbase.security.access.AccessController',
     node['bcpc']['hadoop']['hbase']['site_xml'].fetch('hbase.coprocessor.region.classes', nil)
  ].select{|c| c}.join(',')
  regionserver_classes = [
    'org.apache.hadoop.hbase.security.access.AccessController',
    node['bcpc']['hadoop']['hbase']['site_xml'].fetch('hbase.coprocessor.regionserver.classes', nil)
  ].select{|c| c}.join(',')
  master_classes = [
    'org.apache.hadoop.hbase.security.access.AccessController',
    'org.apache.hadoop.hbase.security.access.CoprocessorWhitelistMasterObserver',
    node['bcpc']['hadoop']['hbase']['site_xml'].fetch('hbase.coprocessor.master.classes', nil)
  ].select{|c| c}.join(',')
  generated_values['hbase.coprocessor.region.classes'] = region_classes
  generated_values['hbase.coprocessor.regionserver.classes'] = regionserver_classes
  generated_values['hbase.coprocessor.master.classes'] = master_classes
  generated_values['hbase.security.exec.permission.checks'] = 'true'
  generated_values['hbase.security.authentication'] = 'kerberos'
  generated_values['hbase.master.kerberos.principal'] =
    "#{node[:bcpc][:hadoop][:kerberos][:data][:hbase][:principal]}/" +
    "#{node[:bcpc][:hadoop][:kerberos][:data][:hbase][:princhost] == '_HOST' ? '_HOST' : node[:bcpc][:hadoop][:kerberos][:data][:hbase][:princhost]}@#{node[:bcpc][:hadoop][:kerberos][:realm]}"
  generated_values['hbase.master.keytab.file'] =
    "#{node[:bcpc][:hadoop][:kerberos][:keytab][:dir]}/#{node[:bcpc][:hadoop][:kerberos][:data][:hbase][:keytab]}"
  generated_values['hbase.regionserver.kerberos.principal'] =
    "#{node[:bcpc][:hadoop][:kerberos][:data][:hbase][:principal]}/#{node[:bcpc][:hadoop][:kerberos][:data][:hbase][:princhost] == '_HOST' ? '_HOST' : node[:bcpc][:hadoop][:kerberos][:data][:hbase][:princhost]}@#{node[:bcpc][:hadoop][:kerberos][:realm]}"
  generated_values['hbase.regionserver.keytab.file'] =
    "#{node[:bcpc][:hadoop][:kerberos][:keytab][:dir]}/#{node[:bcpc][:hadoop][:kerberos][:data][:hbase][:keytab]}"
  generated_values['hbase.rpc.engine'] = 'org.apache.hadoop.hbase.ipc.SecureRpcEngine'
  generated_values['phoenix.acls.enabled'] = 'true'
end

#
# If HDFS short circuit read is enabled properties in this section will be added to hbase-site.xml
#
if node["bcpc"]["hadoop"]["hbase"]["shortcircuit"]["read"] == true then
  generated_values['dfs.domain.socket.path'] =  '/var/run/hadoop-hdfs/dn._PORT'
  generated_values['dfs.client.read.shortcircuit.buffer.size'] = node["bcpc"]["hadoop"]["hbase"]["dfs"]["client"]["read"]["shortcircuit"]["buffer"]["size"].to_s
end

#
# If HBASE bucket cache is enabled the properties from this section will be included in hbase-site.xml
#
bucketcache_size = (node["bcpc"]["hadoop"]["hbase_rs"]["mx_dir_mem"]["size"] -  node["bcpc"]["hadoop"]["hbase_rs"]["hdfs_dir_mem"]["size"]).floor
if node["bcpc"]["hadoop"]["hbase"]["bucketcache"]["enabled"] == true then
  generated_values['hbase.regionserver.global.memstore.upperLimit'] = node["bcpc"]["hadoop"]["hbase_rs"]["memstore"]["upperlimit"].to_s
  generated_values['hfile.block.cache.size'] = node["bcpc"]["hadoop"]["hbase"]["blockcache"]["size"].to_s
  generated_values['hbase.bucketcache.size'] = bucketcache_size
  generated_values['hbase.bucketcache.ioengine '] = node["bcpc"]["hadoop"]["hbase"]["bucketcache"]["ioengine"]
  generated_values['hbase.bucketcache.combinedcache.enabled'] = true
  if node['bcpc']['hadoop']['hbase']['bucketcache.bucket.sizes']
    generated_values['hbase.bucketcache.bucket.sizes'] = node['bcpc']['hadoop']['hbase']['bucketcache.bucket.sizes']
  end
end

# If HBASE RS group is enabled the properties from this section will be included in hbase-site.xml
#
if node["bcpc"]["hadoop"]["hbase"]["rsgroup"]["enabled"] == true then
  if generated_values['hbase.coprocessor.master.classes'].nil?
    generated_values['hbase.coprocessor.master.classes'] = 'org.apache.hadoop.hbase.rsgroup.RSGroupAdminEndpoint'
  else
    generated_values['hbase.coprocessor.master.classes'] = generated_values['hbase.coprocessor.master.classes'] +
                                                           ',org.apache.hadoop.hbase.rsgroup.RSGroupAdminEndpoint'
  end
  generated_values['hbase.master.loadbalancer.class'] = 'org.apache.hadoop.hbase.rsgroup.RSGroupBasedLoadBalancer'
end

#
# if HBASE region replication is enabled the properties in this section will be included in hbase-site.xml
#
if node['bcpc']['hadoop']['hbase']['site_xml']['hbase.region.replica.replication.enabled'] then
  generated_values['hbase.regionserver.storefile.refresh.period'] = node["bcpc"]["hadoop"]["hbase_rs"]["storefile"]["refresh"]["period"]
  generated_values['hbase.region.replica.replication.enabled'] = node['bcpc']['hadoop']['hbase']['site_xml']['hbase.region.replica.replication.enabled'].to_s
  generated_values['hbase.master.hfilecleaner.ttl'] = node["bcpc"]["hadoop"]["hbase_master"]["hfilecleaner"]["ttl"]
  generated_values['hbase.meta.replica.count'] = node["bcpc"]["hadoop"]["hbase"]["meta"]["replica"]["count"]
  generated_values['hbase.regionserver.storefile.refresh.all'] = node["bcpc"]["hadoop"]["hbase_rs"]["storefile"]["refresh"]["all"]
  generated_values['hbase.region.replica.storefile.refresh.memstore.multiplier'] = node["bcpc"]["hadoop"]["hbase"]["region"]["replica"]["storefile"]["refresh"]["memstore"]["multiplier"]
  generated_values['hbase.region.replica.wait.for.primary.flush'] = node["bcpc"]["hadoop"]["hbase"]["region"]["replica"]["wait"]["for"]["primary"]["flush"]
  generated_values['hbase.regionserver.global.memstore.lowerLimit'] = node["bcpc"]["hadoop"]["hbase_rs"]["memstore"]["lowerlimit"]
  generated_values['hbase.hregion.memstore.block.multiplier'] = node["bcpc"]["hadoop"]["hbase"]["hregion"]["memstore"]["block"]["multiplier"]
  generated_values['hbase.ipc.client.specificThreadForWriting'] = node["bcpc"]["hadoop"]["hbase"]["ipc"]["client"]["specificthreadforwriting"]
  generated_values['hbase.client.primaryCallTimeout.get'] = node["bcpc"]["hadoop"]["hbase"]["client"]["primarycalltimeout"]["get"]
  generated_values['hbase.client.primaryCallTimeout.multiget'] = node["bcpc"]["hadoop"]["hbase"]["client"]["primarycalltimeout"]["multiget"]
end

#
# if HBASE backup is enabled the properties from this section will be included in hbase-site.xml
#
if node['bcpc']['hadoop']['hbase']['site_xml']['hbase.backup.enable'] then
  generated_values['hbase.coprocessor.region.classes'] << 'org.apache.hadoop.hbase.backup.BackupObserver'
  generated_values['hbase.master.logcleaner.plugins'] << 'org.apache.hadoop.hbase.backup.master.BackupLogCleaner'
  generated_values['hbase.master.hfilecleaner.plugins'] << 'org.apache.hadoop.hbase.backup.BackupHFileCleaner'
  generated_values['hbase.procedure.master.classes'] << 'org.apache.hadoop.hbase.backup.master.LogRollMasterProcedureManager'
  generated_values['hbase.procedure.regionserver.classes'] << 'org.apache.hadoop.hbase.backup.regionserver.LogRollRegionServerProcedureManager'
end

#
# Consolidate hbase-site.xml list properties
#
generated_values.delete_if { |k, v| v.empty? }
list_properties.each { |prop| generated_values[prop] = generated_values[prop].join(",") }

site_xml = node[:bcpc][:hadoop][:hbase][:site_xml]
complete_hbase_site_hash = generated_values.merge(site_xml)

template '/etc/hbase/conf/hbase-site.xml' do
  source 'generic_site.xml.erb'
  mode 0644
  variables(:options => complete_hbase_site_hash)
end

template "/etc/hbase/conf/regionservers" do
   source "hb_regionservers.erb"
   mode 0644
   variables(:rs_hosts => node[:bcpc][:hadoop][:rs_hosts])
end

include_recipe 'bcpc-hadoop::hbase_env'
