--VERSION 3
--[[
  written by jane petrovna
  01/08/21
]]
local util = dofile("/var/janeptrv/mcglasses/src/util.lua")
local logging = util.get("logging")

logging.info("Starting Glasses Manager")

-- we are now finished!
logging.info("Shutting Down")
os.setenv("MCG_RUNNING", false)
