--[[
  written by jane petrovna
  01/08/21
]]
local filesystem = require("filesystem")
local util
local terminal
local glasses
local config

local logging = {}

-- 0 = ERROR
-- 1 = WARN
-- 2 = INFO
-- 3 = DEBUG

logging.set_log_level = function(level)
  local l = tonumber(level)
  if l ~= nil and l >= 0 and l <= 3 then
    logging.log_level = l
  end
end

local log_file
local file_enabled
local terminal_enabled
local glasses_enabled

local function __create_message(msg, source)
  if msg == nil then
    msg = "nil"
  end
  --io.stdout:write(msg .. "\n")
  if terminal_enabled and source ~= "terminal" then
    terminal.writeLine(msg)
  end
  if glasses_enabled and source ~= "glasses" then
    glasses.log(msg)
  end
  if file_enabled then
    if filesystem.exists(log_file) then
      local file = filesystem.open(log_file, "a")
      file:write(msg .. "\n")
      file:close()
    else
      if not filesystem.isDirectory(filesystem.path(log_file)) then
        filesystem.makeDirectory(filesystem.path(log_file))
      end
      local file = filesystem.open(log_file, "w")
      file:write("LOG BEGINS\n")
      file:write(msg .. "\n")
      file:close()
    end
  end
end

logging.error = function(msg, source)
  if logging.log_level >= 0 then
    __create_message(msg, source)
  end
end

logging.warn = function(msg, source)
  if logging.log_level >= 1 then
    __create_message(msg, source)
  end
end

logging.info = function(msg, source)
  if logging.log_level >= 2 then
    __create_message(msg, source)
  end
end

logging.debug = function(msg, source)
  if logging.log_level >= 3 then
    __create_message(msg, source)
  end
end

logging.__init = function(iutil)
  util = iutil
  terminal = util.get("driver/terminal")
  glasses = util.get("driver/glasses")
  config = util.get("driver/config")

  terminal.inject_logging(logging)
  glasses.inject_logging(logging)

  -- load config
  log_file = config.get_value("log_file", "/var/log/mcg.log")
  file_enabled = config.get_value("log_to_file", "true") == "true"
  terminal_enabled = config.get_value("log_to_terminal", "true") == "true"
  glasses_enabled = config.get_value("log_to_glasses", "true") == "true"
  logging.log_level = tonumber(config.get_value("log_level", "2"))
end
return logging
