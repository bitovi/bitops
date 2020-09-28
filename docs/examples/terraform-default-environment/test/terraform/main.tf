resource "null_resource" "test_resource" {
  provisioner "local-exec" {
    command = "echo I am a test terraform resource"
  }
}