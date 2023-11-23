--[[
    I just wanted to require modules for cleaner code, but I didn't want to use oxlib
    since more dependencies would be annoying. So here's a quick little implementation for this resource.
]]
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

AddEventHandler('playerConnecting', function(name, _, deferrals)
    print(string.format('[PS] %s is connecting', name))
    local identifier = GetPlayerIdentifierByType(source, 'discord')
    identifier = identifier and identifier:gsub('discord:', '')
    if not identifier then
        deferrals.done(Lang.failedDiscordIdentifier)
        print(string.format('[PS] %s failed to provide a Discord identifier', name))
        return
    end

    Queue:AddToQueue(identifier, deferrals)
end)

AddEventHandler('playerDropped', function(reason)
    local identifier = GetPlayerIdentifierByType(source, 'discord')
    identifier = identifier and identifier:gsub('discord:', '')
    if not identifier then
        return
    end

    Queue:PlayerLeft(identifier)
end)
