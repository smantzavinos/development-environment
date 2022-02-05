# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = "bento/ubuntu-20.04"

  # default timeout is 300
  config.vm.boot_timeout = 600

  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
  
  config.vm.provider "hyperv" do |v|
    v.cpus = 4
    v.memory = 2048
  end

  # Disable synced folder
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Network settings are ignored for Hyper-V provider
  # config.vm.network "forwarded_port", guest: 4000, host: 4040

  config.vm.provision "apt-get update", type: "shell" do |s|
    s.inline = "sudo apt-get update"
  end

  config.vm.provision "install xfce", type: "shell" do |s|
    s.inline = "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4"
  end
  
  # Permit anyone to start the GUI
  config.vm.provision "allow anyone to start GUI", type: "shell" do |s|
    s.inline = "sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config"
  end
  
 config.vm.provision 'shell', privileged: false, path: 'provisioning/provision.sh'

  # Run Ansible from the Vagrant VM
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
  end

end

