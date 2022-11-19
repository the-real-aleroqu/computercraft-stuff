local basalt = require("basalt")
local monitor = peripheral.find("monitor")
local adapter = peripheral.find("fissionReactorLogicAdapter")

if monitor == nil then error("Could not find monitor!") end
if adapter == nil then error("Could not find reactor logic adapter!") end

--- Temperature Levels
local _temperatureYellow = 600  -- Slightly Hot
local _temperatureOrange = 1000 -- Very Hot.
local _temperatureRed = 1200    -- Hotness Levels Critical (whew)

--- Reactor Max Values
local _maxCoolant = adapter.getCoolantCapacity()
local _maxFuel = adapter.getFuelCapacity()
local _maxHeatedCoolant = adapter.getHeatedCoolantCapacity()
local _maxWaste = adapter.getWasteCapacity()

--- Item Names
local _itemNames = {
    ["minecraft:water"] = "Water",
    ["mekanism:sodium"] = "Sodium",
    ["mekanism:fissile_fuel"] = "Fissile Fuel",
    ["mekanism:steam"] = "Steam",
    ["mekanism:superheated_sodium"] = "Superheated Sodium",
    ["mekanism:nuclear_waste"] = "Nuclear Waste",
    ["minecraft:empty"] = "Empty",
    ["mekanism:empty"] = "Empty"
}

local _button = {
    text = {
        [false] = "Start",
        [true] = "SCRAM"
    },
    color = {
        [false] = colors.green,
        [true] = colors.red
    }
}

--- Reactor object (internal values, object methods)

-- adapter.getCoolant() ->
--      {
--          name = "minecraft:water",
--          amount = 119523556
--      }

local reactor = {
    status = false,
    temperature = 0.0,
    damage = 0,
    burnRate = 0.0,
    coolant = {},
    coolantLevel = 0,
    fuel = {},
    fuelLevel = 0,
    heatedCoolant = {},
    heatedCoolantLevel = 0,
    waste = {},
    wasteLevel = 0
}

function reactor:updateValues()
    self.status = adapter.getStatus()
    self.temperature = adapter.getTemperature()
    self.damage = adapter.getDamagePercent()
    self.burnRate = adapter.getBurnRate()
    self.coolant = adapter.getCoolant()
    self.coolantLevel = math.floor(adapter.getCoolantFilledPercentage() * 100)
    self.fuel = adapter.getFuel()
    self.fuelLevel = math.floor(adapter.getFuelFilledPercentage() * 100)
    self.heatedCoolant = adapter.getHeatedCoolant()
    self.heatedCoolantLevel = math.floor(adapter.getHeatedCoolantFilledPercentage() * 100)
    self.waste = adapter.getWaste()
    self.wasteLevel = math.floor(adapter.getWasteFilledPercentage() * 100)
end

function reactor:temperaturePercentage()
    return math.min(math.floor(self.temperature / 1800 * 100),100)    -- Returns percentage for the temperature bar (0-100)
end

function reactor:getCoolantName()
    return _itemNames[self.coolant.name]
end

function reactor:getFuelName()
    return _itemNames[self.fuel.name]
end

function reactor:getHeatedCoolantName()
    return _itemNames[self.heatedCoolant.name]
end

function reactor:getWasteName()
    return _itemNames[self.waste.name]
end

function reactor:addBurnRate(value)
    local newBurnRate = tonumber(string.format("%.1f",self.burnRate + value))
    if pcall(function() adapter.setBurnRate(newBurnRate) end) then
        self.burnRate = newBurnRate
    end
end


local function temperatureColor()
    if reactor.temperature >= _temperatureRed then return colors.red end
    if reactor.temperature >= _temperatureOrange then return colors.orange end
    if reactor.temperature >= _temperatureYellow then return colors.yellow end
    return colors.green
end

local function damageColor()
    if reactor.damage > 25 then return colors.yellow end
    if reactor.damage > 50 then return colors.orange end
    if reactor.damage > 75 then return colors.red end -- big uh oh
    return colors.green
end

local function valueLevelColor(color)
    if color < 5 then return colors.red end
    if color < 25 then return colors.orange end
    if color < 50 then return colors.yellow end
    return colors.green
end

--- Initial Reactor Update
reactor:updateValues()

--- Main Frame
local mainFrame = basalt.createFrame()
                            :setMonitor(peripheral.getName(monitor))
                            :setMonitorScale(0.5)
                            :setBackground(colors.black)
                            :setTheme({
                                LabelBG = colors.black,
                                LabelText = colors.white,
                                ButtonText = colors.white
                            })

    --- Title and Start/Scram Button
    local mainTitle = mainFrame:addLabel()
                                :setPosition(2,2)
                                :setText("Reactor")
                                :setFontSize(3)

    local startScramButton = mainFrame:addButton()
                                :setPosition(28,12)
                                :setSize(15,3)
                                :setText(_button.text[reactor.status])
                                :setBackground(_button.color[reactor.status])
                                :onClick(function(self)
                                    if pcall(adapter.activate) then
                                        reactor.status = true
                                    else
                                        pcall(adapter.scram)
                                        reactor.status = false
                                    end
                                    self:setText(_button.text[reactor.status])
                                    self:setBackground(_button.color[reactor.status])
                                end)

    --- Temperature
    local temperatureLabel = mainFrame:addLabel()
                                :setPosition(3,17)
                                :setText("Temperature")
                                :setFontSize(2)

    local temperatureValue = mainFrame:addLabel()
                                :setPosition(40,17)
                                :setText(string.format("%7.1fK", reactor.temperature))
                                :setForeground(temperatureColor())
                                :setFontSize(2)

    local temperatureBar = mainFrame:addProgressbar()
                                :setPosition(2,20)
                                :setSize(64,2)
                                :setProgress(reactor:temperaturePercentage())
                                :setProgressBar(temperatureColor())

    --- Damage
    local damageLabel = mainFrame:addLabel()
                                :setPosition(3,25)
                                :setText("Damage:")
                                :setFontSize(2)

    local damageValue = mainFrame:addLabel()
                                :setPosition(25,25)
                                :setText(string.format("%d%%", reactor.damage))
                                :setForeground(damageColor())
                                :setFontSize(2)

    --- Burn Rate
    local burnRateLabel = mainFrame:addLabel()
                                :setPosition(3,30)
                                :setText("Burn Rate:")
                                :setFontSize(2)

    local burnRateValue = mainFrame:addLabel()
                                :setPosition(34,30)
                                :setText(string.format("%.1f", reactor.burnRate))
                                :setFontSize(2)

    local rateBigDecrement = mainFrame:addButton()
                                :setPosition(10,33)
                                :setSize(3,1)
                                :setText("<<")
                                :onClick(function()
                                    reactor:addBurnRate(-1)
                                    burnRateValue:setText(string.format("%.1f", reactor.burnRate))
                                end)
    local rateSmallDecrement = mainFrame:addButton()
                                :setPosition(14,33)
                                :setSize(3,1)
                                :setText("<")
                                :onClick(function()
                                    reactor:addBurnRate(-0.1)
                                    burnRateValue:setText(string.format("%.1f", reactor.burnRate))
                                end)

    local rateSmallIncrement = mainFrame:addButton()
                                :setPosition(21,33)
                                :setSize(3,1)
                                :setText(">")
                                :onClick(function()
                                    reactor:addBurnRate(0.1)
                                    burnRateValue:setText(string.format("%.1f", reactor.burnRate))
                                end)
    local rateBigIncrement = mainFrame:addButton()
                                :setPosition(25,33)
                                :setSize(3,1)
                                :setText(" >>")
                                :onClick(function()
                                    reactor:addBurnRate(1)
                                    burnRateValue:setText(string.format("%.1f", reactor.burnRate))
                                end)

--- Values Frame
local valuesFrame = mainFrame:addFrame()
                            :setPosition(74,1)
                            :setSize(27,38)
                            :setTheme({
                                LabelBG = colors.gray,
                                LabelText = colors.white
                            })

    --- Coolant
    local coolantTitle = valuesFrame:addLabel()
                                :setPosition(2,2)
                                :setText("Coolant")
                                :setFontSize(2)

    local coolantName = valuesFrame:addLabel()
                                :setPosition(5,6)
                                :setText(reactor:getCoolantName())

    local coolantValue = valuesFrame:addLabel()
                                :setPosition(4,7)
                                :setText(string.format("%d/%d", reactor.coolant.amount, _maxCoolant))
                                :setForeground(valueLevelColor(reactor.coolantLevel))

    --- Fuel
    local fuelTitle = valuesFrame:addLabel()
                                :setPosition(2,10)
                                :setText("Fuel")
                                :setFontSize(2)

    local fuelName = valuesFrame:addLabel()
                                :setPosition(5,14)
                                :setText(reactor:getFuelName())

    local fuelValue = valuesFrame:addLabel()
                                :setPosition(4,15)
                                :setText(string.format("%d/%d", reactor.fuel.amount, _maxFuel))
                                :setForeground(valueLevelColor(reactor.fuelLevel))

    --- Heated Coolant
    local heatedCoolantTitle = valuesFrame:addLabel()
                                :setPosition(2,18)
                                :setText("Heated")
                                :setFontSize(2)

    local heatedCoolantTitle2 = valuesFrame:addLabel()
                                :setPosition(2,21)
                                :setText("Coolant")
                                :setFontSize(2)

    local heatedCoolantName = valuesFrame:addLabel()
                                :setPosition(5,25)
                                :setText(reactor:getHeatedCoolantName())

    local heatedCoolantValue = valuesFrame:addLabel()
                                :setPosition(4,26)
                                :setText(string.format("%d/%d", reactor.heatedCoolant.amount, _maxHeatedCoolant))
                                :setForeground(valueLevelColor(100 - reactor.heatedCoolantLevel))

    --- Waste
    local wasteTitle = valuesFrame:addLabel()
                                :setPosition(2,29)
                                :setText("Nuclear")
                                :setFontSize(2)

    local wasteTitle2 = valuesFrame:addLabel()
                                :setPosition(2,32)
                                :setText("Waste")
                                :setFontSize(2)

    local wasteName = valuesFrame:addLabel()
                                :setPosition(5,36)
                                :setText(reactor:getWasteName())

    local wasteValue = valuesFrame:addLabel()
                                :setPosition(4,37)
                                :setText(string.format("%d/%d", reactor.waste.amount, _maxWaste))
                                :setForeground(valueLevelColor(100 - reactor.wasteLevel))

--- Clears Screen if Program Terminates and adds Failsafe if a Peripheral Detaches
basalt.onEvent(function(event)
    if event == "peripheral_detach" then os.queueEvent("terminate") return end
    if event == "terminate" then
        monitor.clear()
        return true
    end
end)

--- Main Code
parallel.waitForAny(basalt.autoUpdate,
function()
    while true do
        -- Update reactor object
        reactor:updateValues()

        -- Update Values on screen
        local damageColor = damageColor() -- This variable will be used in the reactor restart
        local temperatureColor = temperatureColor() -- These 3 variables will be used in the failsafe
        local coolantLevelColor = valueLevelColor(reactor.coolantLevel)
        local wasteLevelColor = valueLevelColor(100 - reactor.wasteLevel)

        temperatureValue:setText(string.format("%7.1fK", reactor.temperature))
                :setForeground(temperatureColor)
        temperatureBar:setProgress(reactor:temperaturePercentage())
                :setProgressBar(temperatureColor)
        damageValue:setText(string.format("%d%%", reactor.damage))
                :setForeground(damageColor)
        burnRateValue:setText(string.format("%.1f", reactor.burnRate))
        coolantName:setText(reactor:getCoolantName())
        coolantValue:setText(string.format("%d/%d", reactor.coolant.amount, _maxCoolant))
                :setForeground(coolantLevelColor)
        fuelName:setText(reactor:getFuelName())
        fuelValue:setText(string.format("%d/%d", reactor.fuel.amount, _maxFuel))
                :setForeground(valueLevelColor(reactor.fuelLevel))
        heatedCoolantName:setText(reactor:getHeatedCoolantName())
        heatedCoolantValue:setText(string.format("%d/%d", reactor.heatedCoolant.amount, _maxHeatedCoolant))
                :setForeground(valueLevelColor(100 - reactor.heatedCoolantLevel))
        wasteName:setText(reactor:getWasteName())
        wasteValue:setText(string.format("%d/%d", reactor.waste.amount, _maxWaste))
                :setForeground(wasteLevelColor)

        -- Failsafe
        if reactor.status then
            if temperatureColor == colors.red or coolantLevelColor == colors.red or wasteLevelColor == colors.red then
                pcall(adapter.scram)
                reactor.status = false
                startScramButton:setText(_button.text[reactor.status])
                startScramButton:setBackground(_button.color[reactor.status])
            end

        -- Restart Reactor
        else
            if coolantLevelColor ~= colors.red and temperatureColor ~= colors.red and damageColor == colors.green then
                pcall(adapter.activate)
                reactor.status = true
                startScramButton:setText(_button.text[reactor.status])
                startScramButton:setBackground(_button.color[reactor.status])
            end
        end
    end
end)

-- while true do
--     os.startTimer(0.8)  -- Basalt works event wise, create a timer loop to update values every now and then

--     -- Update reactor object
--     reactor:updateValues()

--     -- Update Values on screen
--     coolantValue:setForeground(valueLevelColor(reactor.coolantLevel))
--     coolantValue:setText(string.format("%d/%d", reactor.coolant.amount, _maxCoolant))
--     fuelValue:setText(string.format("%d/%d", reactor.fuel.amount, _maxFuel))
--     fuelValue:setForeground(valueLevelColor(reactor.fuelLevel))
--     heatedCoolantValue:setText(string.format("%d/%d", reactor.heatedCoolant.amount, _maxHeatedCoolant))
--     heatedCoolantValue:setForeground(valueLevelColor(reactor.heatedCoolantLevel))
--     wasteValue:setText(string.format("%d/%d", reactor.waste.amount, _maxWaste))
--     wasteValue:setForeground(valueLevelColor(100 - reactor.wasteLevel))

--     -- Failsafe



--     local ev = table.pack(os.pullEventRaw())
--     basalt.update(table.unpack(ev))
-- end