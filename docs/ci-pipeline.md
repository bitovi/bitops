The CI pipeline that creates new BitOps images is made up of 3 distinct actions; 
    
1. A bitops base image is created which contains python3, jq, git as well as a few other utilities. 

2. The final step of the base bitops image build performs a minor bump to the [bitops-tag](../prebuilt-config/bitops-tag) file

3. A CI pipeline is watching the `bitops-tag` file, if there is an update it triggers a github action that creates a new set of prebuilt images.



The logic is that a base image recreation is triggered if any change happens to the bitops source code which subsequently triggers the recreation of all prebuilt images. 

This effectively softlinks the CI pipelines as though they are able to run independent of the other, they are intended to be used in succession.


# Break down of CI triggers
## Base
### Push
```
    # ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~- #
    #                   PUSH                   #
    # ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~- #  
    - name: Publish Docker Image (Push)
      env:
        REGISTRY_URL: "bitovi/bitops"
        DEFAULT_BRANCH: "plugins"
        DOCKER_USER: ${{ secrets.DOCKER_USER}}
        DOCKER_PASS: ${{ secrets.DOCKER_PASS}}
        IMAGE_TAG: ${{ env.BASE_TAG}}
      run: |
        echo "running scripts/ci/publish.sh"
        ./scripts/ci/publish.sh
      if: github.event_name == 'push'
```

The push trigger will perform a basic rebuild of the base image but it will not bump the bitops-version, therefor this trigger does not trigger the subsequent prebuilt image CI. 

### **Workflow Disbatch**
```
    # ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~- #
    #           Workflow dispatch              #
    # ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~- # 
    - name: Publish Docker Image (Workflow dispatch)
      env:
        REGISTRY_URL: "bitovi/bitops"
        DEFAULT_BRANCH: "plugins"
        DOCKER_USER: ${{ secrets.DOCKER_USER}}
        DOCKER_PASS: ${{ secrets.DOCKER_PASS}}
        IMAGE_TAG: ${{ github.event.inputs.bitops_base_tag}}
      run: |
        echo "running scripts/ci/publish.sh"
        ./scripts/ci/publish.sh
        echo "IMAGE_TAG=${{ github.event.inputs.bitops_base_tag}}" >> $GITHUB_ENV
        echo "IMAGE_BUMP=${{ github.event.release.bump_base_tag }}" >> $GITHUB_ENV
      if: github.event_name == 'workflow_dispatch'
```

The workflow disbatch trigger will create a custom bitops image name, and provides the boolean option to bump the [prebuilt-config/bitops-tag.yaml](../prebuilt-config/bitops-tag.yaml)`:tags.bitops-tag`


### **Release**

```
    # ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~- #
    #                Release                   #
    # ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~- #
    - name: Publish Docker Image (Release)
      env:
        REGISTRY_URL: "bitovi/bitops"
        DEFAULT_BRANCH: "plugins"
        DOCKER_USER: ${{ secrets.DOCKER_USER}}
        DOCKER_PASS: ${{ secrets.DOCKER_PASS}}
        IMAGE_TAG: ${{ github.event.release.tag_name }}-base
      run: |
        echo "running scripts/ci/publish.sh"
        ./scripts/ci/publish.sh
        echo "IMAGE_TAG=${{ github.event.release.tag_name }}-base" >> $GITHUB_ENV
        echo "IMAGE_BUMP=true" >> $GITHUB_ENV
      if: github.event_name == 'release'
```

Creates a new base image based on the tag of the release and bumps the [prebuilt-config/bitops-tag.yaml](../prebuilt-config/bitops-tag.yaml)`:tags.bitops-tag`

## Prebuilt
### **Push**
The CI pipeline watches the [prebuilt-config/bitops-tag.yaml](../prebuilt-config/bitops-tag.yaml) file and if an update occurs to the `tags.bitops_base` tag then it rebuilds using the new version.

### **Workflow Disbatch**
The user who triggers the workflow disbatch must specify a version tag for the plugins image name. For example if `2.0.0` was entered as the `image_tag`