> ⚠️ Note from the developers: We are currently in the process of moving our documentation and so the below documentation is only partially correct. For more information on this tool please checkout our [plugin documentation](https://github.com/bitops-plugins/helm).

# Helm

## Example bitops.config.yaml
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
    uninstall-charts: "chart1,chart2"
    kubeconfig:
      path: ./path/to/kubeconfig
      fetch:
        enabled: true
        cluster-name: my-cluster
  plugins:
```

## CLI Configuration

| Property  | Environment Variable | Description                                                  | Default | Required |
| --------- | -------------------- | ------------------------------------------------------------ | ------- | -------- |
| namespace | NAMESPACE            | Namespace scope for this project                             | `null`  | Yes      |
| timeout   | TIMEOUT              | Time to wait for any individual Kubernetes operation (like Jobs for hooks) | `500s`  |          |
| set       | HELM_SET_FLAG        | List of "key=value" strings to pass in to `helm` via `--set` | `{}`    |          |
| debug     | HELM_DEBUG           | Enable verbose helm output                                   | `null`  |          |
| atomic    |                      | If set, the installation process deletes the installation on failure | `null`  |          |
| force     |                      | Sets helm's `--force` flag                                   | `null`  |          |
| dry-run   |                      | Simulate an install                                          | `null`  |          |

-------------------
## Options Configuration

| Property                      | Environment Variable | Description                                                  | Default | Required |
| ----------------------------- | -------------------- | ------------------------------------------------------------ | ------- | -------- |
| skip-deploy                   | SKIP_DEPLOY          | Will skip helm execution                                     | `null`  |          |
| release-name                  | HELM_RELEASE_NAME    | Sets helm release name                                       | `null`  |          |
| uninstall                     | HELM_UNINSTALL       | If true, this chart will be uninstalled instead of deployed/upgraded. If the environment variable `HELM_UNINSTALL` is passed into the container, all BitOps-managed charts for a given environment will be uninstalled. | `null`  |          |
| kubeconfig                    |                      | configure cluster access. Has the following child-properties. Should provide one of `path` or `fetch`. Defaults to `fetch` | `fetch` |          |
| kubeconfig.path               | KUBE_CONFIG_PATH     | Relative file path to .kubeconfig file                       | `null`  |          |
| kubeconfig.fetch              |                      | Fetch kubeconfig using cloud provider auth                   |         |          |
| kubeconfig.fetch.enabled      | FETCH_KUBECONFIG     | enables/disables kubeconfig.fetch                            | `true`  |          |
| kubeconfig.fetch.cluster-name | CLUSTER_NAME         | Cloud kubernetes cluster name for kubeconfig fetching.       | `null`  |          |

-------------------
## Plugin Configuration
This section of `bitops.config.yaml` is unique to helm and allows the customization of helm plugins

### S3 Plugin

Configure [helm s3 plugin](https://github.com/hypnoglow/helm-s3) with the following properties

| Property  | Environment Variable  | Description                     | Default | Required |
| --------- | --------------------- | ------------------------------- | ------- | -------- |
| s3.region | HELM_PLUGIN_S3_REGION | AWS region containing s3 bucket |         |          |
| s3.bucket | HELM_CHARTS_S3_BUCKET | AWS s3 bucket name              |         |          |



-------------------
## Additional Environment Variable Configuration
Although not captured in `bitops.config.yaml`, the following environment variables can be set to further customize behavior.

| Environmental Variable | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| SKIP_DEPLOY_HELM       | Will skip all helm executions. This supersedes all other configurations. |
| HELM_UNINSTALL_CHARTS  | Comma-separated string. If any of the charts to be deployed match one of the chart names listed here, it will be uninstalled with `helm uninstall $HELM_RELEASE_NAME` instead of deployed/upgraded. |



