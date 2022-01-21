# development-environment
Virtual machine based development environment for a variety of programming languages

# Purpose

# Design Goals
1) Repeatable development environment for all users.
2) Easy to develop the same codebase on multiple computers.
3) Fully automatic confiugration of development tools and plugins.
4) Can be used as as standalone development environment or as a template to start a project specific development environment.
5) Quick and easy to configure the first time.
6) Fast to start up each time it is needed.
7) Share files with the host machine.
8) Minimum requirements for the host machine.
9) Desktop GUI available if needed.
10) Virtualization allowed in the development environment (use Docker inside the VM if needed)
11) Supports Windows host machine (others should work too but are not tested at this time)

# Design

## Virtual Machine
Virtualization is provided by [Vagrant by HashiCorp](https://www.vagrantup.com/) using the [Hyper-V](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/about/) provider.

## Supported Languages

- Elixir
- Javascript
- C/C++
- Python

### Future Supported Languages
- Rescript

## Development Tools

# Help

## Host Setup and Install

### Git
[Download Git](https://git-scm.com/downloads)

### Vagrant
[Download Vagrant](https://www.vagrantup.com/downloads)

### Hyper-V
Hyper-V is hardware virtualization provided by Windows. It requires Windows 10 Pro or higher. Read more [here](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/about/).

You can enable Hyper-V by following the Microsoft instructions: [Install Hyper-V on Windows 10](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v)

Alternatively, you can enable Hyper-V by running the following PowerShell command as an Admin:
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All
```

## Usage

### Start
```powershell
cd C:\Path\to\this\file
vagrant up
```
The first run of this command took 22 minutes on my laptop.

### Connect
```powershell
vagrant ssh
```

#### Port Forwarding
You can start the ssh connection to the vagrant VM with port forwarding. This example forwards host port 4040 to VM port 4000. You can forward the same port number as well.
```powershell
vagrant ssh -- -L 4040:localhost:4000

##### Set ZSH as default shell
I had trouble getting ZSH to stick as the default shell. You can run this to set it. 
```sh
sudo chsh -s $(which zsh) $(whoami)
```
Note: you will need to log out and reconnect for the change to take effect. 
```

