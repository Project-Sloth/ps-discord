# ps-discord
ps-discord is an efficient queue system for FiveM that has discord integration with a priority system.

## Usage
### Installation
1. Grab the latest release from the releases tab.
2. Extract the files to your server resources folder.
3. Remove any other queue resources & hardcap.
4. Set up your Roles & Prio in `ps-discord/queue/roles.lua`
4. Set up the resource to your needs with the convars stated below.

### Convars

- `set ps:discordDebug "true" or "false"` | STRING | If you want debug prints in server console.
- `set ps:discordAPIVersion 10` | INT | The Discord API Version you want to use (Recommended Version 10.)
- `set ps:discordGuildId "Your Discord Guild Id"` | STRING | This is for your Discord Guild ID (Right-click Server Name in Dev Mode and Copy Server ID.)
- `set ps:discordBotToken "Your Discord Guild Id"` | STRING | This is for your Discord Bot Token (Bot Token in Discord Developer Portal.)
- `set ps:discordRequestsPerMinute 30` | INT | The Max Amount of Requests to the Discord API per minute (Recommended Amount is 30)
