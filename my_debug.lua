require "pbin"
isLogActive = false
httpPut = false
FOLDER = "logs"
FILE_NAME = "log"
FILE_PATH = FOLDER .. "/" .. FILE_NAME
PriorityLevels = {
    INFO = "INFO",
    DEBUG = "DEBUG",
    ERROR = "ERROR"
}

function initDebug(active, pastenbinPut)
    isLogActive = active
    httpPut = isLogActive and pastenbinPut
    if not isLogActive then
        if fs.exists(FILE_NAME .. ".txt") then
            fs.delete(FILE_NAME .. ".txt")
        end
    end
end

local function pastenbinPut(filepath)
    local pastebinUrl = put(filepath)
    writeLines({ pastebinUrl })
end

function logger(...)
    local str = {}
    local function table_to_string(t, indent)
        -- If no indentation level is specified, start at 0
        if not indent then indent = 0 end

        -- Initialize an empty string to hold the output
        local output = ""

        -- Iterate through the table's keys
        for k, v in pairs(t) do
            -- Add the key with the appropriate indentation to the output string
            output = output .. string.rep("\t", indent) .. k .. ": "

            -- If the value is another table, print it recursively
            if type(v) == "table" then
                output = output .. "\n"
                output = output .. table_to_string(v, indent + 1)
            else
                -- Otherwise, just add the value to the output string
                output = output .. tostring(v) .. "\n"
            end
        end

        -- Return the completed output string
        return output
    end

    local paraments = { ... }
    for i, v in ipairs(paraments) do
        -- Check the type of the element
        if v == nil then
            strs[#strs + 1] = "nil"
        elseif type(v) == "table" then
            strs[#strs + 1] = table_to_string(v)
        elseif type(v) == "function" then
            strs[#strs + 1] = "type function()"
        else
            strs[#strs + 1] = tostring(v)
        end

    end
    local input = table.concat(strs, " ")
    local level = PriorityLevels.DEBUG
    local info = debug.getinfo(2, "Sl")
    local parentInfo = debug.getinfo(3, "Sl")

    local parentFile = info.source
    parentFile = parentFile:sub(2) -- remove the "@" symbol from the beginning of the file name
    local parentLineNumber = parentInfo.currentline

    local file = info.source
    file = file:sub(2) -- remove the "@" symbol from the beginning of the file name
    local lineNumber = info.currentline
    local date = os.date("%Y-%m-%d %H:%M:%S")
    local line = "[" .. level .. "] - " .. input .. "\n"
    if not isLogActive then
        print(line)
        return
    end
    print(line)
    line = "[" .. date .. "] -" .. "[" .. parentFile .. " | line: " .. parentLineNumber .. "] - [" .. file .. " | line: " .. lineNumber .. "] - " .. line
    local logFile = fs.open("log.txt", "a")
    logFile.write(line)
    logFile.close()
end
