#!/bin/bash

# Read private IPs from file
private_ips=$(cat private_ips.txt)

# Iterate through each IP and install Java
for ip in $private_ips
do
  # Determine OS type
  os=$(ssh -i "nani.pem" ec2-user@$ip "uname -a")
  
  if [[ $os == "Ubuntu" ]]; then
    ssh -i "nani.pem" ec2-user@$ip "sudo apt-get update && sudo apt-get install -y default-jdk"
  elif [[ $os == "Red Hat" ]]; then
    ssh -i "nani.pem" ec2-user@$ip "sudo yum update && sudo yum install -y java-1.8.0-openjdk"
fi
done
