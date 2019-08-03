# terraform-helmfile

An example that shows how to use Terraform for installing Helm Charts on a Kubernetes cluster using Helmfile.

[![asciicast](https://asciinema.org/a/7PH3P0wHjyzFlq9KNHLNFViiK.svg)](https://asciinema.org/a/7PH3P0wHjyzFlq9KNHLNFViiK)

There are a couple of reasons why you would want to deploy using Terraform:

* Provision complete Kubernetes clusters from scratch using Terraform
* Passing variables to charts dynamically that Terraform manages

The example uses the `docker_container` Terraform resource to spin up a local ephemeral container that runs Helmfile.

We render a kubeconfig, entrypoint and helmfile.yaml into this container and execute `helmfile apply`.

The demo executes against a local K3s Kubernetes cluster. To use this on remote clusters you will need to render the appropriate kubeconfig.yaml into the container.

We use a local-exec to run docker logs against the helmfile docker container and detect when it finishes and what the exit code was. This informs Terraform of whether the deployment was successful or not.

No Terraform state is used to determine is a Helm Chart needs to be updated. This mechanism for doing chart deployments is effectively stateless and idempotent. Inside the container we're using the helm-tiller plugin so there is no server side tiller component either.

# Demo

Start K3s so we can execute our demo Terraform code against it.

```
docker-compose up -d
```

Verify that K3s comes up and you have a running core-dns pod.

```
export KUBECONFIG=./kubeconfig.yaml
kubectl get pods --all-namespaces 
```

You should see a coredns pod running after a few seconds.

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                      READY   STATUS    RESTARTS   AGE
kube-system   coredns-b7464766c-xlmjn   1/1     Running   0          16s
```

Initialise the Terraform plugins

```
terraform init
```

Run helmfile to install the example kubernetes dashboard chart.

*Warning:* The settings for this chart are dangerously insecure. This demo installs into a K3s on localhost which is the only place you should ever think about installing an unsecured dashboard.

```
terraform apply
```

Check that everything worked.

```
kubectl get pods --all-namespaces
```

You can also verify that the dashboard chart that was installed by opening it in a browser.

```
export POD_NAME=$(kubectl get pods -n dashboard -l "app=kubernetes-dashboard,release=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
kubectl -n dashboard port-forward $POD_NAME 9090:9090
```

Then browse to `https://localhost:9090` and click the skip button to login.

# Troubleshooting

K3s creates a volume named `k3s-server` so data is persisted between container restarts. To wipe your local K3s you'll need to run.

```
docker-compose down
docker volume rm terraform-charts_k3s-server
```
