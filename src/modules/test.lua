--[[
  written by jane petrovna
  01/15/21
]]
--TODO improve syntax

local mod = {}
local widget

local function handle_chat_message(args)
  if mod.logging then
    mod.logging.debug("chat message recv'd" .. args[0])
  end
  if widget then
    widget.setText(tostring(args[0]))
  end
end

local function handle_test_widget(w)
  --widget.addScale()
  widget.setFont("Monospaced.bold")
  widget.setFontSize(16)
  widget = w
end

mod = {
  name = "test",
  elements = {
    {
      pos = {
        type = "absolute",
        x = 50,
        y = 50
      },
      type = "Text2D",
      handler = handle_test_widget
    }
  },
  events = {
    chat_message = handle_chat_message
  }
}

return mod
