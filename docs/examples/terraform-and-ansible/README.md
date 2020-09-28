This example shows how terraform could be used to provision infrastructure and then passed on to ansible for configuration.

To run this example, open a terminal in this directory and run
```
docker run \
-e ENVIRONMENT="test" \
-e AWS_ACCESS_KEY_ID=skip \
-e AWS_SECRET_ACCESS_KEY=skip \
-e AWS_DEFAULT_REGION="us-east-1" \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:latest
```

In the logs you will see:

Creation of `hosts.yaml`
```
Terraform will perform the following actions:

  # local_file.ansible_inventory will be created
  + resource "local_file" "ansible_inventory" {
      + content              = <<~EOT
            my-servers:
              hosts:
                localhost  
              vars:
                ansible_connection: local
        EOT
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "/tmp/tmp.hxYnhz1NCU/test/terraform/hosts.yaml"
      + id                   = (known after apply)
    }

  # null_resource.test_resource will be created
  + resource "null_resource" "test_resource" {
      + id = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

A terraform post hook showing the contents of `hosts.yaml`
```
+ cat hosts.yaml
my-servers:
  hosts:
    localhost  
  vars:
    ansible_connection: local
```

The ansible playbook running using `hosts.yaml` as its input
```
ok: [localhost]

TASK [debug] *******************************************************************
ok: [localhost] => {
    "msg": "ansible debug"
}

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```