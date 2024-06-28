# SNMP V3

## SNMP V3 Configuration:
```
auth-protocol string=SHA
auth-key string=$auth_key_string
priv-proto string=AES
priv-key string=$priv_key_string 
security-level string=authPriv
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
./run.sh up;
./run.sh ssh
```
- ### snmp `yaml` Configuration will Reflect your `VALUES`:
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
      - minor:jammy
    user: $snmpv3_user
    authKey: $auth_key_string
    privKey: $priv_key_string
```

## 3. To Run `snmpwalk` Commands:

#### 3a. Use the `<VALUE>` Set in `setup.sh` File:
```
$auth_key_string=<AUTH_VALUE>
$priv_key_string=<PRIV_VALUE>
$snmpv3_user=<USER_VALUE>
```

#### 3b. Or Set `Environment Variables`:
```
export auth_key_string=<VALUE>;
export priv_key_string=<VALUE>;
export snmpv3_user=<VALUE>
```
## 4. `snmpwalk` Commands:
```
netstat -nlpu|grep snmp -v 'will display snmp walk output'
snmpwalk -v 3 -a SHA -A $auth_key_string -x AES -X $priv_key_string -l authPriv -u $snmpv3_user localhost:161
sudo datadog-agent snmp walk localhost:161 1.3 -v 3 -a SHA -A $auth_key_string -x AES -X $priv_key_string -l authPriv -u $snmpv3_user  
```

##  Verbose `snmp` Metrics Should Be Collecting into Datadog
