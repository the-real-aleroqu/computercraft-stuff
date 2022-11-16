local basalt = require("basalt")
local monitor = peripheral.find("monitor")
local adapter = peripheral.find("fissionReactorLogicAdapter")

if monitor == nil then error("Could not find monitor!") end
if adapter == nil then error("Could not find reactor logic adapter!") end

--- Temperature Levels
local _temperatureYellow = 600  -- Slightly Hot
local _temperatureOrange = 1000 -- Very Hot.
local _temperatureRed = 1200    -- Hotness Levels Critical (whew)

--- Internal Max Values
local _maxCoolant = adapter.getCoolantCapacity()
local _maxFuel = adapter.getFuelCapacity()
local _maxHeatedCoolant = adapter.getHeatedCoolantCapacity()
local _maxWaste = adapter.getWasteCapacity()

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
    temperature = 0,
}

function reactor:updateValues()
    self.coolant = adapter.getCoolant()
    self.fuel = adapter.getFuel()
    self.heatedCoolant = adapter.getHeatedCoolant()
    self.waste = adapter.getWaste()
    self.temperature = adapter.getTemperature()
end

--- Main Frame
local mainFrame = basalt.createFrame()
                        :setMonitor(peripheral.getName(monitor))
                        :setMonitorScale(0.5)
                        :setBackgroundColor(colors.black)


--- Values Frame
local valuesFrame = mainFrame:addFrame()
                            :setPosition(49,1)
                            :setSize(50,38)


basalt.autoUpdate()