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



function Station:setStationDirections()
    logger("FUNC => Station:setStationDirections")
    local function getDirectionFromTypes(direction)
        logger("FUNC => getDirectionFromTypes | param (direction): ", direction)
        if DirectionTypes.NORTH == direction then
            return DirectionTypes.NORTH
        end
        if DirectionTypes.SOUTH == direction then
            return DirectionTypes.SOUTH
        end
        if DirectionTypes.WEST == direction then
            return DirectionTypes.WEST
        end
        if DirectionTypes.EAST == direction then
            return DirectionTypes.EAST
        end
    end
    Station.relativeFront = getDirectionFromTypes(Worker.relativeFront)
    Station.relativeRight = getDirectionFromTypes(Worker.relativeRight)
    Station.relativeLeft = getDirectionFromTypes(Worker.relativeLeft)
    Station.relativeBack = getDirectionFromTypes(Worker.relativeBack)
end

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