local basalt = require("basalt")
local monitor = peripheral.find("monitor")
local adapter = peripheral.find("fissionReactorLogicAdapter")

if monitor == nil then error("Could not find monitor!") end
--if adapter == nil then error("Could not find reactor logic adapter!") end
-- 
-- monitor.getCoolant() ->
--     {   
--         name = "minecraft:water",
--         amount = 12932986346
--     }

local _temperatureYellow = 600  -- A bit heated
local _temperatureOrange = 1000 -- Very heated
local _temperatureRed = 1200    -- Heat levels critical
-- local _maxCoolant = monitor.getCoolantCapacity()
-- local _maxFuel = monitor.getFuelCapacity()
-- local _maxHeatedCoolant = monitor.getHeatedCoolantCapacity()
-- local _maxWaste = monitor.getWasteCapacity()

-- local reactor = {
--     --{ name = "minecraft:water" }
--     coolant = monitor.getCoolant(),
--     fuel = monitor.getFuel(),
--     -- { name = "mekanism:steam" }
--     heatedCoolant = monitor.getHeatedCoolant(),
--     waste = monitor.getWaste()
-- }

--- Main Frame
local mainFrame = basalt.createFrame()
                        :setMonitor(peripheral.getName(monitor))
                        :setMonitorScale(0.5)
                        :setBackground(colors.black)
                        :setTheme({

                            ProgressbarBG = colors.white,
                            ProgressbarActiveBG = colors.green
                        })


--- Values Frame
local valuesFrame = mainFrame:addFrame()
                            :setPosition(15,1)
                            :setSize(12,15)

local textLabel = mainFrame:addLabel()
                        :setPosition(100,1)
                        :setText("a")

--- Coolant
local coolantFrame

--- Fuel
basalt.autoUpdate()