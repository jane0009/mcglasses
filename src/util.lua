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

util.get_modules = function(subdir)
  local modules = {}
  local module_list
  if subdir ~= nil then
    module_list = filesystem.list("/var/janeptrv/mcglasses/src/modules/" .. subdir)
  else
    module_list = filesystem.list("/var/janeptrv/mcglasses/src/modules")
  end
  if module_list ~= nil then
    for module in module_list do
      if filesystem.isDirectory("/var/janeptrv/mcglasses/src/modules/" .. module) then
        modules[module] = util.get_modules(module)
      else
        modules[module] = dofile("/var/janeptrv/mcglasses/src/modules/" .. module)
        modules[module].logging = util.get("logging")
      end
    end
  end
  return modules
end
return util
