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
You may also need to create a Virtual Switch for Hyper-V. If so (you will know because `vagrant up` will fail), you can create one with:
```powershell
New-VMSwitch -name InternalSwitch -SwitchType Internal
```
More info on Virtual Switches here: [Create a virtual switch for Hyper-V virtual machines](https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-switch-for-hyper-v-virtual-machines)

### Alacritty
Recommend using alacritty as the terminal on the Windows host. It is GPU accelerated, so it has the best performance of terminals I have found. Particularly when re-rendering the full screen, like you do when moving between tabs in vim.

Preferred font: [Consolas NF](https://github.com/whitecolor/my-nerd-fonts/tree/master/Consolas%20NF)

Configure Alacritty to use the font by creating or editing `~\AppData\Roaming\alacritty\alacritty.yml` with:
```YAML
# Font configuration (changes require restart) 
font: 
  # The size to use. 
  size: 12 
  # The normal (roman) font face to use. 
  normal: 
    family: Consolas NF 
    # Style can be specified to pick a specific face. 
    style: Book 
  # The bold font face 
  bold: 
    family: Consolas NF 
    # Style can be specified to pick a specific face. 
    style: Bold 
  # The italic font face 
  italic: 
    family: Consolas NF 
    # Style can be specified to pick a specific face. 
    style: Italic
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
```

#### Set ZSH as default shell
I had trouble getting ZSH to stick as the default shell. You can run this to set it. 
```sh
sudo chsh -s $(which zsh) $(whoami)
```
Note: you will need to log out and reconnect for the change to take effect. 


# Tips and tricks

## vim
### Vim settings for easy copy and paste
There is no setup to share the host clipboard with the VM. You can copy paste text directly within Alacritty. Copy paste shortcuts for Alacritty are Ctrl+Shift+C and Ctrl+Shift+V.
The problem is this also copies any text along the left edge (line numbers and git gutter). These can be disabled with:
#### Turn off line numbers
```vim
set nonumber norelativenumber
```
#### Hide vim gutter
```vim
set signcolumn=no
```
