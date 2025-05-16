
local vec = vector.new

local fuelChest = 1
local fuelSlot = 2

-- By convention, the slot next is its reserved item slot
local aChest = 3
local bChest = 5
local cChest = 7
local dChest = 9


direction = {
    north = vec(0,0,-1), -- 1
    east = vec(1,0,0), -- 2
    south = vec(0,0,1), -- 3
    west = vec(-1,0,0), -- 4
}

dirToIdx = {
    direction.north,
    direction.east,
    direction.south,
    direction.west
}

-- heading is north
-- desired direction west



local heading = nil
local curPos = nil
local function getDirId(desDir)
    for idx,a in pairs(dirToIdx) do
        if a == desDir then
            return idx
        end
    end
    return -1
end
-- TEST TEST TEST
-- Get bearing and set current position
local function setHeading()
    local px,py,pz = gps.locate()
    curPos = vec(px,py,pz)

    if turtle.inspect() == false then
        turtle.forward()
    else
        error("Error: Front blocked")
        return
    end

    local cx,_,cz = gps.locate()
    local sx = px - cx
    local sz = pz - cz
    turtle.back()

    if sz > 0 then
        heading = direction.north
    elseif sx > 0 then
        heading = direction.west
    elseif sz < 0 then
        heading = direction.south
    else
        heading = direction.east
    end
end

local function printHeading()
    for dir,v in pairs(direction) do
        if v == heading then
            error(dir)
            return
        end
    end
end

local function getHeadingAsStr()
    for dir,v in pairs(direction) do
        if v == heading then
            return dir
        end
    end
    return nil
end

local function getHeading()
    return heading
end

local function turnLeft()
    local cx = heading.z
    local cz = -heading.x

    heading = vec(cx, heading.y, cz)

    while turtle.turnLeft() ~= true do
    end
end

local function turnRight()
    local cx = -heading.z
    local cz = heading.x

    heading = vec(cx, heading.y, cz)


    while turtle.turnRight() ~= true do
    end
end

local function fwd()
    if turtle.getFuelLevel() == 0 then
        refuel()
    end

    if turtle.forward() then
        curPos = curPos + heading
        return true
    end
end

local function back()
    if turtle.getFuelLevel() == 0 then
        refuel()
    end

    if turtle.back() then
        curPos = curPos - heading
        return true
    end
end

local function up()
    if turtle.getFuelLevel() == 0 then
        refuel()
    end

    if turtle.up() then
        curPos = curPos + vec(0,1,0)
        return true
    end
end

local function down()
    if turtle.getFuelLevel() == 0 then
        refuel()
    end

    if turtle.down() then
        curPos = curPos + vec(0,-1,0)
        return true
    end
end



-- positive CW, negative CCW
local function face(desiredDirection)
    local idx = (getDirId(desiredDirection) - 1) % 4
    local headingId = (getDirId(heading) - 1) % 4

    local rightTurns = (idx - headingId) % 4 
    local leftTurns = (4 - rightTurns) % 4 

    if leftTurns < rightTurns then
        while leftTurns ~= 0 do
            turnLeft()
            leftTurns = leftTurns - 1
        end
    else
        while rightTurns ~= 0 do
            turnRight()
            rightTurns = rightTurns - 1
        end
    end
end

local function goTo(x,y,z)
    dx = curPos.x  - x
    dy = curPos.y - y
    dz = curPos.z - z

    while dy ~= 0 do
        if dy < 0 then
            up()
        elseif dy > 0 then
            down()
        end
        dy = curPos.y - y
    end

    if dz > 0 then
        face(direction.north)
    else
        face(direction.south)
    end
    while dz ~= 0 do
        fwd()
        dz = curPos.z - z
    end
    if dx > 0 then
        face(direction.west)
    else
        face(direction.east)
    end
    while dx ~= 0 do
        fwd()
        dx = curPos.x  - x
    end

end

local function refuel()
    turtle.select(fuelChest)
    if turtle.placeUp() then
        turtle.select(fuelSlot)
        turtle.suckUp()
        turtle.refuel()
        turtle.digUp()
    elseif turtle.placeDown() then
        turtle.suckDown()
        turtle.refuel()
        turtle.digDown()
    else
        error("Unable to refuel")
    end
end

local function refill(chestSlot, itemSlot)
    turtle.select(chestSlot)
    if turtle.placeUp() then
        turtle.select(itemSlot)
        turtle.suckUp()
        turtle.select(chestSlot)
        turtle.digUp()
    elseif turtle.placeDown() then
        turtle.select(itemSlot)
        turtle.suckDown()
        turtle.select(chestSlot)
        turtle.digDown()
    else
        error("Unable to refill")
    end
end
local function refillA()
    chestSlot =aChest
    itemSlot = aChest + 1
    turtle.select(chestSlot)
    if turtle.placeUp() then
        turtle.select(itemSlot)
        turtle.suckUp()
        turtle.select(chestSlot)
        turtle.digUp()
    elseif turtle.placeDown() then
        turtle.select(itemSlot)
        turtle.suckDown()
        turtle.select(chestSlot)
        turtle.digDown()
    else
        error("Unable to refill")
    end
    turtle.select(itemSlot)


end

local function place(slot,refillFunc,placingFunc)
    local placingFunc = placingFunc or turtle.placeDown
    local refillFunc = refillFunc or  refillA
    turtle.select(slot)
    
    if placingFunc() ~= true then
        if turtle.getItemCount(slot) == 0 then
            print(turtle.getItemCount(slot))
            refillFunc()
            turtle.select(slot)
        end
        
        if placingFunc() ~= true then
            print("Warning: Unable to placedown")
            return false
        end
    end
end


local function placeDownAt(x,y,z, chestSlot)
    goTo(x,y+1,z)
    local itemSlot = chestSlot+1
    place(itemSlot, refillA)
end

local function placeDownAt(point, chestSlot)
    goTo(point.x, point.y + 1, point.z)
    local itemSlot = chestSlot+1
    place(itemSlot,  refillA)
end

setHeading()

return {
    placeDown = placeDownAt,
    chests = {
        a = aChest,
        b = bChest
    },
}
