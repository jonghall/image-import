data "template_file" "apikey_json" {
    template = file("${path.module}/apikey.tpl")
    vars = {
      apikey = var.apikey
    }
}

data "local_file" "service" {
  filename = "${path.module}/image-process.service"
}

data "template_file" "cloud-config" {
  template = file("${path.module}/cloud-init.tpl")
  vars = {
    githubtoken = var.githubtoken
    hmackey = var.hmackey
    hmacsecret = var.hmacsecret
    redisinstance = var.redisinstance
    redisuser = var.redisuser
    redispw = var.redispw
    cosendpoint = var.cosendpoint
    snapshot_region = var.snapshot_region
    recovery_region = var.recovery_region
    cosbucket = var.cosbucket
  }
}

data "template_cloudinit_config" "cloud-init" {
  gzip            = false
  base64_encode   = false

  part {
    filename      = "init.cfg"
    content_type  = "text/cloud-config"
    content       = data.template_file.cloud-config.rendered
  }

  part {
    filename      = "apikey.json"
    content_type  = "text/x-shellscript"
    content       = data.template_file.apikey_json.rendered
  }

  part {
    filename      = "image-process.service"
    content_type  = "text/x-shellscript"
    content       = data.local_file.service.content
  }

}
