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
```
sudo cat /etc/snmp/snmpd.conf #v1
sudo cat /usr/share/snmp/snmpd.conf #v3
```

## Host snmpwalk
```
snmpwalk -v 1 -c <VALUE> -ObentU localhost:161 1.3 #v1

snmpwalk -v 3 -a SHA -A $auth_key_string -x AES -X $priv_key_string -l authPriv -u $snmpv3_user localhost:161 #v3
```

# 2. Install Agent:

## Agent `snmpwalk`
```
sudo datadog-agent snmp walk localhost:161 1.3 -C <COMMUNITY_STRING>

sudo datadog-agent snmp walk localhost:161 1.3 -v 3 -a SHA -A $auth_key_string -x AES -X $priv_key_string -l authPriv -u $snmpv3_user 
```

## 3.SNMP Integration Configuration

### V1:

```
init_config:
    loader: core
    use_device_id_as_hostname: true
instances:
  -
    ip_address: localhost
    snmp_version: 1
    loader: core
    use_device_id_as_hostname: true
    community_string: <COMMUNITY_STRING>
```

### V3:
```
init_config:
    loader: core
    use_device_id_as_hostname: true
instances:
  -
    ip_address: localhost
    snmp_version: 3
    loader: core
    use_device_id_as_hostname: true
    authProtocol: SHA
    privProtocol: AES
    user: $snmpv3_user
    authKey: $auth_key_string
    privKey: $priv_key_string
```

- SNMP Metrics should begin populating in Network Devices UI

---
# Build Custom Profile

- <link>https://github.com/Dog-Gone-Earl/Agent-Spec-Sandboxes/blob/main/SNMP/snmp_v1_profile/README.md</link>

## The `Sysobjectid` and `metrics` definition are stated as `required` with building a profile. From our documentation on building profiles:
- <link>https://datadoghq.dev/integrations-core/tutorials/snmp/profile-format/</link>

```
sysobjectid: <x.y.z...>

# extends:
#   <Optional list of base profiles to extend from...>

metrics:
  # <List of metrics to collect...>

# metric_tags:
#   <List of tags to apply to collected metrics. Required for table metrics, optional otherwise>
```
- Devices under same manufacturer/model tend to have same beginning `Sysobjectid` value

# Sysobjectid Fortinet-Fortigate Example
- https://community.fortinet.com/t5/Support-Forum/OID-Lists/m-p/30443
- https://github.com/DataDog/integrations-core/blob/master/snmp/datadog_checks/snmp/data/default_profiles/fortinet-fortigate.yaml

# Using `ddev` with `snmp`

## Validate a Profile
```
 ddev meta snmp validate-profile -f <FILE_NAME>
```

## Build a Profile

- Our ddev tool can help to build an yaml file.
Example
- from the CHECKPOINT MIB (file attached)
```
Checkpoint MIB
version: R81.20
```
<link>https://support.checkpoint.com/results/sk/sk90470</link>

- Using ddev to generate MIB
- <link>https://docs.datadoghq.com/developers/integrations/python/?tab=macos</link>
- <link>https://datadoghq.dev/integrations-core/tutorials/snmp/profiles/</link>

```
ddev meta snmp generate-profile-from-mibs CHECKPOINT-MIB
```
---
# Test Metric Collection

copied the snmpwalk to the snmp tests data
```
#PUT THE snmpwalk OUTPUT IN THIS DIRECTORY
~/PATH_TO_DDEV/integrations-core/snmp/tests/compose/data 

cp -r <SNMPWALK_OUTPUT> ./PATH_TO_DDEV/integrations-core/snmp/tests/compose/data/<SNMPWALK_FILENAME>
```

added the custom profile to the fixture user profiles that we use for tests
```
~/PATH_TO_DDEV/integrations-core/snmp/tests/fixtures/user_profiles/<PROFILE_NAME>

launched ddev (from integrations-core) with 
```
ddev env start snmp py3.11-false
``
I updated the config to use the snmpwalk data for the test instance with (ddev must be running) then update the community-string to the name of the snmpwalk file `community_string: <VALUE>`

```
ddev env config edit snmp py3.11-false
```

```
init_config:
  loader: core
  namespace: COMP-T210RX79FT
  use_device_id_as_hostname: true
instances:
- community_string: <SNMPWALK_FILENAME>
  profile: <PROFILE_NAME>
  ip_address: 172.22.0.2
  port: 1161
```

I reloaded with the new config and launched a snmp check 
```
ddev env reload snmp py3.11-false && ddev env check snmp py3.11-false
```

Fortinet-Fortigate Example
```
init_config:
  loader: core
  namespace: COMP-T210RX79FT
  use_device_id_as_hostname: true
instances:
- community_string: fortigate-test #fortigate-test.snmpwalk
  profile: fortinet-fortigate #fortinet-fortigate.yaml
  ip_address: 172.22.0.2
  port: 1161
```
![image](https://github.com/Dog-Gone-Earl/SNMP-Sandbox-Enablement/assets/107069502/65491323-d86e-4325-bc0e-8001eccd3f0f)

# `snmp` Troubleshooting:
- <link>https://datadoghq.atlassian.net/wiki/spaces/TS/pages/341017363/SNMP+101</link>
- <link>https://datadoghq.atlassian.net/wiki/spaces/TS/pages/2409398887/NDM+Field+Expedient+Troubleshooting+from+DD+agent+perspective</link>
- <link>https://datadoghq.atlassian.net/wiki/spaces/TS/pages/2093220667</link>

Build CUstom Profile
- <link>https://docs.datadoghq.com/network_monitoring/devices/profiles</link>
- <link>https://docs.datadoghq.com/network_monitoring/devices/guide/build-ndm-profile/</link>
- <link>https://datadoghq.dev/integrations-core/tutorials/snmp/profile-format/</link>
- <link>https://datadoghq.atlassian.net/wiki/spaces/~70121cdee4dd346db4f04b0f898148e69bd67/pages/3256352987/Create+NDM+Polling+Profile+Steps</link>
- <link>https://datadoghq.atlassian.net/wiki/spaces/~70121cdee4dd346db4f04b0f898148e69bd67/pages/3256352987/Create+NDM+Polling+Profile+Steps</link>



