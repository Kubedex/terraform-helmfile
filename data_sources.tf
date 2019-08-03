data "template_file" "entrypoint" {
  template = "${file("${path.module}/entrypoint.sh")}"
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/kubeconfig.yaml")}"
}

data "template_file" "helmfile" {
  template = "${file("${path.module}/helmfile.yaml")}"
}
