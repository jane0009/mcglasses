--[[
  written by jane petrovna
  01/15/21
]]

--TODO improve syntax

local mod = {}

local function handle_chat_message(args)
  if mod.logging then
    mod.logging.debug("chat message recv'd" .. args[0])
  end
  print(args)
end

mod = {
  name="test",
  pos = {
    x = 50,
    y = 50
  },
  elements = {},
  events = {
    chat_message = handle_chat_message
  }
}

return mod