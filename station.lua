
require("worker")

Station = {
    Blocks = {
        IRON_BLOCK = "iron_block",
        CHEST_BACK = "chest_block",
    },
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