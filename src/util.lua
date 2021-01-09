--[[
  written by jane petrovna
  01/09/21
]]
local util = {}

util.get = function(filename)
  io.stdout:write("loading " .. filename)
  return dofile("/var/janeptrv/mcglasses/src/" .. filename .. ".lua")
end
return util
