# adfs-health-check
PowerShell script to log into ADFS and report back on failures

### script opens IE, logs into federated services then redirects to AWS console and check url at end is logged in. Send alerts if not.

### Requires ###
# Slack Module
# Token api key for slack
# awscli installed for SMS feature
# SNS publish permissions for aws keys
