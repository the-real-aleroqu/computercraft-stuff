local modem = peripheral.find("modem")  -- grab the modem
modem.open(69)                          -- open modem on channel 69 (nice)

local itemSlot = {  lamp = { 4, 3, 2, 1 },
                    redstone = { 8, 7, 6, 5 },
                    plate = { 12, 11, 10, 9 }
}

local itemName = {  lamp = "minecraft:redstone_lamp",
                    redstone = "minecraft:redstone_block",
                    plate = "darkutils:blank_plate"
}

local statusRunning = "All good!"
local errorStuck = "HELP I'M STUCK"
local errorNoItem = {   lamp = "No lamps :c",
                        redstone = "No redstone :c",
                        plate = "No plates :c"
}

-- turtle message
local file = io.open("coords.txt", "r")
assert(file, "No coords.txt")
local messageBody = {
    position = { x = tonumber(file:read()),
                 y = tonumber(file:read()),
                 z = tonumber(file:read()) },
    fuel = turtle.getFuelLevel(),
    status = statusRunning,
    warningLevel = 0 -- 0 = all good / 1 = warning / 2 = error
}

local movementAxis = file:read()
local direction = tonumber(file:read()) >= 0 and 1 or -1

io.close(file)

-- refuel turtle, returns false if not possible
local function fueledUp()
    if turtle.getFuelLevel() > 0 then return true end

    -- refuel
    for fuelSlot = 12, 16 do
        turtle.select(fuelSlot)
        if turtle.refuel() then turtle.select(slot) return true end
    end

    return false, errorStuck
end

local function grabItem(item)
    for _,slot in ipairs(itemSlot[item]) do
        turtle.select(slot)
        local selItem = turtle.getItemDetail()
        if selItem and selItem.name == itemName[item] and selItem.count > 1 then return true end
    end

    -- shit.
    return false, errorNoItem[item]
end

--- set warning if true
local function setWarning(warning)
    if warning then
        -- do not update warning if one was already found
        if messageBody.warningLevel == 1 then return true end
        messageBody.status = ("Issue at %s=%d"):format(movementAxis, messageBody.position.z)
        messageBody.warningLevel = 1
        return true
    end
    return false
end

---attempt to place item
local function placeItem(item)
     -- check if there's a block
    local exists, block = turtle.inspectDown()
    if item == "slate" and block.name == itemName["slate"] then return true end
    if setWarning(exists) then return true end

    -- attempt to place new block
    local result, message = grabItem(item)
    if not result then return result, message end -- error

    setWarning(not turtle.placeDown())
    return true
end

--- sets the lamp below
local function setLamp()
    local startY = messageBody.position.y
    local endY = messageBody.position.y - 2

    -- break space for lamp
    for y=startY-1,endY,-1 do
        turtle.digDown()
        turtle.down()
        messageBody.position.y = y
        messageBody.fuel = turtle.getFuelLevel()
        modem.transmit(69, 69, messageBody) -- update monitor here
    end
    turtle.digDown()

    -- place redstone
    local result, message = placeItem("redstone")
    if not result then return result, message end -- error, this will be here a lot
    turtle.up()
    messageBody.position.y = endY + 1
    messageBody.fuel = turtle.getFuelLevel()
    modem.transmit(69, 69, messageBody) -- update monitor here

    -- place lamp
    local result, message = placeItem("lamp")
    if not result then return result, message end -- error, this will be here a lot
    turtle.up()
    messageBody.position.y = startY
    messageBody.fuel = turtle.getFuelLevel()

    return true
end

local function errorHandler(error, message)
    if error then return true end -- no error, keep going
    -- send message to monitor
    messageBody.warningLevel = 2
    messageBody.status = message
    modem.transmit(69, 69, messageBody)
    modem.close(69)
    assert(error, message)
end

local function confirmStart()
    -- print message
    term.clear()
    term.setCursorPos(1,1)
    local message = ("Machine will start at (%d,%d,%d) moving in the %s direction of the %s axis.\n\nType \"start\" or \"s\" to confirm starting position and direction.")
                    :format(messageBody.position.x, messageBody.position.y, messageBody.position.z, direction == 1 and "positive" or "negative", movementAxis)
    print(message)

    -- get confirmation
    local confirmation = io.read():lower()
    if confirmation == "start" or confirmation == "s" then return true end
    return false
end

--[[
    main code
]]

if not confirmStart() then return end

--do it's thing
local steps = 0
while errorHandler(fueledUp()) do
    -- try to move forward
    if not turtle.forward() then errorHandler(false, errorStuck) end

    -- update message
    messageBody.position[movementAxis] = messageBody.position[movementAxis] + direction                 -- this only works cuz i'm the one doing this lmao (pos turtles can't get their own pos)
    messageBody.fuel = turtle.getFuelLevel()
    
    -- do stuff
    steps = steps + 1
    if steps <= 3 then
        local exists, block = turtle.inspectDown()
        if exists and block.name ~= itemName["slate"] then turtle.digDown() end
        errorHandler(placeItem("plate"))
    else errorHandler(setLamp()) steps = 0 end

    -- send message
    modem.transmit(69, 69, messageBody)
end