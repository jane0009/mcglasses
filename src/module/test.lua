local function handle_chat_message(event)
end

return {
  pos = {
    x = 50,
    y = 50
  },
  elements = {},
  events = {
    chat_message = handle_chat_message
  }
}
