# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.hostname = "odoovm"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "8192"]
  end

  config.vm.network "forwarded_port", guest: 8069, host: 8069
  config.vm.network "forwarded_port", guest: 5432, host: 5432

  config.vm.provision "base", type: "shell", path: "shell/install.sh"
  config.vm.provision "helpdesk", type: "shell", path: "shell/helpdesk.sh"
  config.vm.provision "sale-workflow", type: "shell", path: "shell/sale-workflow.sh"
  config.vm.provision "account-closing", type: "shell", path: "shell/account-closing.sh"
  config.vm.provision "custom", type: "shell", path: "shell/custom.sh", run: "never"

end
