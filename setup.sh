#!/bin/bash

# check that the necessary files/folders exist
if [[ ! -f /etc/fossil.conf ]]
then
  sudo touch /etc/fossil.conf
fi

if [[ ! -d /var/fossil/archives ]]
then
  sudo mkdir -p /var/fossil/archives
fi

# make sure we have the necessary permissions
sudo chmod 666 /etc/fossil.conf
sudo chown root /var/fossil/archives
