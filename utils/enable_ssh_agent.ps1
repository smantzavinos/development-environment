
# What is this script
#
# This script will enable the ssh-agent on Windows. This will allow you
# to forward the host ssh keys into the Vagrant VM environment.
#
# Rererences:
#   https://stackoverflow.com/questions/24681167/use-ssh-private-key-from-host-in-vagrant-guest
#   https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement


# How to use this script
#
# Running script may be disabled on your system. You can run this with the
# following command to bypass that limitation.
#   powershell -ExecutionPolicy Bypass -File enable_ssh_agent.ps1
#
# Adding your ssh keys to the agent:
#   ssh-add C:\Users\smant\.ssh\id_ed25519
#
# Check that your key is in the list:
#   ssh-add -l


Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser

# By default the ssh-agent service is disabled.
# Allow it to be manually started for the next step to work.
# Make sure you're running as an Administrator.
Get-Service ssh-agent | Set-Service -StartupType Manual

# Start the service
Start-Service ssh-agent

# This should return a status of Running
Get-Service ssh-agent
