local QueueSystem = require 'api/queue'
local Debug = require 'queue/debug'

local API = {}

local discordAPIVersion = GetConvarInt('ps:discordAPIVersion', 10)
local discordGuildId = GetConvar('ps:discordGuildId', "")
local discordBotToken = GetConvar('ps:discordBotToken', '')

function API:FetchMemberInfo(discordId, callback)
    local function responseCallback(respCode, resultData, result, error)
        if respCode ~= 200 then
            Debug(error)
            Debug(string.format('[ps-discord] Failed to fetch member info for %s: %s', discordId, resultData))
            callback(false)
            return
        end

        local data = json.decode(resultData)

        if not data then
            Debug(string.format('[ps-discord] Failed to decode member info for %s: %s', discordId, resultData))
            callback(false)
            return
        end

        callback(data)
    end

    local request = {
        url = string.format('https://discord.com/api/v%s/guilds/%s/members/%s', discordAPIVersion, discordGuildId,
            discordId),
        method = 'GET',
        headers = {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = 'Bot ' .. discordBotToken
        },
        callback = responseCallback
    }

    QueueSystem:ProcessRequest(request)
end

return API
