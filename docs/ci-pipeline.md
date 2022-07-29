The CI pipeline that creates new BitOps images is made up of 3 distinct actions; 
    
1. A bitops base image is created which contains python3, jq, git as well as a few other utilities. 

2. The final step of the base bitops image build performs a minor bump to the [bitops-tag](../prebuilt-config/bitops-tag) file

3. A CI pipeline is watching the `bitops-tag` file, if there is an update it triggers a github action that creates a new set of prebuilt images.



The logic is that a base image recreation is triggered if any change happens to the bitops source code which subsequently triggers the recreation of all prebuilt images. 

This effectively softlinks the CI pipelines as though they are able to run independent of the other, they are intended to be used in succession. 