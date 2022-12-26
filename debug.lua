

require "pbin"
isLogActive = false
httpPut = false
FOLDER = "logs"
FILE_NAME = "log"
FILE_PATH = FOLDER .. "/" .. FILE_NAME
PriorityLevels = {
    INFO = "info",
    DEBUG = "debug",
    ERROR= "error"
}

function debug(active,pastenbinPut)
    isLogActive = active
    httpPut = isLogActive and pastenbinPut
end


local function pastenbinPut(filepath)
   local pastebinUrl = put(filepath)
   writeLines({pastebinUrl})
end

local function logger(input, level)
    if not level then
        level = PriorityLevels.DEBUG
    end
    -- get the name of the file that is calling the logger function
    local file = debug.getinfo(2, "S").source
    file = file:sub(2) -- remove the "@" symbol from the beginning of the file name
    local line = os.date() .. " - " .. level .. " - " .. file .. " - " .. input .. "\n"
    if not isLogActive then
        print(line)
        return
    end
    local logFile = fs.open("log.txt", "a")
    logFile.write(line)
    logFile.close()
    print(line)
  end






