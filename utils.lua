

function readJsonFile(path)
    local file = fs.open(path, "r")
    if not file then
        error("Could not open file: " .. path)
    end
    local contents = file.readAll()
    file.close()
    return textutils.unserialize(contents)
end

function writeJsonFile(path, data)
    local file = fs.open(path, "w")
    if not file then
        error("Could not open file: " .. path)
    end
    file.write(textutils.serialize(data))
    file.close()
end


function consoleWrite(input,color)
    local originalColor  = term.getTextColor()
    term.setTextColor(color)
    term.write(input)
    term.setTextColor(originalColor)
end