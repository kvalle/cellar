# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "cellar"

  config.vm.provision "shell", inline: <<-SCRIPT
    sudo apt-get install python-pip -y
    sudo apt-get install git -y
    sudo pip install PyYAML
    git clone https://github.com/kvalle/dotfiles.git
SCRIPT
  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.vm.network "forwarded_port", guest: 9000, host: 9000
  config.vm.synced_folder "", "/home/vagrant/cellar"
end
