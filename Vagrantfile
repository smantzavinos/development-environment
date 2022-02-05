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

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "pgrunwald/elixir-phoenix-ubuntu-trusty64"
  
  config.vm.box = "bento/ubuntu-20.04"
  #config.vm.box = "ubuntu/focal64"

  #config.vm.box = "peru/ubuntu-20.04-desktop-amd64"
  #config.vm.box_version = "20210601.01"

  #config.vm.box = "sn0wf4k3/focal-ubuntu-desktop"
  #config.vm.box_version = "0.0.1"

  # default timeout is 300
  config.vm.boot_timeout = 600

  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
  
  #config.vm.provider "virtualbox" do |v|
  config.vm.provider "hyperv" do |v|
    #v.gui = true
    v.cpus = 4
    v.memory = 2048
    #v.customize ["modifyvm", :id, "--vram", 64]
    #v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    #v.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
  end

  # Disable synced folder
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Network settings are ignored for Hyper-V provider
  config.vm.network "forwarded_port", guest: 4000, host: 4040

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
  
 # Vagrant.configure("2") do |config|
 #   config.vm.provision "ansible_local" do |ansible|
 #     ansible.playbook = "provisioning/playbook.yml"
 #   end
 # end

 config.vm.provision 'shell', privileged: false, path: 'provisioning/provision.sh'
 #config.vm.provision :reload

  # Run Ansible from the Vagrant VM
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
  end

  # https://askubuntu.com/questions/1067929/on-18-04-package-virtualbox-guest-utils-does-not-exist
#  config.vm.provision "apt-get update", type: "shell" do |s|
#    s.inline = "sudo apt-add-repository multiverse && sudo apt-get update"
#  end

#  config.vm.provision "install ubuntu desktop", type: "shell" do |s|
#    s.inline = "sudo apt install -y --no-install-recommends ubuntu-desktop"
#  end

  # Install xfce and virtualbox additions.
  # (Not sure if these packages could be helpful as well: virtualbox-guest-utils-hwe virtualbox-guest-x11-hwe)
#  config.vm.provision "install virtualbox tools", type: "shell" do |s|
#    s.inline = "sudo apt-get install -y xfce4 virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11"
#  end
  # Permit anyone to start the GUI
#  config.vm.provision "install virtualbox tools", type: "shell" do |s|
#    s.inline = "sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config"
#  end

  # Add `vagrant` to Administrator
#  config.vm.provision "make vagrant user an admin", type: "shell" do |s|
#    s.inline = "sudo usermod -a -G sudo vagrant"
#  end

  # Optional: Use LightDM login screen (-> not required to run "startx")
#  config.vm.provision "shell", inline: "sudo apt-get install -y lightdm lightdm-gtk-greeter"
  # Optional: Install a more feature-rich applications menu
#  config.vm.provision "shell", inline: "sudo apt-get install -y xfce4-whiskermenu-plugin"



  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
