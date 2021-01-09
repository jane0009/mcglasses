--[[
  written by jane petrovna
  01/08/21
]]
local terminal = require("./terminal")

local logging = {}

-- TODO init from config
-- 0 = ERROR
-- 1 = WARN
-- 2 = INFO
-- 3 = DEBUG
logging.log_level = 2

logging.set_log_level = function(level)
  local l = tonumber(level)
  if l ~= nil and l >= 0 and l <= 3 then
    logging.log_level = l
  end
end

-- TODO replace with config
local terminal_enabled = true
local glasses_enabled = true

local function __create_message(msg)
  if terminal_enabled then
    terminal.writeLine(msg)
  end
end

logging.error = function(msg)
  if logging.log_level >= 0 then
    __create_message(msg)
  end
end

logging.warn = function(msg)
  if logging.log_level >= 1 then
    __create_message(msg)
  end
end

logging.info = function(msg)
  if logging.log_level >= 2 then
    __create_message(msg)
  end
end

logging.debug = function(msg)
  if logging.log_level >= 3 then
    __create_message(msg)
  end
end

return logging
