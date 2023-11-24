local loaded = {}
require = function(moduleName)
    if loaded[moduleName] then
        return loaded[moduleName]
    end

    local code = LoadResourceFile(GetCurrentResourceName(), moduleName .. '.lua')

    if not code then
        error('Failed to load module ' .. moduleName)
    end

    local func = load(code, moduleName .. '.lua')

    if not func then
        error('Failed to load module ' .. moduleName)
    end

    local result = func()
    loaded[moduleName] = result
    return result
end

local Queue = require 'queue/main'
local Debug = require 'queue/debug'

AddEventHandler('playerConnecting', function(name, _, deferrals)
    local tempId = source
    Debug(string.format('[ps-discord] %s is connecting', name))
    local identifier = GetPlayerIdentifierByType(source, 'discord')
    identifier = identifier and identifier:gsub('discord:', '')
    if not identifier then
        deferrals.done(Lang.failedDiscordIdentifier)
        Debug(string.format('[ps-discord] %s failed to provide a Discord identifier', name))
        return
    end

    Queue:AddToQueue(tempId, identifier, deferrals)
end)

AddEventHandler('playerDropped', function(reason)
    local identifier = GetPlayerIdentifierByType(source, 'discord')
    identifier = identifier and identifier:gsub('discord:', '')
    if not identifier then
        return
    end

    Queue:AddToGrace(identifier)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= "hardcap" then return end

    StopResource(resourceName)
end)

if GetResourceState('hardcap') == 'started' then
    StopResource('hardcap')
end
