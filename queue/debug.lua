local debugMode = GetConvar("ps:discordDebug", "false") == "true"

function Debug(...)
    if debugMode then
        print(...)
    end
end

return Debug