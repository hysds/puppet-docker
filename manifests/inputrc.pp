define docker::inputrc ($user = $title, $home) {
  file { "$home/.inputrc":
    ensure  => file,
    mode    => 0644,
    owner   => $user,
    group   => $user,
    content => '#"\e[5~": history-search-backward #for "page up" key
#"\e[6~": history-search-forward  #for "page down" key
"\e[A": history-search-backward
"\e[B": history-search-forward
',
  }
}
