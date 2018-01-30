name             'bcpc-hadoop'
maintainer       'Bloomberg Finance L.P.'
maintainer_email 'hadoop@bloomberg.net'
license          'Apache License 2.0'
description      'Installs/Configures Bloomberg Clustered Private Hadoop Cloud (BCPHC)'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.0.45'

depends 'bcpc', '= 3.0.45'
depends 'bach_krb5', '= 3.0.45'
depends 'database'
depends 'java'
depends 'maven'
depends 'poise'
depends 'pam'
depends 'sysctl'
depends 'ulimit'
depends 'locking_resource'
