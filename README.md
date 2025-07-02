# Apstra VRF and VXLAN provisioning setup

## Directory structure

This project contains the following structure:

```
apstra-provisioning/
├── apstra_provision.yml          # Main playbook
├── inventory/
│   └── hosts.ini                 # Inventory file
├── vars/
│   └── apstra_vars.yml          # Variables file
└── README.md                    # This file
```

## Prerequisites

1. **Ansible installation**: Ensure Ansible is installed on your control machine
   ```bash
   pip install ansible
   ```

2. **Network access**: Your Ansible control machine must have HTTPS access to the Apstra server

3. **Apstra credentials**: Valid username and password for Apstra API access

4. **Blueprint ID**: The ID of the blueprint where you want to create the VRF and VXLANs

## Configuration steps

### 1. Update variables file

Edit `vars/apstra_vars.yml` with your specific environment details:

- **apstra_address**: Your Apstra server hostname or IP address
- **apstra_username/password**: Valid Apstra credentials  
- **blueprint_id**: Target blueprint ID (find this in the Apstra UI)
- **routing_zone_name**: Name for your VRF
- **virtual_networks**: List of VXLAN networks to create

### 2. Optional resource pools

If you have specific IP or VNI pools to assign, uncomment and set:
- **ip_pool_id**: IP pool for leaf loopback addresses
- **vni_pool_id**: VNI pool for L3 VNIs

### 3. Customise VXLAN networks

Modify the `virtual_networks` list to match your requirements. Each network supports:
- **virtual_network_name**: Display name
- **vn_id**: VLAN ID (optional)
- **ipv4_enabled**: Enable IPv4 gateway
- **ipv4_subnet**: Subnet for the network
- **virtual_gateway_ipv4**: Gateway IP address
- **create_ct_policy**: Create connectivity template policies

## Running the playbook

### Basic execution

```bash
cd apstra-provisioning
ansible-playbook -i inventory/hosts.ini apstra_provision.yml
```

### With verbose output

```bash
ansible-playbook -i inventory/hosts.ini apstra_provision.yml -v
```

### Override variables

You can override variables from the command line:

```bash
ansible-playbook -i inventory/hosts.ini apstra_provision.yml \
  -e "routing_zone_name=CUSTOM_VRF" \
  -e "apstra_address=different-apstra.company.com"
```

## What the playbook does

1. **Authenticates** to the Apstra REST API using provided credentials
2. **Creates a VRF** (security zone) with the specified name
3. **Assigns resource pools** if configured (IP pools and VNI pools)
4. **Discovers leaf switches** in the blueprint for VXLAN binding
5. **Creates VXLAN networks** according to the virtual_networks configuration
6. **Provides summary** of created resources and uncommitted changes link

## Post-execution steps

After running the playbook successfully:

1. **Review changes** in the Apstra UI at the uncommitted changes link provided
2. **Validate configuration** meets your requirements
3. **Commit changes** through the Apstra UI to deploy to devices

## Troubleshooting

### Common issues

- **Authentication failures**: Verify credentials and network connectivity
- **Blueprint not found**: Check blueprint_id is correct and accessible
- **Resource conflicts**: Ensure VLAN IDs and IP subnets don't conflict with existing configuration
- **SSL errors**: Set `validate_certs: false` for self-signed certificates

### Debugging

Add `-vvv` flag for maximum verbosity:
```bash
ansible-playbook -i inventory/hosts.ini apstra_provision.yml -vvv
```

### Credential security

For production use, consider using Ansible Vault to encrypt sensitive variables:

```bash
ansible-vault create vars/secrets.yml
ansible-playbook -i inventory/hosts.ini apstra_provision.yml --ask-vault-pass
```
