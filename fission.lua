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
local reactor = {
-- adapter.getCoolant() ->
--      {
--          name = "minecraft:water",
--          amount = 119523556
--      }
    status = false,
    coolant = {},
    coolantLevel = 0,
    fuel = {},
    heatedCoolant = {},
    waste = {},
    temperature = 0.0,
    burnRate = 0.0
}

function reactor:updateValues()
    self.status = adapter.getStatus()
    self.coolant = adapter.getCoolant()
    self.coolantLevel = math.floor(adapter.getCoolantFilledPercentage() * 100)
    self.fuel = adapter.getFuel()
    self.fuelLevel = math.floor(adapter.getFuelFilledPercentage() * 100)
    self.heatedCoolant = adapter.getHeatedCoolant()
    self.heatedCoolantLevel = math.floor(adapter.getHeatedCoolantFilledPercentage() * 100)
    self.waste = adapter.getWaste()
    self.wasteLevel = math.floor(adapter.getWasteFilledPercentage() * 100)
    self.temperature = adapter.getTemperature()
    self.burnRate = adapter.getBurnRate()
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

function reactor:temperaturePercentage()
    return math.floor(180000 / self.temperature)    -- Returns percentage for the temperature bar (0-100)
end

local function temperatureColor()
    if reactor.temperature >= _temperatureRed then return colors.red end
    if reactor.temperature >= _temperatureOrange then return colors.orange end
    if reactor.temperature >= _temperatureYellow then return colors.yellow end
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
                                :setPosition(3,11)
                                :setSize(14,5)
                                :setText(_button.text[reactor.status])
                                :setBackground(_button.color[reactor.status])
                                :setBorder(colors.white)
                                :onClick(function(self)
                                    if reactor.status == false then
                                        adapter.activate()
                                        reactor.status = true
                                    else
                                        adapter.scram()
                                        reactor.status = false
                                    end
                                    self:setText(_button.text[reactor.status])
                                    self:setBackground(_button.color[reactor.status])
                                end)

    --- Temperature
    local temperatureLabel = mainFrame:addLabel()
                                :setPosition(3,17)
                                :setText("Temperature:")
                                :setFontSize(2)
    
    local temperatureValue = mainFrame:addLabel()
                                :setPosition(48,17)
                                :setText(string.format("%.1fK", reactor.temperature))
                                :setForeground(temperatureColor())
                                :setFontSize(2)

    local temperatureBar = mainFrame:addProgressbar()
                                :setPosition(2,22)
                                :setSize(64,2)
                                :setProgress(reactor:temperaturePercentage())
                                :setProgressBar(temperatureColor())

    --- Burn Rate
    local burnRateTitle = mainFrame:addLabel()
                                :setPosition(2,25)

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


--- Main Code

basalt.onEvent(function(event)
    print(event)
    if (event == "terminate") then
        return false
    end
end)

while true do
    os.startTimer(0.8)  -- Basalt works event wise, create a timer loop to update values every now and then

    -- Update reactor object
    reactor:updateValues()

    -- Update Values on screen
    coolantValue:setForeground(valueLevelColor(reactor.coolantLevel))
    coolantValue:setText(string.format("%d/%d", reactor.coolant.amount, _maxCoolant))
    fuelValue:setText(string.format("%d/%d", reactor.fuel.amount, _maxFuel))
    fuelValue:setForeground(valueLevelColor(reactor.fuelLevel))
    heatedCoolantValue:setText(string.format("%d/%d", reactor.heatedCoolant.amount, _maxHeatedCoolant))
    heatedCoolantValue:setForeground(valueLevelColor(reactor.heatedCoolantLevel))
    wasteValue:setText(string.format("%d/%d", reactor.waste.amount, _maxWaste))
    wasteValue:setForeground(valueLevelColor(100 - reactor.wasteLevel))

    -- Failsafe



    local ev = table.pack(os.pullEventRaw())
    basalt.update(table.unpack(ev))
end