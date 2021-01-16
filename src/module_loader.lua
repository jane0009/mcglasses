local module_loader = {}

local util
local logging
local config
local glasses

local event_handlers = {}
local modules = {}

local function parse_module(module_list) do
  for key,value in module_list do
    if value ~= nil then
      if value.name ~= nil then

      else
        parse_module(value)  
      end
    end
  end
end

module_loader.__init = function(iutil)
  util = iutil
  logging = util.get("logging")
  glasses = util.get("driver/glasses")
  config = util.get("driver/config")

  modules = util.get_modules()
end

-- TODO look into a way to avoid this
-- e.g. a table of event -> list of modules
-- that then each module has a handler for each event (?)
-- also redefine (idk)
-- allow drivers to register both event handlers and push events

module_loader.fire = function(event, args)
  for _, mod in pairs(event_handlers) do
    for key, evt in pairs(mod) do
      if key == event then
        evt(args)
      end
    end
  end
end

-- avoid running this, double loops are costly!
module_loader.events = function()
  local events = {}
  for _, mod in pairs(event_handlers) do
    for key, evt in pairs(mod) do
      if events[key] == nil then
        events[key] = true
      end
    end
  end
  return events
end

return module_loader
