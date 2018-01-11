class profile::database_server::postgresql (
    $databases = undef,
) {
    # password for default user  `postgresql`
    $postgres_password = lookup('database_server::postgresql::postgres_password')
    class { 'postgresql::globals':
        encoding => 'UTF-8',
        locale   => 'en_US.UTF-8',
    }
    class {'postgresql::server':
        postgres_password => $postgres_password,
    }
    # make it listen only on localhost, remote connections will not be possible
    postgresql::server::config_entry {'listen_addresses':
        value => 'localhost'
    }
    # create a database and a user with all privileges on the db
    $databases.each |$name, $userparams| {
        if $name and $userparams['user'] and $userparams['password'] {
            postgresql::server::db { $name:
                user     => $userparams['user'],
                password => postgresql_password($userparams['user'], $userparams['password']),
            }
        }
    }
}