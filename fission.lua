local basalt = require("basalt")
local monitor = peripheral.find("monitor")
local adapter = peripheral.find("fissionReactorLogicAdapter")

if monitor == nil then error("Could not find monitor!") end
if adapter == nil then error("Could not find reactor logic adapter!") end

local reactor = {
    coolant = { name = "minecraft:water"}
}

function reactor:getCoolantColor()
    if coolant.name == "minecraft:water" then return colors.blue end
    if coolant.name == "mekanism:sodium" then return colors.lightGray end
    return colors.white -- Empty
end

--- Main Frame
local mainFrame = basalt.createFrame()
                        :setMonitor(peripheral.getName(monitor))
                        :setMonitorScale(0.5)
                        :setBackground(colors.black)
                        :setTheme({
                            ProgressbarBG = colors.white,
                            ProgressbarActiveBG = colors.green
                        })

mainFrame:addProgressBar()
            :setProgress(50)

--- Coolant
local coolantBar = mainFrame:addProgressBar()
            :setDirection(3) -- Bottom to Top
            :setProgress(50)
            :setProgressBar(reactor:getCoolantColor()) -- Change color to coolant type


basalt.autoUpdate()