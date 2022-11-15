local basalt = require("basalt")
local monitor = peripheral.find("monitor")
local reactor = peripheral.find("fissionReactorLogicAdapter")
if monitor == nil then error("Could not find monitor!") end
if reactor == nil then error("Could not find reactor logic adapter!") end

--- Main Frame
local mainFrame = basalt.createFrame()
                        :setMonitor(peripheral.getName(monitor))
                        :setMonitorScale(0.5)
                        :setBackground(colors.black)
                        :setTheme({

                        })

mainFrame:addProgressBar()
            :setProgress(50)

basalt.autoUpdate()