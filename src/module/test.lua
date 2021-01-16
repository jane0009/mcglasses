local mod = {
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

local function handle_chat_message(args)
  if mod.logging then
    mod.logging.debug("chat message recv'd" .. args[0])
  end
  print(args)
end

return mod