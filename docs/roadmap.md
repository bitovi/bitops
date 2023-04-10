# Roadmap

This is a BitOps roadmap. It represents our current project direction.
BitOps is still a young project under brainstorming and heavy development.

If there’s something you need or have an idea, remember: this is Open Source.
Create an Issue, open a Discussion, join our Community and we'll be happy to work on shaping the project's future together.

## Backlog
- **Documentation:** Getting started guide
- **Documentation:** BitOps vs other tools comparison
- **CLI:** Ops repo generator
- **Plugins:** Custom version pinning
- **Community:** Ops repo catalog
- **Core:** Integration tests
- **Plugins:** Automated testing and validation
- **Core:** Run a deployment sub-step per tool
- **Core:** Schema validation and error reporting
- **Plugins:** Support for private repositories
- **Core:** Schema validation and enhancements

Check the [`main`](https://github.com/bitovi/bitops) repository branch to see the ongoing development.

## Release History
### In Development

### Done in v2.5.0
  - **Core:** Ops repo `bitops.config.yaml` override and deployment sequence control
  - **Core:** Unit tests coverage

### Done in v2.4.0
  - **Plugins:** ENV variable mapping based on plugin schema
  - **Plugins:** Plugin CLI command generation based on schema (beta)
  - **Website:** Revamp with new video and list of BitOps values
  - **Community:** Switch from Slack to Discord
  - **Community:** Add non-stop user survey

### Done in v2.3.0
  - **Security:** Secrets masking
  - **Core:** Local plugin install via `file://`

### Done in v2.2.0
  - **Core** Real-time command output streaming
  - **Code** `pylint` static code analyser for improving the python standards

### Done in v2.1.0
  - **Community:** Start bi-weekly [BitOps Community Meetings](https://github.com/bitovi/bitops/discussions?discussions_q=label%3Atype%3Ameeting)
  - **Plugins:** Package the latest tools versions by default in the official BitOps image
  - **Code:** Introduce `black` tool for enforcing the common python code formatting style

### Done in v2.0.0
  - **Core:** Rewrite the engine with Python instead of bash
  - **Plugins:** New system to compose the BitOps image with the custom tools
  - **Plugins:** Plugins catalog [github.com/bitops-plugins](https://github.com/bitops-plugins/)
  - **Images:** New official images: omnibus, aws-ansible, aws-terraform, aws-helm
  - **Releases:** New docker tagging strategy

### Done in v1.0.0
  - Ops Repository concept
  - Initial implementation in bash
