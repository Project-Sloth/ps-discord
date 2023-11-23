local QueueSystem = {}
local requestsPerMinuteConvar = GetConvarInt('ps:discordRequestsPerMinute', 30)

local queue = {}
local recentRequests = {}
local shouldRunQueueChecks = false

local function doRequest(request)
    PerformHttpRequest(request.url, request.callback, request.method, request.data, request.headers)
end

local function startQueue()
    shouldRunQueueChecks = true

    CreateThread(function()
        while shouldRunQueueChecks do
            if #recentRequests > 0 then
                for i = #recentRequests, 1, -1 do
                    if os.time() - recentRequests[i] > 60 then
                        table.remove(recentRequests, i)
                    end
                end
            end

            if #queue > 0 and #recentRequests < requestsPerMinuteConvar then
                doRequest(table.remove(queue, 1))
                table.insert(recentRequests, os.time())
            end

            if #queue == 0 then
                shouldRunQueueChecks = false
                break
            end

            Citizen.Wait(500)
        end
    end)
end

function QueueSystem:ProcessRequest(request)
    if #recentRequests < requestsPerMinuteConvar then
        doRequest(request)
        table.insert(recentRequests, os.time())
    else
        table.insert(queue, request)

        if not shouldRunQueueChecks then
            startQueue()
        end
    end
end

return QueueSystem
