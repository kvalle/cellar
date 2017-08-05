# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname = "cellar"

  config.vm.provision "shell", inline: <<-SCRIPT
    sudo apt-get update
    sudo apt-get install python -y
    sudo apt-get install python-setuptools -y
    sudo apt-get install ansible -y
    sudo easy_install pip
    sudo pip install virtualenv
SCRIPT
  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.vm.network "forwarded_port", guest: 9000, host: 9000
  config.vm.synced_folder "", "/home/ubuntu/cellar"

  config.vm.provider :virtualbox do |v|
    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
    # Need more memory in order to install zappa
    v.customize ["modifyvm", :id, "--memory", "2048"]
  end
end
