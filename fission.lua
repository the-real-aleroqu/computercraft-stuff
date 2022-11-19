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

--- Reactor object (internal values, object methods)
local reactor = {
-- adapter.getCoolant() ->
--      {
--          name = "minecraft:water",
--          amount = 119523556
--      }
    coolant = {},
    coolantLevel = 0,
    fuel = {},
    heatedCoolant = {},
    waste = {},
    temperature = 0.0,
}

function reactor:updateValues()
    self.coolant = adapter.getCoolant()
    self.coolantLevel = math.floor(adapter.getCoolantFilledPercentage() * 100)
    self.fuel = adapter.getFuel()
    self.fuelLevel = math.floor(adapter.getFuelFilledPercentage() * 100)
    self.heatedCoolant = adapter.getHeatedCoolant()
    self.heatedCoolantLevel = math.floor(adapter.getHeatedCoolantFilledPercentage() * 100)
    self.waste = adapter.getWaste()
    self.wasteLevel = math.floor(adapter.getWasteFilledPercentage() * 100)
    self.temperature = adapter.getTemperature()
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

function valueLevelColor(color)
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

    --- Title
    local mainTitle = mainFrame:addLabel()                  
                        :setPosition(2,2)
                        :setText("Reactor")
                        :setFontSize(3)



--- Values Frame
local valuesFrame = mainFrame:addFrame()
                            :setPosition(69,1)
                            :setSize(32,38)
                            :setTheme({
                                LabelGB = colors.gray,
                                LabelText = colors.white
                            })

    --- Coolant
    local coolantTitle = valuesFrame:addLabel()
                                :setPosition(2,2)
                                :setText("Coolant")
                                :setFontSize(2)
                                :setBackground(colors.gray) -- Rezising resets background color... for some reason

    local coolantName = valuesFrame:addLabel()
                                :setPosition(5,6)
                                :setText(reactor:getCoolantName())

    local coolantValue = valuesFrame:addLabel()
                                :setPosition(4,7)
                                :setForeground(valueLevelColor(reactor.coolantLevel))
                                :setText(string.format("%d/%d", reactor.coolant.amount, _maxCoolant))

    --- Fuel
    local coolantTitle = valuesFrame:addLabel()
                                :setPosition(2,10)
                                :setText("Fuel")
                                :setFontSize(2)
                                :setBackground(colors.gray)

    local coolantName = valuesFrame:addLabel()
                                :setPosition(5,14)
                                :setText(reactor:getFuelName())

    local coolantValue = valuesFrame:addLabel()
                                :setPosition(4,15)
                                :setForeground(valueLevelColor(reactor.fuelLevel))
                                :setText(string.format("%d/%d", reactor.fuel.amount, _maxFuel))

    --- Heated Coolant
    local heatedCoolantTitle = valuesFrame:addLabel()
                                :setPosition(2,18)
                                :setText("Heated")
                                :setFontSize(2)
                                :setBackground(colors.gray)

                                
    local heatedCoolantTitle2 = valuesFrame:addLabel()
                                :setPosition(2,21)
                                :setText("Coolant")
                                :setFontSize(2)
                                :setBackground(colors.gray)

    local heatedCoolantName = valuesFrame:addLabel()
                                :setPosition(5,25)
                                :setText(reactor:getHeatedCoolantName())

    local heatedCoolantValue = valuesFrame:addLabel()
                                :setPosition(4,26)
                                :setForeground(valueLevelColor(reactor.heatedCoolantLevel))
                                :setText(string.format("%d/%d", reactor.heatedCoolant.amount, _maxHeatedCoolant))

    --- Waste
    local wasteTitle = valuesFrame:addLabel()
                                :setPosition(2,29)
                                :setText("Nuclear")
                                :setFontSize(2)
                                :setBackground(colors.gray)
                     
    local wasteTitle2 = valuesFrame:addLabel()
                                :setPosition(2,32)
                                :setText("Waste")
                                :setFontSize(2)
                                :setBackground(colors.gray)

    local wasteName = valuesFrame:addLabel()
                                :setPosition(5,36)
                                :setText(reactor:getWasteName())

    local wasteValue = valuesFrame:addLabel()
                                :setPosition(4,37)
                                :setForeground(valueLevelColor(100 - reactor.wasteLevel))
                                :setText(string.format("%d/%d", reactor.waste.amount, _maxWaste))

while true do
    reactor:updateValues()
    basalt.update()
end