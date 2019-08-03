#!/bin/bash
sed -i 's/localhost:6443/k3s-server:6443/' /kubeconfig.yaml
export KUBECONFIG=/kubeconfig.yaml
helm init --client-only
helm repo update
helm plugin install https://github.com/rimusz/helm-tiller
helmfile apply 2>&1
