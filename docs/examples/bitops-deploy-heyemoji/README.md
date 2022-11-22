# Bitops Operations Repo for HeyEmoji app deployment
This repo is based on the HOWTO blog post [How to Deploy a HeyEmoji Slack App to AWS using Terraform](https://www.bitovi.com/blog/heyemoji-slack-app-aws-terraform-ansible)


This deployment can be run with:
```sh
docker run \
-e BITOPS_ENVIRONMENT="test" \
-e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
-e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
-e AWS_DEFAULT_REGION="us-east-2" \
-e TF_STATE_BUCKET="heyemoji_blog" \
-e HEYEMOJI_HEYEMOJI_SLACK_API_TOKEN="$HEYEMOJI_SLACK_API_TOKEN" \
-v $(pwd):opt/bitops_deployment \
bitovi/bitops:latest
```
Make sure to populate the secret ENV variables like `$AWS_ACCESS_KEY_ID`, `$AWS_SECRET_ACCESS_KEY`, and `$HEYEMOJI_SLACK_API_TOKEN`.

For more information, check out official BitOps docs https://bitovi.github.io/bitops/
