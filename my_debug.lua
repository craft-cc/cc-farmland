
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
    if not isLogActive then
        if fs.exists("log.txt") then
            fs.delete("log.txt")
        end
    end
end


local function pastenbinPut(filepath)
   local pastebinUrl = put(filepath)
   writeLines({pastebinUrl})
end

function logger(input, level)
    if not level then
        level = PriorityLevels.DEBUG
    end
    -- get the name of the file that is calling the logger function
   -- local file = debug.getinfo(2, "S").source
    --file = file:sub(2) -- remove the "@" symbol from the beginning of the file name
    local date = os.date("%Y-%m-%d %H:%M:%S")
    local line = level  .. " - " .. input .. "\n"
    if not isLogActive then
        print(line)
        return
    end
    print(line)
    line = date .. " - " .. line
    local logFile = fs.open("log.txt", "a")
    logFile.write(line)
    logFile.close()
  end






