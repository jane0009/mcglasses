local module_loader = {}

local util
local config
local glasses

module_loader.__init = function(iutil)
  util = iutil
  glasses = util.get("driver/glasses")
  config = util.get("driver/config")
end

return module_loader
