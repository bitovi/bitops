resource "null_resource" "default_resource" {
  provisioner "local-exec" {
    command = "echo I am a default terraform resource"
  }
}