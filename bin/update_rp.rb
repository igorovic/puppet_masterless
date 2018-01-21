#!/opt/puppetlabs/puppet/bin/ruby
# updates roles and profiles for puppet_masterless environment
require 'puppet'
puts "updating roles and profiles"
puts "==========================="
Puppet.initialize_settings()
environment = Puppet.settings[:environment]
envpath     = Puppet.settings[:environmentpath]
sitepath    = File.join(envpath, environment, 'site')
clean = "rm -rf #{sitepath}"
puts clean
Facter::Util::Resolution.exec(clean)
repo = "https://github.com/igorovic/puppet_roles_and_profiles.git"
gitdir = File.join( sitepath, '.git')
gitclone = "git clone #{repo} #{sitepath} && rm -rf #{gitdir}"
puts gitclone
Facter::Util::Resolution.exec(gitclone)
