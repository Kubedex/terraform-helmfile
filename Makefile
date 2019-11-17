SHELL := /bin/bash
export KUBECONFIG := ./kubeconfig.yaml

.PHONY: help
help:
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

_up:
	@docker-compose up -d &>/dev/null || true 
	
_down:
	docker-compose down && docker volume rm -f terraform-helmfile_k3s-server

## Initialize terraform remote state
init:
	[ -f .terraform/terraform.tfstate ] || terraform $@

## Pass arguments through to terraform which require remote state
apply console graph plan output providers show: init _up
	@terraform $@

## Pass arguments through to terraform which do not require remote state
get fmt version:
	@terraform $@

validate:
	@terraform $@ -check-variables=false . && echo "[OK] terraform validated"

clean: _down destroy ## Clean up this project
	rm -rf .terraform *.tfstate* 

destroy: init
	terraform destroy -auto-approve || true

run: _up ## Run this setup
	@echo "Running"

k3s-cluster-info: _up ## K3s cluster info
	kubectl cluster-info

k3s-get-pods: _up ## Get k3s pods
	kubectl get pods --all-namespaces

k3s-dashboard: _up ## K3s Dashboard portforward on localhost 
	export POD_NAME=$$(kubectl get pods -n dashboard -l "app=kubernetes-dashboard,release=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}") \
		&& echo http://127.0.0.1:9090/ \
		&& kubectl -n dashboard port-forward $$POD_NAME 9090:9090

terraform-helmfile-logs:
	docker logs terraform-helmfile
