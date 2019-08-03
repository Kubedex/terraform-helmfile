#!/bin/bash
sed -i 's/localhost:6443/k3s-server:6443/' /kubeconfig.yaml
helmsman --apply --debug --kubeconfig /kubeconfig.yaml -f /helmsman-deployments.yaml --no-fancy --suppress-diff-secrets --force-upgrades 2>&1
sleep 10
