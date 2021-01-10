--[[
  written by jane petrovna
  01/09/21
]]
local component = require("component")
local util = dofile("/var/janeptrv/mcglasses/src/util.lua")
local config = util.get("driver/config")
local logging

local glasses = {}
glasses.widgets = {}

local max_log_lines = tonumber(config.get_value("glasses_log_lines", "5"))
local render_resolution_x = tonumber(config.get_value("glasses_resolution_x", "1080"))
local render_resolution_y = tonumber(config.get_value("glasses_resolution_y", "1920"))
local log_pos = config.get_value("glasses_log_pos", "upper_right")
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
    x = 90,
    y = 5
  },
  upper_left = {
    x = 5,
    y = 5
  },
  lower_right = {
    x = 90,
    y = 90
  },
  lower_left = {
    x = 5,
    y = 90
  }
}

glasses.draw = function(x, y, text, bg, fg)
  local length = string.len(text)
end

local current_log_size = 0

local function __update_log()
  for key, value in pairs(glasses.widgets) do
    if logging ~= nil then
      logging.debug(key, "glasses")
      logging.debug(tostring(value), "glasses")
    end
  end
  local x = log_positions[log_pos].x
  local y = log_positions[log_pos].y

  logging.debug("xy " .. x .. " " .. y, "glasses")
  if not glasses.widgets["log_box"] then
    glasses.widgets["log_box"] = glasses.bound_glasses.addBox2D()
    glasses.widgets["log_box"].addAutoTranslation(x, y)
    glasses.widgets["log_box"].setSize(30 * 15, max_log_lines * 30)
    glasses.widgets["log_box"].addColor(0.1, 0.1, 0.1, 0.5)
  end
  for i = 1, current_log_size do
    if not glasses.widgets["log_text_" .. i] then
      glasses.widgets["log_text_" .. i] = glasses.bound_glasses.addText2D()
      glasses.widgets["log_text_" .. i].addAutoTranslation(x, y)
      glasses.widgets["log_text_" .. i].addTranslation(0, i * 30, 0)
    end
    glasses.widgets["log_text_" .. i].setText(current_log[i])
  end
end

glasses.log = function(msg)
  local idx = current_log_size
  if idx + 1 > max_log_lines then
    for i = 1, current_log_size - 1 do
      current_log[i] = current_log[i + 1]
    end
  else
    current_log_size = current_log_size + 1
  end
  current_log[current_log_size] = msg
  __update_log()
end

__init()

glasses.inject_logging = function(log)
  logging = log
end
return glasses
