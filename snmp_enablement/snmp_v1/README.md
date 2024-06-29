## VM type: 
- Linux Ubuntu

### 1. Set a `community string` value in the `setup.sh` file:
```
comm_string=<VALUE>
```

### 2. Start the sandbox:
```
vagrant up;
vagrant ssh;
```

#### You should be able to run `host snmpwalk` comnand to poll OID's:
```
snmpwalk -v 1 -c <COMMUNITY_STRING> -ObentU localhost:161 1.3
```
### 3. Install Agent:

#### You should now be able to run `agent snmpwalk` comnand to poll OID's:

#### Example:

```
sudo datadog-agent snmp walk localhost:161 1.3 -C <COMMUNITY_STRING>
```

### 4. Create `snmp` integration configuration `yaml` named `conf.yaml` located at `/etc/datadog-agent/conf.d/snmp.d/`:

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

### 5. Restart Agent
```
sudo service datadog-agent restart
```

## SNMP Metrics should begin populating in Network Devices UI
