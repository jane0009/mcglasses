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

local function redownload()
  shell.execute("rm -rf /var/janeptrv")
  shell.execute("gitrepo janeptrv/mcglasses /var/janeptrv/mcglasses")
end

local function get_version(fstring)
  local first_newline = string.find(fstring, "\n")
  local version = tonumber(string.sub(fstring, 11, first_newline))
  return version
end

-- download required files
if not filesystem.exists("/var/janeptrv") then
  redownload()
end

-- check main program version
if not filesystem.exists("/var/janeptrv/mcglasses/src/start.lua") then
  redownload()
end
local file = filesystem.open("/var/janeptrv/mcglasses/src/start.lua")
local fstring = file:read(20) -- idk just some really long number
file:close()
if fstring == nil then
  redownload()
else
  local version = get_version(fstring)

  local internet = require("internet")
  local result, response =
    pcall(
    internet.request,
    "https://raw.githubusercontent.com/janeptrv/mcglasses/master/src/start.lua",
    nil,
    {["user-agent"] = "MCG/OpenComputers"}
  )
  if result then
    local fremotestring = response[1]
    if fremotestring ~= nil then
      local internet_version = get_version(fremotestring)
      if internet_version > version then
        redownload()
      end
    end
  end
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
