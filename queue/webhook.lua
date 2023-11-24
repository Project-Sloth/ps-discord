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
        local webhook = queue[i].webhook
        if requestsMade[webhook] < requestsPerMinute then
            table.insert(requestsMade[webhook], os.time())

            PerformHttpRequest(webhook, queue[i].callback, 'POST', json.encode(queue[i].data),
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

function Webhook:Send(webhook, data, callback)
    if not requestsMade[webhook] then
        requestsMade[webhook] = {}
    end

    if #requestsMade[webhook] < requestsPerMinute then
        PerformHttpRequest(webhook .. "?wait=true", callback, 'POST', json.encode(data),
            { ['Content-Type'] = 'application/json' })
        table.insert(requestsMade[webhook], os.time())
    else
        table.insert(queue, { webhook = webhook, data = data, callback = callback })
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

    if #requestsMade[webhook] < requestsPerMinute then
        PerformHttpRequest(webhook .. '/messages/' .. messageId, callback, 'PATCH', json.encode(data),
            { ['Content-Type'] = 'application/json' })

        table.insert(requestsMade[webhook], os.time())
    else
        table.insert(queue, { webhook = webhook .. '/messages/' .. messageId, data = data, callback = callback })

        if not shouldRunQueueChecks then
            shouldRunQueueChecks = true
            startQueueThread()
        end
    end
end

return Webhook
