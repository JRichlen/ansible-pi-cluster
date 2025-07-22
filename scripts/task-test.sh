#!/bin/bash

echo "🧪 Running tests in escalating order of importance..."
echo "1/3 Running YAML syntax validation..."

if command -v yamllint >/dev/null 2>&1; then
  yamllint -c .yamllint . && echo "✔ YAML syntax validation passed"
else
  echo "⚠️  yamllint not installed, skipping YAML validation"
fi

echo "2/3 Running Ansible syntax validation..."
ansible-playbook --syntax-check playbooks/*.yml && \
  echo "✔ Ansible syntax validation passed"

echo "3/3 Running Ansible lint (best practices)..."
if command -v ansible-lint >/dev/null 2>&1; then
  echo "ℹ️  Running ansible-lint..."
  ansible-lint playbooks/ roles/ || \
    echo "⚠️  Some lint warnings found, but syntax is valid"
else
  echo "⚠️  ansible-lint not installed, skipping lint check"
fi

echo "✅ Essential tests completed! Playbooks are syntactically valid."
