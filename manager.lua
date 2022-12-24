 
require("debug")
require("worker")
require("controller")
require("station")
debug(true)

local function parseArguments(arg)
    local function validation(input)
        return string.match(input, "%d+x%d+")
    end

    local function split(input, pattern)
        local substrings = {}
        for substring in string.gmatch(input, "[^" .. pattern .. "]+") do
            substrings[#substrings + 1] = substring
        end
        return substrings
    end

    local substrs = split(arg, "x")
    local targetRow = tonumber(substrs[1])
    local targetColumn = tonumber(substrs[2])
    return targetRow, targetColumn
end








