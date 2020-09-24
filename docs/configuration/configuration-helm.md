# Helm

## Example bitops.config.yml
```
helm:
  cli:
    namespace: bitops
    timeout: 60s
    set:
      key1: value1
    debug: false
    atomic: true
    force: true
    dry-run: true
  options:
    skip-deploy: false
    release-name: bitops-release
    kubeconfig:
      path: ./path/to/kubeconfig
      fetch:
        enabled: true
        cluster-name: my-cluster
  plugins:
```

## CLI Configuration

-------------------
### namespace
* **Bitops Property:** `namespace`
* **Environment Variable:** `NAMESPACE`
* **default:** `""`
* **required:** yes

namespace scope for this request

-------------------
### timeout
* **Bitops Property:** `timeout`
* **Environment Variable:** `TIMEOUT`
* **default:** `"500s"`

time to wait for any individual Kubernetes operation (like Jobs for hooks) 

-------------------
### set
* **Bitops Property:** `set`
* **Environment Variable:** `HELM_SET_FLAG`
* **default:** `{}`

key/value pairs to pass in to `helm` via `--set`

-------------------
### debug
* **Bitops Property:** `debug`
* **Environment Variable:** `HELM_DEBUG`
* **default:** `""`

enable verbose helm output

-------------------
### atomic
* **Bitops Property:** `atomic`
* **Environment Variable:** `TODO`
* **default:** `""`

if set, the installation process deletes the installation on failure

-------------------
### force
* **Bitops Property:** `force`
* **Environment Variable:** `TODO`
* **default:** `""`

sets helm's `--force` flag

-------------------
### dry-run
* **Bitops Property:** `dry-run`
* **Environment Variable:** `TODO`
* **default:** `""`

simulate an install

-------------------
## Options Configuration

-------------------
### skip-deploy
* **Bitops Property:** `skip-deploy`
* **Environment Variable:** `SKIP_DEPLOY`
* **default:** `""`

will skip helm execution

-------------------
### release-name
* **Bitops Property:** `release-name`
* **Environment Variable:** `HELM_RELEASE_NAME`
* **default:** `""`

sets helm release name

-------------------
### kubeconfig
* **Bitops Property:** `kubeconfig`

configure cluster access. Has the following child-properties. Should provide one of `path` or `fetch`. Defaults to `fetch`

### path
* **Bitops Property:** `kubeconfig.path`
* **Environment Variable:** `KUBE_CONFIG_PATH`
* **default:** `""`

relative file path to .kubeconfig file

#### fetch
* **Bitops Property:** `kubeconfig.fetch`

fetch kubeconfig from cluster? TODO @mick

##### enabled
* **Bitops Property:** `kubeconfig.fetch.enabled`
* **Environment Variable:** `FETCH_KUBECONFIG`
* **default:** `true`

enables/disables kubeconfig.fetch

##### cluster-name
* **Bitops Property:** `kubeconfig.fetch.cluster-name`
* **Environment Variable:** `CLUSTER_NAME`
* **default:** `""`

cluster to operation against? TODO @mick

-------------------
## Plugin Configuration
This section of `bitops.config.yml` is unique to helm and allows the customization of helm plugins

-------------------
### S3 Plugin
* **Bitops Property:** `s3`

Configure https://github.com/hypnoglow/helm-s3 with the following properties

-------------------
#### region
* **Bitops Property:** `s3.region`
* **Environment Variable:** `HELM_PLUGIN_S3_REGION`

AWS region

-------------------
#### bucket
* **Bitops Property:** `s3.bucket`
* **Environment Variable:** `HELM_CHARTS_S3_BUCKET`

AWS s3 bucket

-------------------
## Additional Environment Variable Configuration
Although not captured in `bitops.config.yml`, the following environment variables can be set to further customize behaviour

-------------------
### SKIP_DEPLOY_HELM
Will skill all helm executions. This superseeds all other configuration