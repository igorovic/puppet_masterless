# Installation
Use the install script provided [install.sh](https://raw.githubusercontent.com/igorovic/puppet_masterless/master/bin/install.sh)
This script will install all the base requirements puppet, puppet-hiera and puppet-r10k, puppet roles and profiles.
It will also add the following utilities: 
* puppet_deploy 
* update_rp.rb
## puppet_deploy
This command help to deploy a role properly.
**Usage**
```console
puppet_deploy <myrole>
```
* **myrole**: the role you want to deploy. The role must exist first in the puppet environment. When given in the command line, the role name will be added into the _**/etc/role_puppet**_. The role in this file will be used by puppet to determine how to deploy packages.
If the role is not specified on the command line then it is read from the file /etc/role_puppet. 

## update_rp.rb
This script helps to update roles and profiles since they are in a separate git repository. 
**Udage**
```console
root@igordev:/etc# update_rp
updating roles and profiles
===========================
Following actions will be performed!
rm -rf /etc/puppetlabs/code/environments/production/site
git clone https://github.com/igorovic/puppet_roles_and_profiles.git /etc/puppetlabs/code/environments/production/site && rm -rf /etc/puppetlabs/code/environments/production/site/.git
Would you like to continue? [No/yes]yes
root@igordev:/etc#
````


# Roles and Profiles
Roles and profiles are shipped along the environment. There si no good reason to make a separate repository for them.
This post gives some reasons not to separate roles and profiles from the control-repo. 
* https://github.com/bentlema/puppet-tutorial-pe/blob/master/tutorial/vbox/11-Roles-and-Profiles.md

The official control-repo given as an example is also shipped with roles and profiles inside.
* https://github.com/puppetlabs/control-repo