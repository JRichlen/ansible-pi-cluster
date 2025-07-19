# Install all dependencies using Homebrew
install:
	brew install ansible nmap yamllint ansible-lint
# Makefile for common Ansible Pi Cluster commands

.PHONY: scan scan-detailed subnet nmap ping-sweep ansible-ping ansible-all ansible-update help install

# Network Discovery Commands
scan:
	./scripts/network-discovery scan

scan-detailed:
	@echo "Running detailed scan with MAC addresses (requires sudo)..."
	sudo ./scripts/network-discovery scan

subnet:
	./scripts/network-discovery subnet

nmap:
	@echo "Usage: make nmap SUBNET=192.168.1.0/24"
	@if [ -z "$(SUBNET)" ]; then echo "Error: Please specify SUBNET"; exit 1; fi
	sudo ./scripts/network-discovery nmap $(SUBNET)

ping-sweep:
	@echo "Usage: make ping-sweep SUBNET=192.168.1.0/24"
	@if [ -z "$(SUBNET)" ]; then echo "Error: Please specify SUBNET"; exit 1; fi
	./scripts/network-discovery ping $(SUBNET)

help:
	./scripts/network-discovery help

# Ansible Commands
ansible-ping:
	ansible -i inventories/hosts.ini all -m ping -u ubuntu

ansible-all:
	ansible-playbook -i inventories/hosts.ini playbooks/update.yml -u ubuntu

ansible-update:
	ansible-playbook -i inventories/hosts.ini playbooks/update.yml -u ubuntu
