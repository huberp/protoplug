require "include/protoplug"

--Welcome to Lua Protoplug effect (version 1.4.0)
script.ffiLoad("libwinpthread-1")
package.path  = (package.path..";"..protoplug_dir.."\\extra\\luapower\\?.lua")
print("PATH:  "..package.path)
package.cpath = (package.cpath)..";"..protoplug_dir.."\\lib\\?.dll"
print("CPATH: "..package.cpath)

io.stdout:setvbuf'no'

local ffi = require'ffi'
local thread = require'thread'
local pthread = require'pthread'
local luastate = require'luastate'
local time = require'time'
local glue = require'glue'

local function test_events()
	local event = thread.event()
	local t1 = thread.new(function(event)
			local time = require'time'
			local i=0
			while i<10 do
				print'set'
				event:set()
				time.sleep(0.5)
				print'clear'
				event:clear()
				time.sleep(1)
				i=i+1
			end
		end, event)

	local t2 = thread.new(function(event)
			local time = require'time'
			local i =0
			while i<10 do
				event:wait()
				print'!'
				time.sleep(0.5)
				i=i+1
			end
		end, event)

	--t1:join()
	--t2:join()
end

test_events()