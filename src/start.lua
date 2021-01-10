--VERSION 8
--[[
  written by jane petrovna
  01/08/21
]]
local util = dofile("/var/janeptrv/mcglasses/src/util.lua")
local logging = util.get("logging")

logging.info("Starting Glasses Manager")

logging.debug("TEST LOG -A-B-C-D-E-F-G-H-I-J-K-L-")

coroutine.yield()

-- we are now finished!
-- TODO figure out how to set env after crash (i.e outside of active files)
logging.info("Shutting Down")
os.setenv("MCG_RUNNING", false)
