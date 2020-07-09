## convert-schema

Given a `bitops/scripts/<tool>/bitops.schema.yaml` in bitops and a `bitops.config.yaml` from an operations repo, output cli arguments.

### Sample tool bitops schema
`bitops/scripts/example-tool/bitops.schema.yaml`
```
foo-bool:
  type: boolean
  parameter: foobool
foo-exists:
  type: exists
  parameter: fooexists
bar:
  type: string
  parameter: bar
some-string:
  type: string
  parameter: somestring
terminal-if-true:
  type: boolean
  terminal: true
  parameter: terminaliftrue
nested:
  type: object
  properties:
    foo:
      type: boolean
      parameter: nested-foo
    bar:
      type: object
      properties:
        foo:
          type: boolean
          parameter: super-nested-foo
```

### Sample bitops config
`operations/<env>/example-tool/bitops.config.yaml`
```
foo-bool: true
foo-exists: "1"
bar: "bar hello world"
some-string: hello-world
terminal-if-true: true
nested:
  foo: true
```

### Sample convert schema
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="$ENVIRONMENT" \
  --entrypoint="/opt/bitops/scripts/bitops-config/convert-schema.sh" \
  -v /path/to/operations:/opt/bitops_deployment \
  -v /path/to/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops/scripts/example-tool/bitops.schema.yaml" \
  "/opt/bitops_deployment/${ENVIRONMENT}/example-tool/bitops.config.yaml" 

```

This will output the following:
```
--foobool --fooexists --bar='bar hello world' --somestring='hello-world'  --nested-foo 
```



## get-convert examples

### Bolean
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="opsmfi-test" \
  --entrypoint="/opt/bitops/scripts/bitops-config/get-convert.sh" \
  -v /path/to/operations:/opt/bitops_deployment \
  -v /path/to/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops_deployment/opsmfi-test/ansible/bitops.config.yaml" \
  "foo-bool" \
  "boolean" \
  "foobool"
```


### exists
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="opsmfi-test" \
  --entrypoint="/opt/bitops/scripts/bitops-config/get-convert.sh" \
  -v /path/to/operations:/opt/bitops_deployment \
  -v /path/to/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops_deployment/opsmfi-test/ansible/bitops.config.yaml" \
  "foo-exists" \
  "exists" \
  "fooexists"
```

### string
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="opsmfi-test" \
  --entrypoint="/opt/bitops/scripts/bitops-config/get-convert.sh" \
  -v /path/to/operations:/opt/bitops_deployment \
  -v /path/to/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops_deployment/opsmfi-test/ansible/bitops.config.yaml" \
  "some-string" \
  "string" \
  "somestring"
```


### Bolean (terminal-if-true)
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="opsmfi-test" \
  --entrypoint="/opt/bitops/scripts/bitops-config/get-convert.sh" \
  -v /path/to/operations:/opt/bitops_deployment \
  -v /path/to/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops_deployment/opsmfi-test/ansible/bitops.config.yaml" \
  "terminal-if-true" \
  "boolean" \
  "terminaliftrue" \
  "true"
```


### nested boolean
```
docker run --rm --name bitops-local \
  -e ENVIRONMENT="opsmfi-test" \
  --entrypoint="/opt/bitops/scripts/bitops-config/get-convert.sh" \
  -v $(pwd):/opt/bitops_deployment \
  -v /Users/mickmcgrath/Projects/Bitovi/bitops:/opt/bitops \
  bitops:latest \
  "/opt/bitops_deployment/opsmfi-test/ansible/bitops.config.yaml" \
  "nested.foo" \
  "boolean" \
  "nested-foo"
```