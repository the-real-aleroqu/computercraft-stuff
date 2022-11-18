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
    fuel = {},
    heatedCoolant = {},
    waste = {},
    temperature = 0.0,
}

function reactor:updateValues()
    self.coolant = adapter.getCoolant()
    self.fuel = adapter.getFuel()
    self.heatedCoolant = adapter.getHeatedCoolant()
    self.waste = adapter.getWaste()
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

--- Initial Reactor Update
reactor:updateValues()

--- Main Frame
local mainFrame = basalt.createFrame()
                        :setMonitor(peripheral.getName(monitor))
                        :setMonitorScale(0.5)
                        :setBackground(colors.black)


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
                                :setText(string.format("%d/%d", reactor.fuel.amount, _maxFuel))

    --- Heated Coolant
    local coolantTitle = valuesFrame:addLabel()
                                :setPosition(2,18)
                                :setText("Heated")
                                :setFontSize(2)
                                :setBackground(colors.gray)

                                
    local coolantTitle = valuesFrame:addLabel()
                                :setPosition(2,20)
                                :setText("Coolant")
                                :setFontSize(2)
                                :setBackground(colors.gray)

    local coolantName = valuesFrame:addLabel()
                                :setPosition(5,24)
                                :setText(reactor:getHeatedCoolantName())

    local coolantValue = valuesFrame:addLabel()
                                :setPosition(4,25)
                                :setText(string.format("%d/%d", reactor.heatedCoolant.amount, _maxHeatedCoolant))

    --- Waste
    local wasteTitle = valuesFrame:addLabel()
                                :setPosition(2,28)
                                :setText("Nuclear")
                                :setFontSize(2)
                                :setBackground(colors.gray)
                     
    local wasteTitle2 = valuesFrame:addLabel()
                                :setPosition(2,30)
                                :setText("Waste")
                                :setFontSize(2)
                                :setBackground(colors.gray)

    local wasteName = valuesFrame:addLabel()
                                :setPosition(5,34)
                                :setText(reactor:getWasteName())

    local wasteValue = valuesFrame:addLabel()
                                :setPosition(4,35)
                                :setText(string.format("%d/%d", reactor.waste.amount, _maxWaste))

basalt.autoUpdate()