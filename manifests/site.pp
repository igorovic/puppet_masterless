#
# To define a role for the current machine you need to create the file '/etc/role_puppet'
# and on the first line write the name of the role you want to deploy. 
#      
node default {
  include "role::${::role}"
  file { '/usr/bin/puppet_deploy':
    ensure => 'link',
    target => "${::environmentpath}/${::environment}/bin/puppet_deploy",
  }
}