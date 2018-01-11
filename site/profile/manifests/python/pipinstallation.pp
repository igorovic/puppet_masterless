define profile::python::pipinstallation (
  $python_version = $title,
) {

  $get_pip_url = 'https://bootstrap.pypa.io/get-pip.py'

  Exec {
    path    => ['/usr/bin', '/usr/local/bin', '/bin/'],
    require => Package['curl'],
  }

  exec { "install-pip${python_version}":
    command => "curl -L ${get_pip_url} | python${python_version}",
    unless  => "which pip${python_version}",
    onlyif  => "which python${python_version}",
  }

}
