# SNMP V3

## VM type: 
- Linux Ubuntu

## SNMP V3 Configuration Mapping/Security Protocols:
```
auth-protocol=SHA
auth-key=$auth_key_string
priv-protocol=AES
priv-key=$priv_key_string 
security-level=authPriv
user=$snmpv3_user
```

## 1. Configure in `setup.sh` File your `VALUES` (minimum 8 characters):
```
auth_key_string=<VAlUE>
priv_key_string=<VAlUE>
snmpv3_user=<VAlUE>
```

## 2. Spin Up Sandbx:
```
vagrant up;
vagrant ssh
```

#### You should be able to run `host snmpwalk` comnand to poll OID's:
```
snmpwalk -v 3 -a SHA -A $auth_key_string -x AES -X $priv_key_string -l authPriv -u $snmpv3_user localhost:161 #V3
```
- Use the `<VALUE>` Set in `setup.sh` File:
```
$auth_key_string=<AUTH_VALUE>
$priv_key_string=<PRIV_VALUE>
$snmpv3_user=<USER_VALUE>
```

- Or Set `Environment Variables` on host:
```
export auth_key_string=<VALUE>;
export priv_key_string=<VALUE>;
export snmpv3_user=<VALUE>
```
Can use the `netstat -nlpu|grep snmp -v` command to see if `snmp` service listening on `127.0.0.1` aka `localhost` 

### 3. Install Agent:

#### You should now be able to run `agent snmpwalk` comnand to poll OID's:

#### Example:

```
sudo datadog-agent snmp walk localhost:161 1.3 -v 3 -a SHA -A $auth_key_string -x AES -X $priv_key_string -l authPriv -u $snmpv3_user 
```

### 4. Create `snmp` integration configuration `yaml` named `conf.yaml` located at `/etc/datadog-agent/conf.d/snmp.d/`:
- snmp `yaml` Configuration should reflect your `VALUES` set in `setup.sh` script:
  
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
    tags:
      - minor:<VALUE>
    user: $snmpv3_user
    authKey: $auth_key_string
    privKey: $priv_key_string
```

### 5. Restart Agent
```
sudo service datadog-agent restart
```

## SNMP Metrics should begin populating in Network Devices UI
