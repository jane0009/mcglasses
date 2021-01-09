--[[
  written by jane petrovna
  01/08/21
]]
local component = require("component")
local term = require("term")

local terminal = {}

local screens = {}
local gpus = {}

local debug_gpu = nil
local debug_screen = nil

local function __get_all_screen_proxies()
  local screens = component.list("screen")
  for key, _ in screens do
    screens[key] = component.proxy(key)
  end
end

local function __get_all_gpu_proxies()
  local gpus = component.list("gpu")
  for key, _ in pairs(gpus) do
    gpus[key] = component.proxy(key)
  end
end

local function __get_largest_screen()
  local biggest_size = 0
  local biggest_key = nil
  for key, value in pairs(screens) do
    local tw, th = value.getAspectRatio()

    if tw * th > biggest_size then
      biggest_size = tw * th
      biggest_key = key
    end
  end
  return biggest_key
end

local function __get_any_other_screen(screen)
  for key, value in pairs(screens) do
    if screen ~= key then
      return key
    end
  end
  return nil
end

local function __get_any_other_gpu(gpu)
  for key, value in pairs(gpus) do
    if gpu ~= key then
      return key
    end
  end
  return nil
end

local function __setup_debug_term()
  local current_gpu = term.gpu()
  local currently_active_screen = current_gpu.getScreen()
  local largest_screen = __get_largest_screen()
  if currently_active_screen == largest_screen then
    -- rebind the terminal to any other available screen
    local new_screen = __get_any_other_screen(largest_screen)
    if new_screen == nil then
      os.exit()
    end
    current_gpu.bind(new_screen, true)
  end

  -- now, set the biggest screen as our output
  local new_gpu = __get_any_other_gpu(current_gpu.address)
  if new_gpu == nil then
    os.exit()
  end
  debug_gpu = component.proxy(new_gpu)
  debug_screen = largest_screen
  debug_gpu.bind(debug_screen, true)
  debug_gpu.setBackground(0xFFFF00) -- just to make sure i have the right screen
end

local function __init()
  __get_all_gpu_proxies()
  __get_all_screen_proxies()
  __setup_debug_term()
end

__init()

-- reimplement term api but for this logging screen

local term_x = 0
local term_y = 0

local function __smooth_scroll()
  -- TODO smooth scrolling
end
terminal.write = function(msg)
  debug_gpu.set(term_x, term_y, tostring(msg))
  -- TODO implement
  -- TODO character wrap
  __smooth_scroll()
end
terminal.writeLine = function(msg)
  terminal.write(msg + "\n")

  -- manually increment where we are
  term_x = 0
  term_y = term_y + 1
  __smooth_scroll()
end
terminal.read = function()
end
terminal.getCursor = function()
  return term_x, term_y
end
terminal.setCursor = function(x, y)
  term_x = x
  term_y = y
end
terminal.clear = function()
end
terminal.clearLine = function()
end

return terminal
