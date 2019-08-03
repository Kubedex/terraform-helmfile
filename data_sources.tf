data "template_file" "entrypoint" {
  template = "${file("${path.module}/entrypoint.sh")}"
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/kubeconfig.yaml")}"
}

data "template_file" "helmsman-deployments" {
  template = "${file("${path.module}/helmsman-deployments.yaml")}"
}
