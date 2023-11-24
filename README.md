# ps-discord
ps-discord is an efficient standalone queue system for FiveM that has discord integration with a priority system. This script was inspired in response to numerous inefficient scripts that cause server-side lag, particularly when the Discord API is rate-limited. Our testing has shown that this script remains highly stable, with server-side performance between 0.00 and 0.03 ms. Additionally, the included anti rate-limiter for Discord effectively limits the number of requests to 30 per minute, ensuring smooth operation.

## Usage
### Installation
1. Grab the latest release from the releases tab.
2. Extract the files to your server resources folder.
3. Remove any other queue resources.
4. Go to the Discord Developer Portal, and create an app if you haven't already. Find it [here](https://discord.com/developers/applications/)
5. Copy your bot token and put it in the server cfg, as this: `set ps:discordBotToken "TOKENHERE"`.
6. Copy your servers ID and put it in the server cfg as this: `set ps:discordGuildId "IDHERE"` (This can be found by enabling the Developer mode on Discord, and right clicking on your server)
7. Set up `queue/roles.lua` and `queue/card.lua` to your liking. See [Configuration](#configuration) for more information.
8. Check the list of covars below, to see if there's anything else you might want to change.
9. Done! You've successfully installed ps-discord!

### Configuration
You primarily configure the resource with the convars stated below. There however is two files you should edit to your liking.
That is `queue/roles.lua` and `queue/card.lua`, the first one determines which roles have access and their priority and the second one is the card that is displayed in the queue.

### Commands
| Command | Description |
| --- | --- |
| `clearWebhookStatus` | Clears the webhook status message id, in case you want/need to send a new one. |

### Convars
You only have to configure the convars that has `none` as default value. The rest is optional. These should be placed in the `server.cfg` file or a file loaded by it.
| Convar | Type | Default | Description |
| --- | --- | --- | --- |
| `set ps:discordDebug` | STRING | "false" | If you want debug prints in server console. |
| `set ps:discordAPIVersion` | INT | 10 | The Discord API Version you want to use (Recommended Version 10.) |
| `set ps:discordGuildId` | STRING | none | This is for your Discord Guild ID (Right-click Server Name in Dev Mode and Copy Server ID.) |
| `set ps:discordBotToken` | STRING | none | This is for your Discord Bot Token (Bot Token in Discord Developer Portal.) |
| `set ps:discordRequestsPerMinute` | INT | 30 | The Max Amount of Requests to the Discord API per minute (Recommended Amount is 30) |
| `set ps:displayQueueInHostname` | INT | 1 | If you want to display the queue in the hostname (1 = true, 0 = false) |
| `set ps:gracePeriod` | INT | 0 | The amount of time a player can be disconnected and join back to get upped queue priority (in seconds) (0 = disabled) |
| `set ps:ghostCheckInterval` | INT | 60 | The amount of time to check for ghost players (in seconds) |
| `set ps:webhookStatusMessage` | STRING | none | The webhook to send the status message to (leave blank to disable) |
| `set ps:webhookStatusUpdateInterval` | INT | 30 | The amount of time to send the status message to the webhook (in seconds) (Defualt is 30) |

### Exports
#### `exports["ps-discord"]:GetQueueStatus(identifier)`
Gets the queue status of a player.

| Parameter | Type | Description |
| --- | --- | --- |
| `identifier` | STRING | The identifier of the player to get the queue status of. |

| Return | Type | Description |
| --- | --- | --- |
| queueNumber | INT | The queue number of the player. |
| queuePriority | INT | The queue priority of the player. |

#### `exports["ps-discord"]:UpdateQueuePriority(identifier, priority)`
Updates the queue priority of a player for this load only.

| Parameter | Type | Description |
| --- | --- | --- |
| `identifier` | STRING | The identifier of the player to update the queue priority of. |
| `priority` | INT | The new queue priority of the player. |

| Return | Type | Description |
| --- | --- | --- |
| success | BOOL | Whether or not the queue priority was updated. |

#### `exports["ps-discord"]:ForceRefreshQueue()`
Forces the queue to refresh everyones queue number and priority.

#### `exports["ps-discord"]:OnQueueAdded(callback)`
Adds a callback to be called when a player is added to the queue.

| Parameter | Type | Description |
| --- | --- | --- |
| `callback` | FUNCTION | The callback function to call when a player is added to the queue. |

**Example:**
```lua
exports["ps-discord"]:OnQueueAdded(function(identifier, priority)
    print("Player " .. identifier .. " was added to the queue with priority " .. priority)
end)
```

#### `exports["ps-discord"]:WebhookSend(webhook, data, callback, wait)`
Sends a message to a webhook.

| Parameter | Type | Description |
| --- | --- | --- |
| `webhook` | STRING | The webhook to send the message to. |
| `data` | TABLE | The data to send to the webhook. |
| `callback` | FUNCTION | The callback function to call when the request is done. |
| `wait` | BOOL | Set this to true if you wish to edit the message later, this will return the message in the reponse parameter of the callback |

#### `exports["ps-discord"]:WebhookEdit(webhook, message, data, callback)`
Edits a message sent by a webhook.

| Parameter | Type | Description |
| --- | --- | --- |
| `webhook` | STRING | The webhook to edit the message from. |
| `messageId` | STRING | The message id to edit. |
| `data` | TABLE | The data to send to the webhook. |
| `callback` | FUNCTION | The callback function to call when the request is done. |

#### `exports["ps-discord"]:WebhookSendMessage(webhook, name, title, color, message, tagEveryone, callback, wait)`
Sends a message to a webhook with a premade embed.

| Parameter | Type | Description |
| --- | --- | --- |
| `webhook` | STRING | The webhook to send the message to. |
| `name` | STRING | The name of the embed account sending the messaged |
| `title` | STRING | The title of the embed. |
| `color` | INT or STRING | The color of the embed. |
| `message` | STRING | The message of the embed. |
| `tagEveryone` | BOOL | Whether or not to tag everyone in the message. |
| `callback` | FUNCTION | The callback function to call when the request is done. |
| `wait` | BOOL | Set this to true if you wish to edit the message later, this will return the message in the reponse parameter of the callback |

#### `exports["ps-discord"]:WebhookEditMessage(webhook, messageId, name, title, color, message, tagEveryone, callback)`
Edits a message sent by a webhook with a premade embed.

| Parameter | Type | Description |
| --- | --- | --- |
| `webhook` | STRING | The webhook to edit the message from. |
| `messageId` | STRING | The message id to edit. |
| `name` | STRING | The name of the embed account sending the messaged |
| `title` | STRING | The title of the embed. |
| `color` | INT or STRING | The color of the embed. |
| `message` | STRING | The message of the embed. |
| `tagEveryone` | BOOL | Whether or not to tag everyone in the message. |
| `callback` | FUNCTION | The callback function to call when the request is done. |

## Preview
![image](https://github.com/Project-Sloth/ps-discord/assets/82112471/83b680c9-db2a-40aa-a958-ff68c58a81bb)
![image](https://github.com/Project-Sloth/ps-discord/assets/82112471/2bc02073-0779-44b0-ac78-e681e23d1e94)

## Credits
[Walter](https://github.com/Walter-00)
[complexza](https://github.com/complexza)
