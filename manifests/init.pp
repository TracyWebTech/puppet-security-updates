
class security_updates {

  case $::osfamily {
    redhat: {
      cron { 'security-updates':
        command => '/usr/bin/yum update --security -y',
        user    => 'root',
        hour    => '3',
        minute  => '0',
      }
    }

    debian: {

      case $::operatingsystem {
        ubuntu: {
          ensure_packages(['update-notifier-common'])
          $periodic_conf_path = '/etc/apt/apt.conf.d/10periodic'
        }
        default: {
          $periodic_conf_path = '/etc/apt/apt.conf.d/02periodic'
        }
      }

      ensure_packages(['unattended-upgrades'])

      file { "$periodic_conf_path":
        ensure => file,
      }

      File_line {
        require => [Package['unattended-upgrades'], File[$periodic_conf_path]],
      }

      # Enable the update/upgrade script (0=disable)
      file_line { 'enable apt periodic tasks':
        path    => $periodic_conf_path,
        line    => 'APT::Periodic::Enable "1";',
        match   => '^APT::Periodic::Enable',
      }

      # Do "apt-get update" automatically every n-days (0=disable)
      file_line { 'apt update':
        path    => $periodic_conf_path,
        line    => 'APT::Periodic::Update-Package-Lists "1";',
        match   => '^APT::Periodic::Update-Package-Lists',
      }

      # Do "apt-get upgrade --download-only" every n-days (0=disable)
      file_line { 'download-upgradate-packages':
        path    => $periodic_conf_path,
        line    => 'APT::Periodic::Download-Upgradeable-Packages "1";',
        match   => '^APT::Periodic::Download-Upgradeable-Packages',
      }

      # Run the "unattended-upgrade" security upgrade script every n-days (0=disabled)
      #   Requires the package "unattended-upgrades" and will write
      #   a log in /var/log/unattended-upgrades
      file_line { 'enable unattended-upgrades':
        path    => $periodic_conf_path,
        line    => 'APT::Periodic::Unattended-Upgrade "1";',
        match   => '^APT::Periodic::Unattended-Upgrade',
      }

      # Do "apt-get autoclean" every n-days (0=disable)
      file_line { 'auto-clean':
        path    => $periodic_conf_path,
        line    => 'APT::Periodic::AutocleanInterval "7";',
        match   => '^APT::Periodic::AutocleanInterval',
      }
    }
  }

}
