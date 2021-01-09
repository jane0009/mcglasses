--[[
  written by jane petrovna
  01/09/21
]]
local util = {}

local cache = {}

util.get = function(filename)
  --coroutine.yield()
  io.stdout:write("loading " .. filename)
  if cache[filename] then
    return cache[filename]
  else
    local load = dofile("/var/janeptrv/mcglasses/src/" .. filename .. ".lua")
    cache[filename] = load
    return load
  end
end
return util
