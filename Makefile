# Install all dependencies using Homebrew
install:
	brew install ansible nmap yamllint ansible-lint

# Makefile for common Ansible Pi Cluster commands

.PHONY: scan scan-detailed subnet nmap ping-sweep ansible-test ansible-ping ansible-all ansible-update help install test-syntax test-lint test-yaml test-all

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
ansible-test:
	ansible-playbook -i inventories/hosts.ini playbooks/test-connection.yml --ask-pass

ansible-ping:
	ansible -i inventories/hosts.ini ubuntu -m ping --ask-pass

ansible-update:
	ansible-playbook -i inventories/hosts.ini playbooks/update-packages.yml --ask-pass --ask-become-pass

ansible-all:
	ansible-playbook -i inventories/hosts.ini playbooks/update-packages.yml --ask-pass --ask-become-pass

# Testing Commands
test-syntax:
	@echo "Running syntax validation..."
	ansible-playbook --syntax-check playbooks/*.yml

test-lint:
	@echo "Running ansible-lint..."
	ansible-lint playbooks/ roles/

test-yaml:
	@echo "Running yamllint..."
	yamllint .

test-all:
	@echo "Running all tests..."
	make test-syntax
	make test-yaml
	make test-lint
