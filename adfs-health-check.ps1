# Login to ADFS then to AWS console and check url at end is logged in. Send alerts if not.

## Requires ##
# Slack Module
# Token api key for slack
# awscli installed for SMS feature
# SNS publish permissions for aws keys


# Paramaters
$token = "privateTokenHere"
$channel = "#general"
$slackModule = "..\adfs-health-check\Modules\PSSlack\PSSlack.psm1"
$onCallMobile = "+61#########"
Import-Module $slackModule


# Internal Email
$smtpServer = "contoso.com"
$smtpFrom = "noreply@contoso.com"
$smtpTo = "team@contoso.com"
$messageSubject = "ADFS to AWS failing login"


$ie = New-Object -ComObject 'internetExplorer.Application' -ErrorAction SilentlyContinue
# Change to $true to view
$ie.Visible= $false
$ie.Navigate("https://contoso.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices")
# Sleep for 10 seconds for redirects and loading
start-sleep -seconds 10

$currentSite = $ie.LocationURL
$sitesURL = @("https://ap-southeast-2.console.aws.amazon.com/console/home?region=ap-southeast-2","https://ap-southeast-2.console.aws.amazon.com/console/home?region=ap-southeast-2#")
 if ($sitesURL | where-object { $_ -eq $currentSite} )
    {
  echo "Website working..."
  }
  else {
     echo "ADFS through to AWS is down. URL comming back is: $currentSite"
     # Send SMS to oncall
     aws sns publish --phone-number $onCallMobile --message "AWS logins from ADFS is failing...possible ADFS down?"
     # Send Slack Message
     Send-SlackMessage -token $token -Channel $channel -BotName "#SlackBot" -Message "ADFS not passing through to AWS, URL recived:$currentSite"
     # Send Email to SSV
     Send-MailMessage -From "$smtpFrom" -To "$smtpTo" -Subject "$messageSubject" -Body "AWS Console failing to login through ADFS...URL expected:https://ap-southeast-2.console.aws.amazon.com/console/home?region=ap-southeast-2, however received: $currentSite" -SMTPServer "$smtpServer"
        }
# close IE
$ie.quit()
