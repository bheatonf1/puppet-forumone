include forumone

define forumone::webserver::vhost (
  $aliases        = undef,
  $servername     = localhost,
  $path           = undef,
  $allow_override = ['All'],
  $source         = undef,
  $fastcgi_pass   = "unix:${::forumone::webserver::php_fpm_listen}") {
  if $path {
    if $::forumone::webserver::webserver == 'apache' {
      apache::vhost { $name:
        servername    => $servername,
        aliases       => $aliases,
        port          => $::forumone::webserver::port,
        docroot       => $path,
        docroot_group => $::host_gid,
        docroot_owner => $::host_uid,
        directories   => [{
            path           => $path,
            allow_override => $allow_override
          }
          ]
      }

      apache::vhost { "${name}-ssl":
        port          => '443',
        docroot       => $path,
        docroot_group => $::host_gid,
        docroot_owner => $::host_uid,
        directories   => [{
            path           => $path,
            allow_override => $allow_override
          }
          ],
        ssl           => true,
      }
    } elsif $::forumone::webserver::webserver == 'nginx' {
      if empty($source) {
        nginx::file { "${name}.conf":
          content => inline_template(file("/etc/puppet/modules/forumone/templates/webserver/nginx/vhost_${::forumone::webserver::platform}.erb", "/etc/puppet/modules/forumone/templates/webserver/nginx/vhost_html.erb"
          )),
          notify  => Service['nginx'],
          require => Exec['create_self_signed_sslcert']
        }
      } else {
        nginx::file { "${name}.conf":
          content => inline_template(file($source)),
          notify  => Service['nginx'],
          require => Exec['create_self_signed_sslcert']
        }
      }
    }
  }
}

