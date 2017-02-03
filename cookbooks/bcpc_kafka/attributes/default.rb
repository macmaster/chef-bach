#######################################
#    Kafka BCPC specific attributes   #
#######################################

#
# Attribute to indidate whether an existing Hadoop Zookeeper
# can be used. If not Kafka Zookeeper quorum need to be created.
#
# This should always be false in a standalone Kafka cluster.
#
default[:use_hadoop_zookeeper_quorum] = false

#
# Overwriting community kafka cookbook attributes
#
default[:kafka][:automatic_start] = true
default[:kafka][:automatic_restart] = true
default[:kafka][:jmx_port] = node[:bcpc][:hadoop][:kafka][:jmx][:port]
default[:kafka][:base_url] = get_binary_server_url + 'kafka'

#
# Kafka broker settings
#
default[:kafka][:broker].tap do |broker|
  broker[:host_name] = float_host(node[:fqdn])
  broker[:advertised_host_name] = float_host(node[:fqdn])
  broker[:port] = 6667
  broker[:advertised_port] = 6667
  broker[:broker_id] = node[:bcpc][:node_number]
  broker[:reserved_broker_max_id] = (2 ** 31) - 1
  broker[:controlled][:shutdown][:enable] = true
  broker[:controlled][:shutdown][:max][:retries] = 3
  broker[:controlled][:shutdown][:retry][:backoff][:ms] = 5000
  broker[:unclean][:leader][:election][:enable] = false
  broker[:compression][:type] = 'lz4'
  broker[:auto][:create][:topics][:enable] = false
  broker[:num][:insync][:replicas] = 2
  broker[:max][:connections][:per][:ip] = 500

  # Migrate any 0.8.x nodes/topics to use Kafka-based offset storage.
  broker[:dual][:commit][:enabled] = false
  broker[:offsets][:storage] = 'kafka'

  # Use 0.9.x protocol to enable cluster upgrade to 0.10.x
  broker[:inter][:broker][:protocol][:version] = '0.9.0'
  broker[:log][:message][:format][:version] = '0.9.0'

  # Defaults for new topics
  broker[:num][:partitions] = 3
  broker[:default][:replication][:factor] = 3

  #
  # This value was chosen arbitrarily.  Kafka defaults to 1 replica
  # fetcher thread, which is clearly too few.  But how many is too
  # many?
  #
  broker[:num][:replica][:fetchers] = 8
end

#
# These attributes are normally overriden in the Chef environment.
#
default[:kafka][:version] = '0.10.1.1'
default[:kafka][:scala_version] = '2.11'

default[:kafka][:checksum] =
  '1540800779429d8f0a08be7b300e4cb6500056961440a01c8dbb281db76f0929'

default[:kafka][:md5_checksum] = ''

#
# This is the path to human-readable log files, not kafka log data.
# (/disk/0 is a mount point created by the bcpc-hadoop::disks recipe)
#
default[:kafka][:log_dir] = '/disk/0/kafka/logs'
