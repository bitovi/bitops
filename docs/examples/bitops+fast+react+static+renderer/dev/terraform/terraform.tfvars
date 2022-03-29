domain_name = "bitovi-cheetah.com"
subdomain_name_angular = "angular.bitovi-cheetah.com"
subdomain_name_react = "react.bitovi-cheetah.com"
s3_domain_name = "bitovi-operations-cheetah-sites.s3-website-us-west-2.amazonaws.com"
# s3_domain_name = "bitovi-operations-cheetah-sites.s3.us-west-2.amazonaws.com"
# s3_domain_name = "bitovi-operations-cheetah-sites.s3.amazonaws.com"
bucket_name = "bitovi-operations-cheetah-sites"
# https://console.aws.amazon.com/route53/v2/hostedzones#EditHostedZone/Z06474611GS5JE6QLWZJK #This value is obtained from the AWS Console. It is the zone id for the bitovi-cheetah.com zone.
# NOTE THIS HOSTED ZONE CHANGED WITH DOMAIN NAME CHANGE TO bitovi-cheetah.com
bitovi-cheetah.com-zone-id = "Z06474611GS5JE6QLWZJK"

# angular path and version
app_subpath_angular = "angular"
app_version_angular = "latest"

# react path and version
app_subpath_react = "react"
app_version_react = "latest"



common_tags = {
  OperationsRepo = "bitovi/operations-cheetah"
  OperationsRepoEnvironment = "dev"
 }


