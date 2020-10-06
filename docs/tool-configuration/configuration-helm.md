# Helm

## Example bitops.config.yml
```
helm:
  cli:
    namespace: bitops
    timeout: 60s
    set:
     - "key1=value1"
     - "key2=value2"
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
* **BitOps Property:** `namespace`
* **Environment Variable:** `NAMESPACE`
* **default:** `""`
* **required:** yes

namespace scope for this request

-------------------
### timeout
* **BitOps Property:** `timeout`
* **Environment Variable:** `TIMEOUT`
* **default:** `"500s"`

time to wait for any individual Kubernetes operation (like Jobs for hooks) 

-------------------
### set
* **BitOps Property:** `set`
* **Environment Variable:** `HELM_SET_FLAG`
* **default:** `{}`

list of "key=value" strings to pass in to `helm` via `--set`

-------------------
### debug
* **BitOps Property:** `debug`
* **Environment Variable:** `HELM_DEBUG`
* **default:** `""`

enable verbose helm output

-------------------
### atomic
* **BitOps Property:** `atomic`
* **Environment Variable:** `TODO`
* **default:** `""`

if set, the installation process deletes the installation on failure

-------------------
### force
* **BitOps Property:** `force`
* **Environment Variable:** `TODO`
* **default:** `""`

sets helm's `--force` flag

-------------------
### dry-run
* **BitOps Property:** `dry-run`
* **Environment Variable:** `TODO`
* **default:** `""`

simulate an install

-------------------
## Options Configuration

-------------------
### skip-deploy
* **BitOps Property:** `skip-deploy`
* **Environment Variable:** `SKIP_DEPLOY`
* **default:** `""`

will skip helm execution

-------------------
### release-name
* **BitOps Property:** `release-name`
* **Environment Variable:** `HELM_RELEASE_NAME`
* **default:** `""`

sets helm release name

-------------------
### kubeconfig
* **BitOps Property:** `kubeconfig`

configure cluster access. Has the following child-properties. Should provide one of `path` or `fetch`. Defaults to `fetch`

### path
* **BitOps Property:** `kubeconfig.path`
* **Environment Variable:** `KUBE_CONFIG_PATH`
* **default:** `""`

relative file path to .kubeconfig file

#### fetch
* **BitOps Property:** `kubeconfig.fetch`

fetch kubeconfig using cloud provider auth

##### enabled
* **BitOps Property:** `kubeconfig.fetch.enabled`
* **Environment Variable:** `FETCH_KUBECONFIG`
* **default:** `true`

enables/disables kubeconfig.fetch

##### cluster-name
* **BitOps Property:** `kubeconfig.fetch.cluster-name`
* **Environment Variable:** `CLUSTER_NAME`
* **default:** `""`

cloud kubernetes cluster name for kubeconfig fetching.

-------------------
## Plugin Configuration
This section of `bitops.config.yml` is unique to helm and allows the customization of helm plugins

-------------------
### S3 Plugin
* **BitOps Property:** `s3`

Configure [helm s3 plugin](https://github.com/hypnoglow/helm-s3) with the following properties

-------------------
#### region
* **BitOps Property:** `s3.region`
* **Environment Variable:** `HELM_PLUGIN_S3_REGION`

AWS region containing s3 bucket

-------------------
#### bucket
* **BitOps Property:** `s3.bucket`
* **Environment Variable:** `HELM_CHARTS_S3_BUCKET`

AWS s3 bucket name

-------------------
## Additional Environment Variable Configuration
Although not captured in `bitops.config.yml`, the following environment variables can be set to further customize behaviour

-------------------
### SKIP_DEPLOY_HELM
Will skill all helm executions. This superseeds all other configuration