# Uses /etc/role_puppet to determine the node's role
Facter.add(:role) do
  confine :kernel => 'Linux'
  setcode do
    if File.exist? '/etc/role_puppet'
        Facter::Core::Execution.exec('/usr/bin/head -1 /etc/role_puppet')
    else
      "base"
    end
  end
end