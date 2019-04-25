# tmpest-bot

# Set Environment Variables
* Eventually move this to be executed as part of UserData (scripts executed on instance start up)
** Need to determine what is persisted between Reboots/Instance swaps

This sets the Token from the Parameter store
> export TMPEST_BOT_DISCORD_TOKEN=$(aws ssm get-parameter --name 'tmpest-bot-discord-token-id' | jq -r .Parameter.Value)
