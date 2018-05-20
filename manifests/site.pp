#
# To define a role for the current machine you need to create the file '/etc/role_puppet'
# and on the first line write the name of the role you want to deploy. 
#      
node default {
  include "role::${::role}"
  # make sure we haven't started the puppet daemon ever
  # this might break a report on an agent that triggers this via a daemonized run.
  service { 'puppet':
    enable => false,
    ensure => stopped,
  }
}