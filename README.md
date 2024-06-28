## 1. Clone Repo
```
git clone https://github.com/Dog-Gone-Earl/SNMP-Sandbox-Enablement.git
```

- This script should work on Vagrant (Ubuntu) or AWS EC2 Instance (Ubuntu).

## Folder Structure: 
```
snmp-sandbox-enablement (folder)
   → Vagrantfile (file)
   → setup.sh (file)
   → data (folder)
   → shared (folder)
```
- This script should work on Vagrant (Ubuntu) or AWS EC2 Instance (Ubuntu).

```
#!/bin/bash

comm_string=<VALUE>
echo "Provisioning!"
sudo apt-get update -y; sudo apt-get upgrade -y; sudo apt-get install -y snmpd snmp
sudo sed -i '73i rocommunity '$comm_string'' /etc/snmp/snmpd.conf
sudo sed -i "s/agentaddress  127.0.0.1,[::1]/agentAddress udp:161,udp6:[::1]:161/1" /etc/snmp/snmpd.conf
sudo service snmpd restart
```


## Checking snmp Configuration

### 1. Set a `community string` value in the `setup.sh` file:
```
comm_string=<VALUE>
```

### 2. Start the sandbox:
```
./run.sh up;
.run.sh ssh;
```

### 3. You should be able to run `agent snmpwalk` and host `snmpwalk` comnands to poll OID's:

#### Example:

```
snmpwalk -v 1 -c <COMMUNITY_STRING> -ObentU localhost:161 1.3
sudo datadog-agent snmp walk localhost:161 1.3 -C <COMMUNITY_STRING>
```

## SNMP Metrics should begin populating in Network Devices UI
