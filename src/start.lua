--VERSION 10
--[[
  written by jane petrovna
  01/08/21
]]
local event = require("event")
local util = dofile("/var/janeptrv/mcglasses/src/util.lua")
local logging = util.get("logging")
local modules = util.get("module_loader")

local active_events = modules.events()
local active_modules = {}

logging.info("Starting Glasses Manager")

logging.debug("TEST LOG -A-B-C-D-E-F-G-H-I-J-K-L-")

local running = true

local function get_event_info(...)
  local event = select(1, ...)
  local values = {}
  local size = select("#", ...)
  values.n = size
  for i = 2, size do
    values[i - 1] = select(i, ...)
  end
  return event, values
end

while running do
  local event, values = get_event_info(event.pull())
  if active_events[event] == true then
    modules.fire(event, values)
  elseif event == "mcg_exit" or event == "interrupted" then
    running = false
    os.setenv("MCG_RUNNING", false)
    logging.debug("shut down for reason " .. values[1])
  else
    logging.debug("got unregistered event " .. event)
  end
end

-- we are now finished!
-- TODO figure out how to set env after crash (i.e outside of active files)
logging.info("Shutting Down")
