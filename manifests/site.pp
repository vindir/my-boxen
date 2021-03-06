require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  include nodejs::v0_6
  include nodejs::v0_8
  include nodejs::v0_10

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  #Vocalocity Base Package Includes
  include ctags
  include wget
  include java
  include python
  include keepassx
  include tunnelblick::beta
  include hangout_plugin
  include virtualbox
  include adium
  include eclipse::java

  include sublime_text_2
  #Vocalocity Base Include Options
  sublime_text_2::package { 'Emmet':
      source => 'sergeche/emmet-sublime'
  }

  include iterm2::stable
  #include iterm2::dev

  include iterm2::colors::arthur
  #include iterm2::colors::solarized_dark
  #include iterm2::colors::saturn
  include hipchat
  include skype
  include apachedirectorystudio

  #include vlc
  class { 'vlc': 
    version => '2.1.5'
  }

  package { 'coreutils':
    ensure => present,
    #install_options => [
    #  '--with-fpm',
    #  '--without-apache'
    #],
    #require => Package['zlib']
  }

}
