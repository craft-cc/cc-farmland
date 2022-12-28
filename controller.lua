require("worker")
Controller = {}

function Controller:moveInRows(fromRow, fromColumn, toRow, toColumn)
    logger("FUNC => Controller:moveInRows | param (fromRow, fromColumn, toRow, toColumn): ", fromRow, fromColumn, toRow,
        toColumn)
    if fromRow == toRow then
        return
    end


    if fromRow > toRow then
        Worker:faceToBack()
        Worker:forward()
        return
    end
    Worker:faceToFront()
    Worker:forward()

end

function Controller:moveInColumns(fromRow, fromColumn, toRow, toColumn)
    logger("FUNC => Controller:moveInColumns | param (fromRow, fromColumn, toRow, toColumn): ", fromRow, fromColumn,
        toRow, toColumn)
    if fromColumn == toColumn then
        return
    end

    if fromColumn > toColumn then
        Worker:faceToLeft()
        Worker:forward()
    elseif fromColumn < toColumn then
        Worker:faceToRight()
        Worker:forward()
    end

end

function Controller:moveByRightCol(row, size)
    logger("FUNC => Controller:moveByRightCol | param (row,size): ", row, size)


    local workerLocation = Worker:getGridLocation()
    local initRow, initCol = workerLocation.row, workerLocation.col
    for col = 1, size, 1 do
        Controller:toPosition(initRow, initCol, row, col)
        Worker:setGridLocation(row, col)
    end
end

function Controller:moveByLeftCol(row, size)
    logger("FUNC => Controller:moveByLeftCol | param (row,size): ", row, size)

    local workerLocation = Worker:getGridLocation()
    local initRow, initCol = workerLocation.row, workerLocation.col
    for col = size, 1, -1 do
        Controller:toPosition(initRow, initCol, row, col)
        Worker:setGridLocation(row, col)
    end
end

function Controller:toPosition(fromRow, fromColumn, toRow, toColumn)
    logger("FUNC => Controller:toPosition | param (fromRow, fromColumn, toRow, toColumn): ", fromRow, fromColumn, toRow,
        toColumn)


    Controller:moveInRows(fromRow, fromColumn, toRow, toColumn) --   __
    Controller:moveInColumns(fromRow, fromColumn, toRow, toColumn) --   |
end

function Controller:recheckDirection()
    logger("FUNC => Controller:recheckDirection")


    local function getMovementInfo(action)
        logger("FUNC => getMovementInfo | param (action): ", action)



        if not action then
            action = ActionsTypes.FORWARD
        end
        local locationInMove = nil
        if action == ActionsTypes.FORWARD then
            if not Worker:forward() then
                return getMovementInfo(ActionsTypes.RIGHT)
            else
                locationInMove = Worker:location(true)
                Worker:undo()
                return locationInMove
            end
        end
        if action == ActionsTypes.RIGHT then
            if not Worker:right() then
                return getMovementInfo(ActionsTypes.LEFT)
            else
                locationInMove = Worker:location(true)
                Worker:undo()
                return locationInMove
            end
        end
        if action == ActionsTypes.LEFT then
            if not Worker:left() then
                return getMovementInfo(ActionsTypes.BACK)
            else
                locationInMove = Worker:location(true)
                Worker:undo()
                return locationInMove
            end
        end
        if action == ActionsTypes.BACK then
            if not Worker:left() then
                assert(false, "Impossible to move!")
            else
                locationInMove = Worker:location(true)
                Worker:undo()
                return locationInMove
            end
        end
        return locationInMove
    end

    local function getDirection()
        logger("FUNC => getDirection")



        local locationInMove = getMovementInfo()
        local turtleX, turtleZ = locationInMove[1], locationInMove[2]

        if not turtleX then return nil end

        local stationLocation = Station:getStationLocation()
        if not stationLocation then
            Station:setLocation()
            stationLocation = Station:getStationLocation()
        end

        local dest_x, dest_z = stationLocation[1], stationLocation[2]
        local dx = dest_x - turtleX
        local dz = dest_z - turtleZ

        if math.abs(dx) > math.abs(dz) then
            if dx < 0 then
                return DirectionTypes.WEST
            else
                return DirectionTypes.EAST
            end
        else
            if dz < 0 then
                return DirectionTypes.SOUTH
            else
                return DirectionTypes.NORTH
            end
        end
    end

    local direction = getDirection()
    return direction
end
