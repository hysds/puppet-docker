define docker::pip($ensure = installed) {
  case $ensure {
    installed: {
      exec { "/usr/bin/pip install $name":
        path => "/usr/local/bin:/usr/bin:/bin",
        unless => "/usr/bin/pip show $name",
        timeout => 1800,
      }
    }
    latest: {
      exec { "/usr/bin/pip install --upgrade $name":
        path => "/usr/local/bin:/usr/bin:/bin",
        timeout => 1800,
      }
    }
    default: {
      exec { "/usr/bin/pip install $name==$ensure":
        path => "/usr/local/bin:/usr/bin:/bin",
        timeout => 1800,
      }
    }
  }
}
