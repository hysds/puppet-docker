#####################################################
# docker class
#####################################################

class docker {

  #####################################################
  # create groups and users
  #####################################################
  $user = 'ops'
  $group = 'ops'

  group { $group:
    ensure     => present,
  }

  user { $user:
    ensure     => present,
    gid        => $group,
    groups     => [ "dockerroot" ],
    shell      => '/bin/bash',
    home       => "/home/$user",
    managehome => true,
    require    => [
                   Group[$group],
                   Package["docker"],
                  ],
  }


  file { "/home/$user":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => 0755,
    require => User[$user],
  }


  file { "/etc/sudoers.d/90-cloudimg-$user":
    ensure  => file,
    content  => template('docker/90-cloudimg-user'),
    mode    => 0440,
    require => [
                User[$user],
               ],
  }


  #####################################################
  # add .inputrc to users' home
  #####################################################

  inputrc { 'root':
    home => '/root',
  }
  
  inputrc { $user:
    home    => "/home/$user",
    require => User[$user],
  }


  #####################################################
  # change default user
  #####################################################

  file_line { "default_user":
    ensure  => present,
    line    => "    name: $user",
    path    => "/etc/cloud/cloud.cfg",
    match   => "^    name:",
    require => User[$user],
  }


  #####################################################
  # install .bashrc
  #####################################################

  file { "/home/$user/.bashrc":
    ensure  => present,
    content => template('docker/bashrc'),
    owner   => $user,
    group   => $group,
    mode    => 0644,
    require => User[$user],
  }


  file { "/root/.bashrc":
    ensure  => present,
    content => template('docker/bashrc'),
    mode    => 0600,
  }


  #####################################################
  # install packages
  #####################################################

  package {
    'docker': ensure => installed;
    'docker-registry': ensure => installed;
    'docker-python': ensure => installed;
    'python2-pip': ensure => installed;
  }


  pip { [ 'docker-compose', 'backports.ssl-match-hostname' ]:
    ensure  => latest,
    require => [
                Package['docker'],
                Package['docker-registry'],
                Package['docker-python'],
                Package['python2-pip'],
               ],
  }


  #####################################################
  # systemd daemon reload
  #####################################################

  exec { "daemon-reload":
    path        => ["/sbin", "/bin", "/usr/bin"],
    command     => "systemctl daemon-reload",
    refreshonly => true,
  }


  #####################################################
  # start docker service
  #####################################################

  file { "/etc/sysconfig/docker":
    ensure  => present,
    content => template('docker/docker'),
    mode    => 0644,
    require => Package['docker'],
  }


  file { "/etc/sysconfig/docker-storage-setup":
    ensure  => present,
    content => template('docker/docker-storage-setup'),
    mode    => 0644,
    require => Package['docker'],
  }


  service { 'docker':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [
                   Package['docker'],
                   Package['docker-registry'],
                   File['/etc/sysconfig/docker'],
                   File['/etc/sysconfig/docker-storage-setup'],
                   Exec['daemon-reload'],
                  ],
  }
  

}
