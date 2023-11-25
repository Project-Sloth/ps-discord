local Webhook = {}

local queue = {}
local requestsPerMinute = GetConvarInt('ps:discordRequestsPerMinute', 30)
local requestsMade = {}
local shouldRunQueueChecks = false

local function processQueue()
    for webhook, requests in pairs(requestsMade) do
        for i = #requests, 1, -1 do
            if os.time() - requests[i] > 60 then
                table.remove(requests, i)
            end
        end
    end

    for i = #queue, 1, -1 do
        local orgWebhook = queue[i].orgWebook
        if #requestsMade[orgWebhook] < requestsPerMinute then
            table.insert(requestsMade[orgWebhook], os.time())

            PerformHttpRequest(queue[i].webhook, queue[i].callback, 'POST', json.encode(queue[i].data),
                { ['Content-Type'] = 'application/json' })

            table.remove(queue, i)
        end
    end

    if #queue == 0 then
        shouldRunQueueChecks = false
    end
end

local function startQueueThread()
    CreateThread(function()
        while shouldRunQueueChecks do
            Wait(1000)

            processQueue()
        end
    end)
end

function Webhook:Send(webhook, data, callback, wait)
    if not requestsMade[webhook] then
        requestsMade[webhook] = {}
    end

    if not callback then
        callback = function() end
    end

    if #requestsMade[webhook] < requestsPerMinute then
        PerformHttpRequest(webhook .. (wait and "?wait=true" or ""), callback, 'POST', json.encode(data),
            { ['Content-Type'] = 'application/json' })
        table.insert(requestsMade[webhook], os.time())
    else
        table.insert(queue,
            { orgWebook = webhook, webhook = webhook .. (wait and "?wait=true" or ""), data = data, callback = callback })
        if not shouldRunQueueChecks then
            shouldRunQueueChecks = true
            startQueueThread()
        end
    end
end

function Webhook:EditMessage(webhook, messageId, data, callback)
    if not requestsMade[webhook] then
        requestsMade[webhook] = {}
    end

    if not callback then
        callback = function() end
    end

    if #requestsMade[webhook] < requestsPerMinute then
        PerformHttpRequest(webhook .. '/messages/' .. messageId, callback, 'PATCH', json.encode(data),
            { ['Content-Type'] = 'application/json' })

        table.insert(requestsMade[webhook], os.time())
    else
        table.insert(queue,
            { orgWebook = webhook, webhook = webhook .. '/messages/' .. messageId, data = data, callback = callback })

        if not shouldRunQueueChecks then
            shouldRunQueueChecks = true
            startQueueThread()
        end
    end
end

function Webhook:DeleteMessage(webhook, messageId, callback)
    if not requestsMade[webhook] then
        requestsMade[webhook] = {}
    end

    if not callback then
        callback = function() end
    end

    table.insert(queue,
        { orgWebook = webhook, webhook = webhook .. '/messages/' .. messageId, data = {}, callback = callback })

    if not shouldRunQueueChecks then
        shouldRunQueueChecks = true
        startQueueThread()
    end
end

return Webhook
