#!/bin/bash


comm_string=<VALUE>
echo "Provisioning!"
sudo apt-get update -y; sudo apt-get upgrade -y; sudo apt-get install -y snmpd snmp
sudo sed -i '73i rocommunity '$comm_string'' /etc/snmp/snmpd.conf
sudo sed -i "s/agentaddress  127.0.0.1,[::1]/agentAddress udp:161,udp6:[::1]:161/1" /etc/snmp/snmpd.conf
sudo service snmpd restart