local basalt = require("basalt")
local monitor = peripheral.find("monitor")

local mainFrame = basalt.createFrame()
                        :setMonitor(peripheral.getName(monitor))
                        :setMonitorScale(0.5)





basalt.autoUpdate()