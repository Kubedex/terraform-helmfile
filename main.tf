resource "null_resource" "dockerrm" {
  provisioner "local-exec" {
    command = "docker kill $(docker inspect --format={{.Id}} terraform-helmsman) && docker rm $(docker inspect --format={{.Id}} terraform-helmsman) || true"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "docker_container" "helmsman" {
  name       = "terraform-helmsman"
  image      = "praqma/helmsman:latest"
  links      = ["k3s-server"]
  entrypoint = ["/entrypoint.sh"]
  rm         = true
  start      = true

  upload = {
    content    = "${data.template_file.entrypoint.rendered}"
    file       = "/entrypoint.sh"
    executable = true
  }

  upload = {
    content = "${data.template_file.kubeconfig.rendered}"
    file    = "/kubeconfig.yaml"
  }

  upload = {
    content = "${data.template_file.helmsman-deployments.rendered}"
    file    = "/helmsman-deployments.yaml"
  }

  depends_on = [
    "null_resource.dockerrm",
  ]
}

resource "null_resource" "dockerlogs" {
  provisioner "local-exec" {
    command = "sleep 5 && ./logtail.py $(docker inspect --format={{.Id}} terraform-helmsman)"
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    "docker_container.helmsman",
  ]
}
