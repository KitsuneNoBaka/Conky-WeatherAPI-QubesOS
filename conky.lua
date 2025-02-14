#!/usr/bin/lua

conky = {}
local cr
local widgets = require 'widgets'



function conky_main()
	if conky_window==nil or conky_window.width == 0 then return end
	local cs = cairo_xlib_surface_create(
		conky_window.display,
		conky_window.drawable,
		conky_window.visual,
		conky_window.width,
		conky_window.height
	)

	cr = cairo_create(cs)
	local width = conky_window.width
	local height = conky_window.height

	local updates=tonumber(conky_parse('${updates}'))

	widgets.main(cr)
	
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	
	cr, cs, width, height, updates = nil, nil, nil, nil, nil
	collectgarbage("collect")
	cairo_debug_reset_static_data()
end
