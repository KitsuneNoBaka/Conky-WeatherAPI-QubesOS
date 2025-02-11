--------------------
-- Conky LUA library
--------------------

local socket = require 'socket'

local lualib= {}

--[[
Convert hexadecimal colors to rgba values

e.g. cairo_set_source_rgba(cr, rgbToRgba(0xff7f00, 0.8))
]]
function lualib.rgbToRgba(color, alpha)
  return ((color / 0x10000) % 0x100) / 255.0,
  ((color / 0x100) % 0x100) / 255.0,
  (color % 0x100) / 255.0,
  alpha
end

-- run shell command and capture it's output
function os.capture(cmd)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	return s
end

-- time epoch
function lualib.mtime()
	return socket.gettime()
end

return lualib
