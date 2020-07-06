## Sample tool bitops schema
`bitops/scripts/example-tool/bitops.schema.yaml`
```
foo-bool:
  type: bool
  parameter: foobool
foo-exists:
  type: exists
  parameter: fooexists
some-string:
  type: string
  parameter: fooexists
terminal-if-true:
  type: bool
  terminal: true
  parameter: terminaliftrue
nested:
  type: object
  properties:
    foo:
      type: bool
      parameter: nested-foo
```

## Sample bitops config
`operations/<env>/example-tool/bitops.config.yaml`
```
foo-bool: true
# foo-bool: false
foo-exists: "1"
some-string: hello world
terminal-if-true: true
nested:
  foo: true
```



## Bolean
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="opsmfi-test" \
  --entrypoint="/opt/bitops/scripts/bitops-config/get-convert.sh" \
  -v $(pwd):/opt/bitops_deployment \
  -v /path/to/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops_deployment/opsmfi-test/ansible/bitops.config.yaml" \
  "foo-bool" \
  "boolean" \
  "foobool"
```


# exists
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="opsmfi-test" \
  --entrypoint="/opt/bitops/scripts/bitops-config/get-convert.sh" \
  -v $(pwd):/opt/bitops_deployment \
  -v /path/to/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops_deployment/opsmfi-test/ansible/bitops.config.yaml" \
  "foo-exists" \
  "exists" \
  "fooexists"
```

# string
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="opsmfi-test" \
  --entrypoint="/opt/bitops/scripts/bitops-config/get-convert.sh" \
  -v $(pwd):/opt/bitops_deployment \
  -v /path/to/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops_deployment/opsmfi-test/ansible/bitops.config.yaml" \
  "some-string" \
  "string" \
  "somestring"
```


# terminal-if-true
## Bolean
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="opsmfi-test" \
  --entrypoint="/opt/bitops/scripts/bitops-config/get-convert.sh" \
  -v $(pwd):/opt/bitops_deployment \
  -v /path/to/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops_deployment/opsmfi-test/ansible/bitops.config.yaml" \
  "terminal-if-true" \
  "boolean" \
  "terminaliftrue" \
  "true"
```

# TODO
nested:
  foo: true