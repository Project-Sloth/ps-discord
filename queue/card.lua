local Card = {}

--[[
    You may change these to your liking.
    If you don't want something, just set it to nil.
]]
local imageUrl = nil

local title = "Project Sloth - Discord Queue"

local text = [[
Our server is very good, check our Discord for more!
Remember to read the rules!
]]

local buttonOne = {
    title = "Docs",
    url = "https://docs.projectsloth.org/ps/"
}

local buttonTwo = {
    title = "Discord",
    url = "https://discord.gg/projectsloth"
}

function Card:Build(queueNumber, totalInQueue)
    local body = {}

    if imageUrl then
        table.insert(body, {
            ["type"] = "Image",
            ["horizontalAlignment"] = "Center",
            ["url"] = imageUrl
        })
    end

    if title then
        table.insert(body, {
            ["type"] = "TextBlock",
            ["text"] = title,
            ["wrap"] = true,
            ["size"] = "ExtraLarge",
            ["horizontalAlignment"] = "Center",
            ["weight"] = "Bolder",
            ["isSubtle"] = true
        })
    end

    if text then
        table.insert(body, {
            ["type"] = "TextBlock",
            ["text"] = text,
            ["wrap"] = true,
            ["horizontalAlignment"] = "Center",
            ["size"] = "Large"
        })
    end

    if queueNumber then
        table.insert(body, {
            ["type"] = "TextBlock",
            ["text"] = string.format("Your current position is: %s / %s", queueNumber, totalInQueue),
            ["wrap"] = true,
            ["size"] = "Large",
            ["horizontalAlignment"] = "Center"
        })
    end

    if buttonOne or buttonTwo then
        local columnSet = {
            ["type"] = "ColumnSet",
            ["horizontalAlignment"] = "Center",
            ["columns"] = {}
        }

        if buttonOne then
            table.insert(columnSet.columns, {
                ["type"] = "Column",
                ["alignItems"] = "Right",
                ["items"] = {
                    {
                        ["type"] = "ActionSet",
                        ["horizontalAlignment"] = "Right",
                        ["actions"] = {
                            {
                                ["type"] = "Action.OpenUrl",
                                ["title"] = buttonOne.title,
                                ["url"] = buttonOne.url
                            }
                        }
                    }
                }
            })
        end

        if buttonTwo then
            table.insert(columnSet.columns, {
                ["type"] = "Column",
                ["items"] = {
                    {
                        ["type"] = "ActionSet",
                        ["actions"] = {
                            {
                                ["type"] = "Action.OpenUrl",
                                ["title"] = buttonTwo.title,
                                ["url"] = buttonTwo.url
                            }
                        }
                    }
                }
            })
        end

        table.insert(body, columnSet)
    end

    return {
        ["type"] = "AdaptiveCard",
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
        ["version"] = "1.2",
        ["body"] = body
    }
end

return Card
