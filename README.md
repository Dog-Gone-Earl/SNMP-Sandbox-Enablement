# sandbox/vagrant/agent7/snmp_v1

## What this VM does

- Test snmp (v1) functionaity with Agent

## VM type: 
- Linux Ubuntu

## Special Instructions

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
