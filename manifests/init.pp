
class security-updates {

  case $osfamily {
    redhat: {
      cron { 'security-updates':
        command => '/usr/bin/yum update --security -y',
        user    => 'root',
        hour    => '3',
        minute  => '0',
      }
    }

    debian: {
      ensure_packages(['unattended-upgrades'])

      file_line { 'enable unattended-upgrades':
        path    => '/etc/apt/apt.conf.d/10periodic',
        line    => 'APT::Periodic::Unattended-Upgrade "1";',
        require => Package['unattended-upgrades'],
      }

      file_line { 'download-upgradate-packages':
        path    => '/etc/apt/apt.conf.d/10periodic',
        line    => 'APT::Periodic::Download-Upgradeable-Packages "1";',
        match   => '^APT::Periodic::Download-Upgradeable-Packages',
        require => Package['unattended-upgrades'],
      }

      file_line { 'auto-clean':
        path    => '/etc/apt/apt.conf.d/10periodic',
        line    => 'APT::Periodic::AutocleanInterval "7";',
        match   => '^APT::Periodic::AutocleanInterval',
        require => Package['unattended-upgrades'],
      }
    }
  }

}
