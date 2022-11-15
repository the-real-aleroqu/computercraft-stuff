local monitor = peripheral.find("monitor") or error("No monitor attached", 0) -- grab the monitor
local modem = peripheral.find("modem") or error("No modem attached", 0) -- grab the modem

-- turtle message 
local messageBody = {
    position = { x = 0,
                 y = 0,
                 z = 0 },
    fuel = 0,
    status = "",
    warningLevel = 0 -- 0 = all good / 1 = warning / 2 = error
}

local curWarning = "" -- keep mind of warning

local function clearMonitor()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    monitor.setCursorPos(1,1)   -- monitor starts at (1,1)
end

local function warningHandler(warningLevel)
    if warningLevel == 0 then return colors.green end
    if warningLevel == 1 then curWarning = messageBody.status return colors.yellow end
    if warningLevel == 2 then
        if curWarning ~= "" then
            monitor.setBackgroundColor(colors.yellow)
            monitor.write(curWarning)
            monitor.setCursorPos(2,11)
        end
        return colors.red
    end
end

--[[
    main code
]]

modem.open(69)  -- open modem on channel 69 (nice)

local event, side, channel, replyChannel, distance -- event vars

-- waits for input from the turtle
while true do
    event, side, channel, replyChannel, messageBody, distance = os.pullEvent("modem_message")
    clearMonitor()
    -- type position
    monitor.write("Position:")
    monitor.setCursorPos(2,2)
    monitor.write(("%d, %d, %d"):format(messageBody.position.x, messageBody.position.y, messageBody.position.z))

    -- type fuel
    monitor.setCursorPos(1,5)
    monitor.write("Fuel:")
    monitor.setCursorPos(2,6)
    monitor.write(("%d"):format(messageBody.fuel))

    -- type status
    monitor.setCursorPos(1,9)
    monitor.write("Status:")
    monitor.setCursorPos(2,10)
    monitor.setBackgroundColor(warningHandler(messageBody.warningLevel))
    monitor.write(messageBody.status)
end