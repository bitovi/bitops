resource "local_file" "private_key" {
  # This creates a keyfile pair that allows ansible to connect to the ec2 container
  sensitive_content = tls_private_key.key.private_key_pem
  filename          = format("%s/%s/%s", abspath(path.root), ".ssh", "heyemoji-blog-ssh-key.pem")
  file_permission   = "0600"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl", {
    ip          = aws_instance.server.public_ip,
    ssh_keyfile = local_file.private_key.filename
  })
  filename = format("%s/%s", abspath(path.root), "inventory.yaml")
}