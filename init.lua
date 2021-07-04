local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Citrix Viewer Spoon"
obj.version = "1.0"
obj.author = "Bruno Navert"
obj.license = "MIT"
obj.homepage = "https://github.com/brunon/CitrixViewer.spoon"

-- PID of Citrix Viewer app
obj.citrixPid = nil
obj.callbackFunction = nil

local function citrixStarted(pid)
  obj.citrixPid = pid
  if (obj.callbackFunction ~= nil) then obj.callbackFunction("citrixStarted") end
end

local function citrixStopped()
  obj.citrixPid = nil
  if (obj.callbackFunction ~= nil) then obj.callbackFunction("citrixStopped") end
end

local citrixAppWatcher = function(name, event, application)
  local isCitrixPid = (application ~= nil) and (application:pid() == obj.citrixPid)

  -- Citrix shut down
  if isCitrixPid and (event == hs.application.watcher.terminated)
  then
    citrixStopped()

  elseif (name == 'Citrix Viewer') and (obj.citrixPid == nil)
  then
    citrixStarted(application:pid())
  end
end

obj.citrixWatcher = hs.application.watcher.new(citrixAppWatcher)

function obj:start()
  citrixApp = hs.application.find('Citrix Viewer')
  if (citrixApp ~= nil) then
    citrixStarted(citrixApp:pid())
  end
  obj.citrixWatcher:start()
end

function obj:stop()
  obj.citrixWatcher:stop()
end

--- CitrixViewer:setStatusCallback(func)
--- Method
--- Registers a function to be called whenever Citrix Viewer starts / stops
---
--- Parameters:
--- * func - A function in the form "function(event)" where "event" is a string describing the state change event
function obj:setStatusCallback(func)
  hs.printf("callback=%s",func)
  obj.callbackFunction = func
end

return obj
