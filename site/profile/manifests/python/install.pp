class profile::python::install (
    $python_version = '3',
){
    package { "python${python_version}":
        ensure => 'installed',
    }
    include git
    ensure_packages(['curl'], {'ensure'=>'present'})
    ensure_resource('profile::python::pipinstallation', "${python_version}")
    package { 'pipenv':
        ensure => 'installed',
        provider => "pip${python_version}",
    }->
    # create a symlinkg in case it does not exist
    file { '/usr/bin/python':
      ensure => 'link',
      target => "/usr/bin/python${python_version}",
    }
}