class profile::database_server (
    $database_engine    = undef,
    $databases          = undef,
){
    if $database_engine != undef {
        class { "profile::database_server::${$database_engine}":
            databases => $databases,
        }
    }
    
}
