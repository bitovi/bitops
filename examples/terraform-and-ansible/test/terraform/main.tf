resource "null_resource" "test_resource" {
  provisioner "local-exec" {
    command = "echo I am a test terraform resource"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("hosts.tmpl", {
    ip = "localhost"
  })
  filename = format("%s/%s", abspath(path.root), "hosts.yaml")
}