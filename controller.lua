require("worker")
Controller = {}


function Controller:toDestination(destRow, destCol)
    logger("FUNC => Controller:toDestination | param (destRow, destCol): ", destRow, destCol)
    local workerLocation = Worker:getGridLocation()
    local initRow, initCol = workerLocation.row, workerLocation.col --5 --5
    local function toDestRow()
        logger("FUNC => toDestRow")
        local pass = 1
        local loopEnd = destRow  -- 1
        local loopStart = initRow --5
        if initRow > destRow then
            pass = -1
          --  loopEnd = initRow --5
        end
        for row = loopStart + pass, loopEnd,pass do
            logger("LOOP => row = loopStart, pass, loopEnd: ", row, pass,loopEnd)
            workerLocation = Worker:getGridLocation()
            Controller:moveInRows(workerLocation.row, row)
        end
    end

    local function toDestCol()
        logger("FUNC => toDestCol")
        local pass = 1
        local loopEnd = destCol
        local loopStart = initCol
        if initCol > destCol then
            pass = -1
           -- loopEnd = initCol
        end
        for col = loopStart + pass, loopEnd,pass do
            logger("LOOP => col = loopStart, pass, loopEnd: ", col, pass,loopEnd)
            workerLocation = Worker:getGridLocation()
            Controller:moveInColumns(workerLocation.col, col,true)
        end
    end

    toDestRow()
    toDestCol()
end

function Controller:moveInRows(fromRow, toRow)
    logger("FUNC => Controller:moveInRows | param (fromRow, toRow): ", fromRow, toRow)
    if fromRow == toRow then
        return
    end

    if fromRow > toRow then
        Worker:faceToBack()
        Worker:forward()
        Worker:getGridLocation().row = toRow
        return
    end
    Worker:faceToFront()
    Worker:forward()
    Worker:getGridLocation().row = toRow


end

function Controller:moveInColumns(fromColumn, toColumn,afterFaceDirection)
    logger("FUNC => Controller:moveInColumns | param (fromColumn, toColumn): ", fromColumn, toColumn)
    if fromColumn == toColumn then
        return
    end

    if fromColumn > toColumn then
        if  afterFaceDirection or (fromColumn == 1 or fromColumn == 16) then
            Worker:faceToLeft()
        end
        Worker:forward()
    elseif fromColumn < toColumn then
        if afterFaceDirection or (fromColumn == 1 or fromColumn == 16) then
            Worker:faceToRight()
        end
        Worker:forward()
    end
    Worker:getGridLocation().col = toColumn


end

function Controller:moveByRightCol(row, size)
    logger("FUNC => Controller:moveByRightCol | param (row,size): ", row, size)



    for col = 1, size, 1 do
        local workerLocation = Worker:getGridLocation()
        local initRow, initCol = workerLocation.row, workerLocation.col
        Controller:toPosition(initRow, initCol, row, col)
        Worker:setGridLocation(row, col)
    end
end

function Controller:moveByLeftCol(row, size)
    logger("FUNC => Controller:moveByLeftCol | param (row,size): ", row, size)

    for col = size, 1, -1 do
        local workerLocation = Worker:getGridLocation()
        local initRow, initCol = workerLocation.row, workerLocation.col
        Controller:toPosition(initRow, initCol, row, col)
        Worker:setGridLocation(row, col)
    end
end

function Controller:toPosition(fromRow, fromColumn, toRow, toColumn)
    logger("FUNC => Controller:toPosition | param (fromRow, fromColumn, toRow, toColumn): ", fromRow, fromColumn, toRow,
        toColumn)


    Controller:moveInRows(fromRow, toRow) --   __
    Controller:moveInColumns(fromColumn, toColumn) --   |
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
