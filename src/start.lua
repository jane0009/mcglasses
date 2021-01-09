--VERSION 2
--[[
  written by jane petrovna
  01/08/21
]]
local logging = dofile("./logging.lua")

logging.info("Starting Glasses Manager")

-- we are now finished!
logging.info("Shutting Down")
os.setenv("MCG_RUNNING", false)
