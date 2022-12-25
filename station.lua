
require("worker")
require("storage")



Station = {
    Blocks = {
        IRON_BLOCK = "iron_block",
        INVENTORY = "inventory",
    },
    getStorage = Storage
}

_stationLocation = nil


function Station:setLocation()
    Worker:isAtStation()
    local x,z,y = Worker:location()
    _stationLocation = {x,z,y}
end

function Station:getStationLocation()
    return _stationLocation
end

function Station:getStorage()

end