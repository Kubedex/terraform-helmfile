# terraform-charts

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
