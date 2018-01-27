#!/bin/bash
#
# Installs masterless puppet on the local machine
# Currently only Debian based nix are supported
# Note:
# The script is not failure proof. It means that in case of failure or execution abortion
# this script will not clean partialy installed data. 
#-------------------------------------------------------------------------------
# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-vhdD] [role]
    This script will deploy a masterless puppet environment on the the local machine. 
    The target environment is retrieved from 'puppet config print environment'

    -h          display this help and exit
    -v          verbose mode. Can be combined with -d
    -d          debug mode. Can be combined with -v
    -D          bash debug mode
    
    Example:
        ${0##*/} -v -d 
    role:
        The puppet role you want to deploy
EOF
}

OPTIND=1
# Resetting OPTIND is necessary if getopts was used previously in the script.
# It is a good idea to make OPTIND local if you process options in a function.

while getopts hvdD opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        v)  VERBOSE="--verbose"
            ;;
        d)  DEBUG="--debug"
            ;;
        D)  DEBUG="--debug"
            set -x # enables bash debug
            ;;
        *)
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"   # Discard the options and sentinel --

# Install puppet5 release
install_puppet_release()
{
    
    if ! dpkg-query -s lsb-release &> /dev/null
    then
        apt-get install lsb-release >&2
    fi
    
    if ! dpkg-query -s puppet5-release &> /dev/null
    then
        CODENAME=$(lsb_release -sc)
        DEST="/tmp/puppet5-release-$CODENAME.deb"
        wget "https://apt.puppetlabs.com/puppet5-release-$CODENAME.deb" -O "$DEST"
        dpkg -i "$DEST"
    fi
}
# install puppet agent
if ! dpkg-query -s puppet-agent &> /dev/null 
then
    apt-get update && 
    install_puppet_release &&
    apt-get update && apt-get install puppet-agent >&2
fi


# verify if puppet is installed and try to install it otherwise!
if puppet --version -eq 127 # 127 => command not found  
then
    echo "Try to install puppet"
    SYSBINPATH=$(systemd-path system-binaries)
    ln -s /opt/puppetlabs/puppet/bin/puppet "$SYSBINPATH/puppet"
    if puppet --version -eq 127
    then
        echo "Puppet app is missing! Install it before continuing!"
        exit 1
    fi
fi

PUPPET_CONFDIR=$(puppet config print confdir)
PUPPET_ENVPATH=$(puppet config print environmentpath)
#PUPPET_MODULEPATH=$(puppet config print modulepath)
PUPPET_ENVIRONMENT=$(puppet config print environment)
    
module_install()
{
    if [ ! "$(puppet module list | grep -c "$1")" -gt 0 ]; then
        puppet module install "$1"
    fi
}

# make sure envrionment direcory exists because we don't want to install global modules because
# they will not be cleaned afterwards.
if [ ! -d "$PUPPET_ENVPATH/$PUPPET_ENVIRONMENT" ]; then
    mkdir "$PUPPET_ENVPATH/$PUPPET_ENVIRONMENT"
fi

# Set a temporary environment and install hiera and r10k before deploying expected environment.
cd "$PUPPET_CONFDIR" || exit 1
module_install "puppet-hiera"
module_install "puppet-r10k"

INIT=$(cat <<-EOM
    node default {
        group { 'puppet':
            ensure => 'present',
            gid    => '111',
        }->
        user { 'puppet':
            ensure           => 'present',
            gid              => '111',
            home             => '/etc/puppetlabs/puppet',
            password         => '!!',
            password_max_age => '0',
            password_min_age => '0',
            shell            => '/bin/false',
            uid              => '107',
        }->
        package {'librarian-puppet': ensure => 'installed', provider => 'gem'}->
        file { '/usr/bin/puppet_deploy':
            ensure => 'link',
            target => "\${::settings::environmentpath}/\${::settings::environment}/bin/puppet_deploy",
        }->
        file { '/usr/bin/update_rp':
            ensure => 'link',
            target => "\${::settings::environmentpath}/\${::settings::environment}/bin/update_rp.rb",
        }->
        class { 'r10k':
            sources => {
              'igorovic_masterless' => {
                'remote'  => 'https://github.com/igorovic/puppet_masterless.git',
                'basedir' => "\${::settings::environmentpath}",
                'prefix'  => false,
              },
            },
            postrun             => ["/bin/sh", "-c", "\${::settings::environmentpath}/${PUPPET_ENVIRONMENT}/bin/install_roles_and_profiles.sh \${::settings::environmentpath}/${PUPPET_ENVIRONMENT}"],
            configfile          => "\${::settings::confdir}/r10k.yaml",
            provider            => 'gem',
            puppet_master       => false,
            
        }
        contain 'r10k' # explicit class containement according to puppet documentation
        
        class { 'hiera':
            hiera_version => '5',
            hierarchy => [
                {"name" => "certname", "path" => "%{trusted.certname}.yaml"},
                {"name" => "common", "path" => "common.yaml"},
                {"name" => "secrets", "path" => "secrets.eyaml", "lookup_key"=>"eyaml_lookup_key",
                    "options"=>{"pkcs7_private_key"=>"\${::settings::confdir}/keys/private_key.pkcs7.pem",
                               "pkcs7_public_key"=>"\${::settings::confdir}/keys/public_key.pkcs7.pem"}},
            ],
            datadir     => "\${::settings::confdir}/data",
            eyaml       => true,
            hiera_yaml  => "\${::settings::confdir}/hiera.yaml",
        }->
        # with puppet5, eyaml is not installed in the search path thus we create a symlink
        file { '/usr/local/bin/eyaml':
            ensure => 'link',
            target => '/opt/puppetlabs/puppet/bin/eyaml',
        }
        contain 'hiera' # explicit class containement according to puppet documentation
    }
EOM
)

# Install initial pupet-r10k and puppet-hiera 
puppet apply $VERBOSE $DEBUG -e "$INIT"
# deploy environment
r10k deploy environment "$PUPPET_ENVIRONMENT" -v
if ! cd "$PUPPET_ENVPATH/$PUPPET_ENVIRONMENT" 
then
    librarian-puppet install $VERBOSE
else
    echo "Error during 'r10k deploy environment'!"
fi
# deploy the request role
if [ ! -z "$1" ]; then
    echo "$1" > /etc/role_puppet
    puppet apply "$PUPPET_ENVPATH/$PUPPET_ENVIRONMENT/manifests/site.pp" $VERBOSE $DEBUG 
fi
exit 0
