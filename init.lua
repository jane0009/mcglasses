--[[
  written by jane petrovna
  01/08/21

  this file should not change unless the repo name itself changes,
  as it only downloads the rest of the code necessary.
]]
local filesystem = require("filesystem")
local shell = require("shell")

-- bootstrap using wget and gitrepo
if not filesystem.exists("/usr/bin/gitrepo.lua") then
  if filesystem.exists("/bin/wget.lua") then
    shell.execute(
      "wget https://raw.githubusercontent.com/OpenPrograms/Gopher-Programs/master/gitrepo.lua /usr/bin/gitrepo.lua"
    )
  else
    print("cannot find wget, and gitrepo is not installed")
    os.exit()
  end
end

-- download required files
if not filesystem.exists("/var/janeptrv") then
  shell.execute("gitrepo janeptrv/mcglasses /var/janeptrv/mcglasses")
end

-- insert ourselves into startup
if not filesystem.exists("/boot/10000_mcglasses.lua") then
  print("adding ourselves to startup...")
  local file = filesystem.open("/boot/10000_mcglasses.lua", "w")
  file:write('local shell = require("shell")\n')
  file:write('shell.execute("/var/janeptrv/mcglasses/init.lua")')
  file:close()
end

-- now start the actual program

print("starting glasses control...")

local is_running = os.getenv("MCG_RUNNING")
if is_running ~= nil and is_running ~= false then
  print("glasses control is already running!")
  os.exit()
end

local thread = require("thread")
local process = thread.create(os.execute, "/tmp/janeptrv/mcglasses/src/start.lua")
process:detach() -- bye bye! into the background you go!
os.setenv("MCG_RUNNING", true)
