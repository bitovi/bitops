In this section we will learn how we can create a custom BitOps image with plugins and additional utilities.


### Create a custom bitops repo
First thing is first, if you haven't already create a repo for your custom bitops image

<hr/>


### Modify the *bitops.config.yaml*
Using your preferred editor, create a file in the root level of the project and call it; `bitops.config.yaml`

This file is used to configure the BitOps image.

[Example bitops.config.yaml](https://github.com/bitovi/bitops/tree/plugins/prebuilt-config)

<hr/>

### bitops.config.yaml

<br/>

#### BitOps "official" image
Below is an example of how the "official latest" image of BitOps is configured. 

As you can see there are two sections we need to be aware of; Plugins and Deployments. 

<br/>

#### plugins
Defines a plugin and the source for that plugin. 

<br/>

#### Deployment
Defines alias', the sequence of executions for those alias' and the alias' related plugin.


### official image
```
  plugins:    
    aws:
      source: https://github.com/bitops-plugins/aws
    terraform:
      source: https://github.com/bitops-plugins/terraform
    cloudformation:
      source: https://github.com/bitops-plugins/cloudformation
    helm:
      source: https://github.com/bitops-plugins/helm
    kubectl:
      source: https://github.com/bitops-plugins/kubectl
    ansible:
      source: https://github.com/bitops-plugins/ansible
  deployments:
    cloudformation:
      plugin: cloudformation
    terraform:
      plugin: terraform
    helm:
      plugin: helm
    ansible:
      plugin: ansible
```

<hr/>

### Custom image example
In the example below we define 2 plugins that BitOps will install, `plugin-name-1` and `plugin-name-2`. 

In the deployment section we specify 3 alias' that we will act on in our ops_repo. We also specify which plugin we'd like to make that action. 

```
plugins:
    plugin-name-1:
        source: url-to-plugin-1
    plugin-name-2:
        source: url-to-plugin-2
deployments:
    alias-name-1:
        plugin: plugin-name-1
    alias-name-2:
        plugin: plugin-name-2
    alias-name-3:
        plugin: plugin-name-1
```

So continuing with our example, the ops_repo would look like; 
```
OPS_REPO/
    ENV/
        alias-name-1/
            ... 
        alias-name-2/
            ...
        alias-name-3/
            ...
```

```
OPS_REPO/
    ENV/
        alias-name-1/ # <-- plugin-name-1 would be actioned on this folder
            ... 
        alias-name-2/ # <-- plugin-name-2 would be actioned on this folder
            ...
        alias-name-3/ # <-- plugin-name-1 would be actioned on this folder
            ...
```



## Build and run the image
The final steps are to build and run the image. You can find example commands to accomplish this in the [local development](development-local.md) section