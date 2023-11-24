local DiscordAPI = require 'api/main'
local Roles = require 'queue/roles'
local Debug = require 'queue/debug'

local maxPlayersConvar = GetConvarInt('sv_maxclients', 48)

local Queue = {}
local inQueue = {}
local shouldQueueRun = false

local function sortQueue()
    local usersWithPriority = {}

    for _, data in ipairs(inQueue) do
        if data.priority > 0 then
            table.insert(usersWithPriority, data)
        end
    end

    table.sort(usersWithPriority, function(a, b)
        if a.priority == b.priority then
            return a.index < b.index
        else
            return a.priority < b.priority
        end
    end)

    local finalyQueueList = {}

    for _, data in ipairs(usersWithPriority) do
        table.insert(finalyQueueList, data)
    end

    for _, data in ipairs(inQueue) do
        if data.priority == 0 then
            table.insert(finalyQueueList, data)
        end
    end

    inQueue = finalyQueueList
end

local function updateQueueNumbers()
    for i, data in ipairs(inQueue) do
        data.deferrals.update(string.format(Lang.inQueue, i))
    end
end

local function startQueue()
    shouldQueueRun = true

    CreateThread(function()
        while shouldQueueRun do
            Citizen.Wait(1000)

            local playersInServer = #GetPlayers()

            for i, data in ipairs(inQueue) do
                if not GetPlayerName(data.source) then
                    table.remove(inQueue, i)
                    updateQueueNumbers()
                end
            end

            if #inQueue > 0 and playersInServer < maxPlayersConvar then
                local data = table.remove(inQueue, 1)

                data.deferrals.done()
                Debug(string.format('[ps-discord] %s has connected', data.identifier))

                updateQueueNumbers()
            end

            if #inQueue == 0 then
                shouldQueueRun = false
                break
            end
        end
    end)
end

function Queue:AddToQueue(source, identifier, deferrals)
    deferrals.defer()
    deferrals.update(Lang.connecting)

    DiscordAPI:FetchMemberInfo(identifier, function(user)
        if not user then
            deferrals.done(Lang.failedToFindDiscord)
            return
        end

        Debug(string.format('[ps-discord] Found Discord user %s (%s)', user.user.username, user.user.id))

        local roles = user.roles
        local hasRole = false

        if #Roles.allowlistedRoles == 0 then
            hasRole = true
        end

        local priority = 0
        for _, role in ipairs(roles) do
            if not hasRole then
                for _, allowedRole in ipairs(Roles.allowlistedRoles) do
                    if role == allowedRole then
                        hasRole = true
                        break
                    end
                end
            end

            for prio, priorityRole in ipairs(Roles.priorityRoles) do
                if role == priorityRole then
                    priority = prio
                end
            end
        end

        if not hasRole then
            deferrals.done(Lang.noRole)
            return
        end

        table.insert(inQueue, {
            source = source,
            identifier = identifier,
            priority = priority,
            deferrals = deferrals,
            index = #inQueue + 1
        })
        sortQueue()
        deferrals.update(string.format(Lang.inQueue, #inQueue))
        updateQueueNumbers()

        if not shouldQueueRun then
            startQueue()
        end
    end)
end

function Queue:PlayerLeft(identifier)
    for i, data in ipairs(inQueue) do
        if data.identifier == identifier then
            table.remove(inQueue, i)
            updateQueueNumbers()
            break
        end
    end
end

return Queue
