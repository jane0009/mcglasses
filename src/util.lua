--[[
  written by jane petrovna
  01/09/21
]]
local filesystem = require("filesystem")
local util = {}

local cache = {}

util.get = function(filename)
  --coroutine.yield()
  io.stdout:write("loading " .. filename .. "\n")
  if cache[filename] then
    return cache[filename]
  else
    local load = dofile("/var/janeptrv/mcglasses/src/" .. filename .. ".lua")
    cache[filename] = load
    if load.__init ~= nil then
      load.__init(util)
    end
    return load
  end
end

util.get_modules = function()
  local modules = {}
  local module_list = filesystem.list("/var/janeptrv/mcglasses/src/modules")
  if module_list ~= nil then
    for module in module_list do
      if not filesystem.isDirectory("/var/janeptrv/mcglasses/src/modules/" .. module) then
        modules[module] = dofile("/var/janeptrv/mcglasses/src/modules/" .. module)
      end
    end
  end
  return modules
end
return util
