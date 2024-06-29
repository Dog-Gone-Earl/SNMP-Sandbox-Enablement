#!/bin/bash

auth_key_string=<VALUE>
priv_key_string=<VALUE>
snmpv3_user=<VALUE>

echo "Provisioning!"
echo ""

echo "apt-get updating"
sudo apt-get update -y
sudo apt-get upgrade -y
echo "install curl if not there..."
sudo apt-get install -y curl

sudo apt install snmpd snmp libsnmp-dev -y

sudo cp /etc/snmp/snmpd.conf{,.bak}
sudo apt install net-tools -y
sudo systemctl stop snmpd #default_pw: 'vagrant'
sudo cp /usr/bin/net-snmp-create-v3-user ~/
sudo sed -ie '/prefix=/adatarootdir=${prefix}\/share' /usr/bin/net-snmp-create-v3-user
sudo net-snmp-create-v3-user -ro -A $auth_key_string -a SHA -X $priv_key_string -x AES $snmpv3_user

#sudo ufw allow from 192.168.99.152 to any port 161 proto udp comment "Allow SNMP Scan from Monitoring Server"
sudo ufw allow from 127.0.0.1 to any port 161 proto udp comment "Allow SNMP Scan from Monitoring Server"

sudo systemctl start snmpd
sudo systemctl enable snmpd

echo "run the command: export auth_key_string=$auth_key_string; export priv_key_string=$priv_key_string;export snmpv3_user=$snmpv3_user"
