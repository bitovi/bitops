# Development Guide

We are excited for any contributions from the community, we welcome any feedback whether its:

* Submitting a bug report
* An idea for feature development
* Expanding functionality of an existing feature
* Submitting an example guide or blog using Bitops
* Security or other concerns

When contributing to Bitops, please consider some of the following basic guidelines before submitting.

## Requirements

To submit changes we require that all contributions first have a GitHub issue created where submissions can be discussed and visible to all contributors and maintainers.

We require that you have signed the [Developer Certificate of Origin (DCO)](DCO.md) stating that the code being submitted is owned wholly by you.

Contributors and Maintainers are expected to treat other community members with courtesy and respect, be willing and able to accept constructive criticism, and strive for understanding of other's viewpoints in all community channels.

## Building Bitops

To develop Bitops, first clone Bitops and create a new branch:

```
git clone https://github.com/bitovi/bitops.git
cd bitops
git checkout -b your-branch-name
```

Replace `your-branch-name` with the name of the feature you're building, e.g. `git checkout -b some-ansible-feature` to create a `some-ansible-feature` branch.

Then after modifying the code or adding your changes, re-build the Bitops docker image:

```
docker build bitops --tag bitovi/bitops:ansible-feature
```

You can now execute your modified version of Bitops locally to test your changes.

For example, to test your new `ansible-featire` version of Bitops with an Operations Repo named `ansible-operations-repo` containing an Ansible playbook and other data:

```
export AWS_ACCESS_KEY_ID=ABCDEF012345
export AWS_SECRET_ACCESS_KEY=ZYXWV09876
export AWS_DEFAULT_REGION=us-east-1
export MY_VAR1=value1
docker run \
-e ENVIRONMENT="ansible-operations-repo" \
-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
-e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
-e MY_VAR1=$MY_VAR1 \
-v $(pwd):/opt/bitops_deployment \
bitovi/bitops:ansible-feature
```


## Understanding Bitops

Bitops has several packages and environmental variables readily available which make working with Bitops easy:

### Standard Bitops Environmental Variables:

| Variable          | Value         |
|   :---            |   :---        |
| `$ENVROOT`        | `test`        |
| `$ENVIRONMENT`    | `test2`       |
| `$TEMPDIR`        | `test3`       |
| `...`             | `...`         |

### Standard Bitops packages:

System Packages natively available in Bitops:

* shyaml
* python3.8
* pip3
* ...

Python packages natively available in Bitops:

* ...
* ...

### Creating a New Plugin

-

## Testing

## Creating a PR

Once you have finished testing your code, please ensure you have first created an issue related to the feature you are developing.

After, push your new branch to Github:

```
git push --set-upstream origin some-ansible-feature
```

Once your code has been submitted to Github, navigate to the main Bitops Github page, and click the “New Pull Request” button. 

Select your branch name e.g `some-ansible-feature` as the 'compare' branch to attempt to merge. You may be warned about conflicts when merging the code, Github will try to tell you what is incorrect. 

If you're unable to solve the merge conflicts, don't worry you'll still be able to submit your PR, just make a note of the issues you were facing in the PR description and we will work with you to solve them.

Give your PR a meaningful title and provide details about the change in the description, including a link to the issue(s) relating to your PR. All that's left is to click the 'Create pull request' button and wait for our eager review of your code!

### Bash Styleguide

The Bitops container uses the Bourne shell during execution, please ensure all functions used in your submission exist for `sh`. Submissions that utilize alternate shells (`zsh`,`ksh`,`csh`, etc.) will not be accepted.

Bitops comes packaged with [`shyaml`](https://pypi.org/project/shyaml/) which can be used to parse YAML config files from stdout.

When contributing Bash code segments to Bitops please keep these concepts in mind:

* Add `echo` statements during plugin execution to give verbosity and debugging during execution
* Update any related documentation to the code or feature you are modifying
* Avoid multiple commands per line if possible. Replace `;` with whitespace and newline characters where appropriate.

### YAML Styleguide