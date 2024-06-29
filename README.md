# 1. Clone Repo
```
git clone https://github.com/Dog-Gone-Earl/SNMP-Sandbox-Enablement.git
```
- These are sandboxes for `V1` and `V3` options
- These sandboxes were tested on a Vagrant (Ubuntu) and AWS EC2 Instance (Ubuntu).
  - If running on Ec2, just copy and paste `setup.sh` script to instance and run with `bash`

## V1 vs V2 vs V3 Configuration

- `V1` and `V2` confiugration will use a `community_string`
```
SNMP Version 1 or 2c specific
  -c COMMUNITY		set the community string
```
- Community string information:
   - <link>https://www.dnsstuff.com/snmp-community-string</link> 
`V3` configuration will have more configurations information
```
SNMP Version 3 specific
  -a PROTOCOL		set authentication protocol (MD5|SHA)
  -A PASSPHRASE		set authentication protocol pass phrase
  -e ENGINE-ID		set security engine ID (e.g. 800000020109840301)
  -E ENGINE-ID		set context engine ID (e.g. 800000020109840301)
  -l LEVEL		set security level (noAuthNoPriv|authNoPriv|authPriv)
  -n CONTEXT		set context name (e.g. bridge1)
  -u USER-NAME		set security name (e.g. bert)
  -x PROTOCOL		set privacy protocol (DES|AES)
  -X PASSPHRASE		set privacy protocol pass phrase
  -Z BOOTS,TIME		set destination engine boots/time
```

- `PROTOCOL`, `PASSPHRASE`, `PROTOCOL`, `PASSPHRASE`, and `USER-NAME` are common configurations seen from tickets.
- Can get more developer information with command `man snmmpwalk`

## Checking snmp Configuration Locations
```
sudo cat /etc/snmp/snmpd.conf #V1
sudo cat /usr/share/snmp/snmpd.conf #V3
```

## Host snmpwalk
- Information on snmpwalk and snmpget commands:
   - <link>https://www.ionos.com/digitalguide/server/know-how/snmp-tutorial/</link>
   - Sometimes customer may refer to either command. `snmpwalk` and `snmpget` are among the included solutions for retrieving information from SNMP-enabled devices using simple `GET` requests (`snmpget`) or multiple `GETNEXT` requests (`snmpwalk`).
   - GETNEXT
      - <link>https://net-snmp.sourceforge.io/wiki/index.php/GETNEXT</link>
```
snmpwalk -v 1 -c <VALUE> -ObentU localhost:161 1.3 #V1

snmpwalk -v 3 -a SHA -A $auth_key_string -x AES -X $priv_key_string -l authPriv -u $snmpv3_user localhost:161 #V3
```

# 2. Agent Configuration:
- Install Agent with Sandbox account

## Agent `snmpwalk`
   - This command is similar to host `snmpwalk` command:
```
sudo datadog-agent snmp walk localhost:161 1.3 -C <COMMUNITY_STRING>

sudo datadog-agent snmp walk localhost:161 1.3 -v 3 -a SHA -A $auth_key_string -x AES -X $priv_key_string -l authPriv -u $snmpv3_user 
```

## 3.SNMP Integration Configuration

### `V1`:

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

### `V3`:
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

Checkpoint MIB File
<link>https://support.checkpoint.com/results/sk/sk90470</link>

- Using ddev to generate MIB
- <link>https://docs.datadoghq.com/developers/integrations/python/?tab=macos</link>
- <link>https://datadoghq.dev/integrations-core/tutorials/snmp/profiles/</link>

```
ddev meta snmp generate-profile-from-mibs CHECKPOINT-MIB
```
---
# Simulate snmp Profile Metrics Collection with `ddev`

copied the snmpwalk to the snmp tests data
```
#PUT THE snmpwalk OUTPUT IN THIS DIRECTORY
~/PATH_TO_DDEV/integrations-core/snmp/tests/compose/data 

cp -r <SNMPWALK_OUTPUT> ~/PATH_TO_DDEV/integrations-core/snmp/tests/compose/data/<SNMPWALK_FILENAME>
```

added the custom profile to the fixture user profiles that we use for tests
```
~/PATH_TO_DDEV/integrations-core/snmp/tests/fixtures/user_profiles/<PROFILE_NAME>

```
launched ddev (from integrations-core) with 

```
ddev env start snmp py3.11-false
```
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



