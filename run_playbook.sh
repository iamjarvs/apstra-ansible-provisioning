#!/bin/bash
# Simple script to run the Apstra provisioning playbook

echo "Running Apstra VRF and VXLAN provisioning playbook..."
echo "Make sure you've updated vars/apstra_vars.yml with your environment details!"
echo ""

ansible-playbook -i inventory/hosts.ini apstra_provision.yml -v
