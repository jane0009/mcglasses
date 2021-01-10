--[[
  written by jane petrovna
  01/08/21
]]
local component = require("component")
local term = require("term")

local terminal = {}
local logging

local screens = {}
local gpus = {}

local debug_gpu = nil
local debug_screen = nil

local function __get_all_screen_proxies()
  local screen_list = component.list("screen")
  for key, _ in screen_list do
    screens[key] = component.proxy(key)
  end
end

local function __get_all_gpu_proxies()
  local gpu_list = component.list("gpu")
  for key, _ in pairs(gpu_list) do
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
  debug_gpu.setBackground(0x2F2F2F) -- just to make sure i have the right screen
  local w, h = debug_gpu.getResolution()
  debug_gpu.setResolution(math.floor(w/2), math.floor(h/2))
  debug_gpu.fill(1, 1, w, h, " ") -- clear the screen
end

local function __init()
  __get_all_gpu_proxies()
  __get_all_screen_proxies()
  __setup_debug_term()
end

__init()

-- reimplement term api but for this logging screen

local term_x = 1
local term_y = 1
local width, height = debug_gpu.getResolution()

local function __smooth_scroll()
  if term_y >= height - 1 then
    for i = 1, height do
      debug_gpu.copy(1, i + 1, width, 1, 1, i)
    end
    term_y = term_y - 1
  end
end
terminal.write = function(msg)
  debug_gpu.set(term_x, term_y, tostring(msg))
  -- TODO character wrap
  __smooth_scroll()
end
terminal.writeLine = function(msg)
  terminal.write(msg)

  -- manually increment where we are
  term_x = 1
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
  term_x = 1
  term_y = 1
  debug_gpu.fill(1, 1, width, height, " ")
end
terminal.clearLine = function()
  term_x = 1
debug_gpu.fill(1, 1, width, 1, " ")
end

terminal.inject_logging = function(log)
  logging = log
end

return terminal
