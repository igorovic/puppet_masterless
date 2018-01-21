#!/opt/puppetlabs/puppet/bin/ruby
# updates roles and profiles for puppet_masterless environment
require 'readline'
require 'puppet'

def input(prompt="", newline=false)
    prompt += "\n" if newline
    Readline.readline(prompt, true).squeeze(" ").strip
end

puts "updating roles and profiles"
puts "==========================="
Puppet.initialize_settings()
environment = Puppet.settings[:environment]
envpath     = Puppet.settings[:environmentpath]
sitepath    = File.join(envpath, environment, 'site')
clean = "rm -rf #{sitepath}"
repo = "https://github.com/igorovic/puppet_roles_and_profiles.git"
gitdir = File.join( sitepath, '.git')
gitclone = "git clone #{repo} #{sitepath} && rm -rf #{gitdir}"

puts "Following actions will be performed!"
puts clean
puts gitclone
continue = input "Would you like to continue? [No/yes]"
if not continue == ""
  if continue[0].downcase == 'y'
    Facter::Util::Resolution.exec(clean)
    Facter::Util::Resolution.exec(gitclone)
  else
    puts "Canceled"
  end
end

