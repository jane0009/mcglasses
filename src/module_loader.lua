local module_loader = {}

local util
local logging
local config
local glasses

local event_handlers = {}
local modules = {}

local element_types

local function parse_modules(module_list)
  if type(module_list ~= "table") then
    return
  end
  for key, value in pairs(module_list) do
    logging.debug("loading module " .. key, "loader")
    if value ~= nil then
      if value.name ~= nil then
        -- todo also elements
        if value.elements ~= nil and glasses ~= nil then
          for _, element in ipairs(value.elements) do
            local widget
            if element_types ~= nil and type(element_types[element.type]) == "function" then
              widget = element_types[element.type]()
              if element.pos ~= nil then
                if element.pos.type == "absolute" then
                  widget.addTranslation(element.pos.x, element.pos.y, 0)
                elseif element.pos.type == "relative" then
                  widget.addTranslation(
                    glasses.bound_glasses.size_x * (element.pos.x / 100),
                    glasses.bound_glasses.size_y * (element.pos.y / 100),
                    0
                  )
                end
              end
            end
          end
        end
        if value.events ~= nil then
          for key, handler in pairs(value.events) do
            if not event_handlers[key] then
              event_handlers[key] = {}
              event_handlers[key].n = 0
            end
            event_handlers[key][event_handlers[key].n + 1] = handler
            event_handlers[key].n = event_handlers[key].n + 1
          end
        end
        if value.__init ~= nil and type(value.__init) == "function" then
          value.__init(util)
        end
      else
        parse_modules(value)
      end
    end
  end
end

module_loader.__init = function(iutil)
  util = iutil
  logging = util.get("logging")
  glasses = util.get("driver/glasses")
  config = util.get("driver/config")

  element_types = {
    Text2D = glasses.bound_glasses.addText2D,
    Box2D = glasses.bound_glasses.addBox2D
  }

  modules = util.get_modules()
  parse_modules(modules)
end

-- TODO look into a way to avoid this
-- e.g. a table of event -> list of modules
-- that then each module has a handler for each event (?)
-- also redefine (idk)
-- allow drivers to register both event handlers and push events

module_loader.fire = function(event, args)
  if event_handlers[event] then
    for _, value in ipairs(event_handlers[event]) do
      value(args)
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
