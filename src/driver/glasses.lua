--[[
  written by jane petrovna
  01/09/21
]]
local component = require("component")
local util
local config
local logging

local glasses = {}
glasses.widgets = {}

local max_log_lines
local render_resolution_x
local render_resolution_y
local log_pos
local font
local font_size
local log_limit
local connected_users

local current_log = {}

local function __init()
  local all_glasses = component.list("glasses")
  local next, table = pairs(all_glasses)
  local key, _ = next(table)
  glasses.bound_glasses = component.proxy(key)

  -- set up glasses
  glasses.bound_glasses.setRenderResolution("", render_resolution_x, render_resolution_y)
  glasses.bound_glasses.setRenderPosition("relative")
  glasses.bound_glasses.removeAll()
end

local log_positions = {
  upper_right = {
    x = 83,
    y = 2
  },
  upper_left = {
    x = 2,
    y = 2
  },
  lower_right = {
    x = 83,
    y = 90
  },
  lower_left = {
    x = 2,
    y = 90
  }
}

glasses.draw = function(x, y, text, bg, fg)
  local length = string.len(text)
end

local current_log_size = 0

local function __update_log(user)
  --for key, value in pairs(glasses.widgets) do
  --  if logging ~= nil then
  --    logging.debug(key, "glasses")
  --    logging.debug(tostring(value), "glasses")
  --  end
  --end
  local x = log_positions[log_pos].x
  local y = log_positions[log_pos].y

  --logging.debug("xy " .. x .. " " .. y, "glasses")
  if not glasses.widgets[user] then
    glasses.widgets[user] = {}
  end
  if not glasses.widgets[user]["log_box"] then
    glasses.widgets[user]["log_box"] = glasses.bound_glasses.addBox2D()
    glasses.widgets[user]["log_box"].setOwner(user)
    glasses.widgets[user]["log_box"].addTranslation((x / 100) * render_resolution_x, (y / 100) * render_resolution_y, 0)
    glasses.widgets[user]["log_box"].setSize(font_size * 30, max_log_lines * (font_size + 3))
    -- because gradients
    glasses.widgets[user]["log_box"].addColor(0.01, 0.01, 0.01, 0.8)
    glasses.widgets[user]["log_box"].addColor(0.01, 0.01, 0.01, 0.8)
  end
  for i = 1, current_log_size do
    if not glasses.widgets[user]["log_text_" .. i] then
      glasses.widgets[user]["log_text_" .. i] = glasses.bound_glasses.addText2D()
      glasses.widgets[user]["log_text_" .. i].setOwner(user)
      glasses.widgets[user]["log_text_" .. i].addTranslation(
        (x / 100) * render_resolution_x,
        (y / 100) * render_resolution_y,
        0
      )
      glasses.widgets[user]["log_text_" .. i].addTranslation(0, (i - 1) * (font_size + 3), 0)
      glasses.widgets[user]["log_text_" .. i].setFont(font)
      glasses.widgets[user]["log_text_" .. i].setFontSize(font_size)
    end
    glasses.widgets[user]["log_text_" .. i].setText(current_log[i])
  end
end

glasses.log = function(msg, user)
  if user ~= nil then
    glasses.__log(msg, user)
  else
    if connected_users == nil then
      connected_users = glasses.bound_glasses.getConnectedPlayers()
    end
    for _, value in ipairs(connected_users) do
      glasses.__log(msg, value[1]) -- value[1] is always the username
    end
  end
end
glasses.__log = function(msg, user)
  if current_log[user] == nil then
    current_log[user] = {}
  end
  local idx = current_log_size
  if idx + 1 > max_log_lines then
    for i = 1, current_log_size - 1 do
      current_log[user][i] = current_log[user][i + 1]
    end
  else
    current_log_size = current_log_size + 1
  end
  if string.len(msg) > 30 then
    local cur_msg = string.sub(msg, 1, log_limit)
    local future_msg = string.sub(msg, log_limit + 1, string.len(msg))
    current_log[user][current_log_size] = cur_msg
    glasses.__log(future_msg, user)
  else
    current_log[user][current_log_size] = msg
  end
  __update_log(user)
end

glasses.addElement = function(element, name, user)
  if not glasses.widgets[user] then
    glasses.widgets[user] = {}
  end
  if not glasses.widgets[user][name] then
    glasses.widgets[user][name] = element()
    glasses.widgets[user][name].setOwner(user)
  end
  return glasses.widgets[user][name]
end

glasses.inject_logging = function(log)
  logging = log
end
glasses.__init = function(iutil)
  util = iutil
  config = util.get("driver/config")

  max_log_lines = tonumber(config.get_value("glasses_log_lines", "5"))
  render_resolution_x = tonumber(config.get_value("glasses_resolution_x", "1920"))
  render_resolution_y = tonumber(config.get_value("glasses_resolution_y", "1080"))
  log_pos = config.get_value("glasses_log_pos", "upper_right")
  font = config.get_value("glasses_font", "Monospaced.bold")
  font_size = tonumber(config.get_value("glasses_font_size", "18"))
  log_limit = tonumber(config.get_value("glasses_log_width_limit", "30"))

  __init()

  glasses.bound_glasses.size_x = render_resolution_x
  glasses.bound_glasses.size_y = render_resolution_y
end
return glasses
