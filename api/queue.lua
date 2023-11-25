local QueueSystem = {}
local requestsPerMinuteConvar = GetConvarInt('ps:discordRequestsPerMinute', 30)

local queue = {}
local recentRequests = {}
local shouldRunQueueChecks = false

local function doRequest(request, callback)
    local function responseCallback(respCode, resultData, result, error)
        if respCode == 429 then
            local retryAfter = error:match("\"retry_after\":(.-),")
            if not retryAfter or tonumber(retryAfter) == nil then
                retryAfter = 5
            end

            Debug(string.format('[ps-discord] Hit Discord\'s rate limit. Stalling and trying again in %s seconds',
                retryAfter))
            callback(retryAfter)
            return
        end

        callback(true)
        request.callback(respCode, resultData, result, error)
    end
    PerformHttpRequest(request.url, responseCallback, request.method, request.data, request.headers)
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

            local shouldStallForRateLimit = nil
            local p = promise.new()
            if #queue > 0 and #recentRequests < requestsPerMinuteConvar then
                local request = table.remove(queue, 1)
                doRequest(request, function(success)
                    if success == true then
                        table.insert(recentRequests, os.time())
                    else
                        table.insert(queue, request)
                        shouldStallForRateLimit = success
                    end

                    p:resolve()
                end)
            end

            Citizen.Await(p)

            if #queue == 0 then
                shouldRunQueueChecks = false
                break
            end

            if shouldStallForRateLimit then
                Wait(shouldStallForRateLimit * 1000)
            else
                Wait(500)
            end
        end
    end)
end

function QueueSystem:ProcessRequest(request)
    table.insert(queue, request)

    if not shouldRunQueueChecks then
        startQueue()
    end
end

return QueueSystem
