class profile::python(
    $python_version          = '3',
){
    class { 'profile::python::install':
        python_version => $python_version,
    }
    
}