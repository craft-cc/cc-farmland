require("storage")



Station = {
    Blocks = {
        IRON_BLOCK = "quark:iron_plate",
        INVENTORY = "inventory",
    },
    getStorage = Storage,
    relativeFront = nil,
    relativeRight = nil,
    relativeLeft = nil,
    relativeBack = nil,
}

_stationLocation = nil


function Station:setLocation()
    logger("FUNC => Station:setLocation")

    

    Worker:isAtStation()
    local x,z,y = Worker:location()
    _stationLocation = {x,z,y}
end

function Station:getStationLocation()
    logger("FUNC => Station:getStationLocation")

    

    return _stationLocation
end

function Station:getStorage()
    logger("FUNC => Station:getStorage")

    


end