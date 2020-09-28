resource "null_resource" "production_resource" {
  provisioner "local-exec" {
    command = "echo I am a production terraform resource"
  }
}