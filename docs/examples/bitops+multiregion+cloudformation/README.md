# Multi region deployment

**Minimum required setup**
```
<env>/cloudformation/
    templates/
    region-1/
    region-2/
    bitops.config.yaml
```

*templates*
<br/>
Contains any common files that are shared between regions


*region-*
<br/>
Contains region specific code


*bitops.config.yaml*
<br/>
Look at `bitops/example-config-files/bitops.config.yaml` for an example. Contains regions and bucket name. 

