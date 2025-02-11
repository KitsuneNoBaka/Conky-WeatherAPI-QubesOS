--------------------------------------
-- cairo-tools - Conky Cairo functions
--------------------------------------

require 'cairo'
local lualib = require 'lib/conky-lua-library'

local cairoT = {}

--require 'imlib2' # imlib2 is broken in conky 1.19.1 - 1.19.7

--[[
Write text on cr by definition (def)
		(override) table will override only those variable specified in override

def = {
	color = 0xffffff,
	alpha = 1,
	pos = {x = 23, y = 42},
	font = {'Open Sans', 12, 0|1|2|3},
	align = {'LEFT|right|center', 'BASELINE|bottom|middle|top'},
}

font[3] are bit flags where first bit is bold and second bit is italic. So:
	0 is normal,
	1 is bold,
	2 is italic,
	3 is bold+italic

returns the boundingBox = {
	left = %d,
	top = %d,
	width = %d,
	height = %d,
	right = %d,
	bottom = %d,
}
]]
function cairoT.write(cr, text, def, override)
	local font = (override and override.font and override.font[1]) or def.font[1] or 'Liberation Mono'
	local fontSize = (override and override.font and override.font[2]) or def.font[2] or 12
	local fontStyle = (override and override.font and override.font[3]) or def.font[3]
	local fontSlant = CAIRO_FONT_SLANT_NORMAL
	local fontWeight = CAIRO_FONT_WEIGHT_NORMAL

	if fontStyle and fontStyle % 2 == 1 then
		fontWeight = CAIRO_FONT_WEIGHT_BOLD
	end
	if fontStyle and fontStyle / 2 >= 1 then
		fontWeight = CAIRO_FONT_SLANT_ITALIC
	end

	cairo_select_font_face(cr, font, fontSlant, fontWeight)
	cairo_set_font_size(cr, fontSize)

	cairo_set_source_rgba(cr, lualib.rgbToRgba((override and override.color) or def.color or 0xffffff, (override and override.alpha) or def.alpha or 1))

	local x = (override and override.pos and override.pos.x) or def.pos.x
	local y = (override and override.pos and override.pos.y) or def.pos.y
	local te = cairo_text_extents_t:create()
	local fe = cairo_font_extents_t:create()
	cairo_text_extents(cr, text, te)
	cairo_font_extents(cr, fe)

	local alignV, alignH = 'left', 'bottom'
	if override and override.align then alignV, alignH = override.align[1], override.align[2]
	elseif def.align then alignV, alignH = def.align[1], def.align[2] end

	if (override and override.align) or def.align then
		if alignV == 'right' then
			x = x - te.width - te.x_bearing
		elseif alignV == 'center' then
			x = x - te.width/2 - te.x_bearing
		end

		if alignH == 'bottom' then
			y = y - fe.descent
		elseif alignH == 'middle' then
			y = y + te.height/2
		elseif alignH == 'top' then
			y = y + fe.ascent
		end
	end
	

	cairo_move_to(cr, x, y)
	cairo_show_text(cr, text)
	cairo_new_path(cr)

	local boundingBox = {
		x = x,
		y = y,
		left = x + te.x_bearing,
		top = y + te.y_bearing,
		width = te.width,
		height = te.height,
		right = x + te.x_bearing + te.width,
		bottom = y + te.y_bearing + te.height
	}

--	if override and override.test and def.widgetKey then print('# Debug: '..override.test) end

	return boundingBox
end

--[[
Draw a rectangle on cr by definition (def)
		(override) table will override only those variable specified in override

def = {
	pos = {x = 10, y = 10},
	size = {width = 200, height = 100},
	fill = {color = 0x000000, alpha = 0.2},
	stroke = {width = 2, color = 0x000000, alpha = 0.5},
	cornerRadius = 0,
}
]]
function cairoT.roundRectangle(cr, def, override)
	local pos, size = override and override.pos or def.pos, override and override.size or def.size;
	local radius = override and override.cornerRadius or def.cornerRadius or 0;
	local degrees = math.pi / 180.0;

	cairo_new_sub_path(cr)
	cairo_arc(
		cr,
		pos.x + size.width - radius,
		pos.y + radius,
		radius,
		270 * degrees,
		360 * degrees
	)
	cairo_arc(
		cr,
		pos.x + size.width - radius,
		pos.y + size.height - radius,
		radius,
		0 * degrees,
		90 * degrees
	)
	cairo_arc(
		cr,
		pos.x + radius,
		pos.y + size.height - radius,
		radius,
		90 * degrees,
		180 * degrees
	)
	cairo_arc(
		cr,
		pos.x + radius,
		pos.y + radius,
		radius,
		180 * degrees,
		270 * degrees
	)
	cairo_close_path(cr)

	if override and override.fill or def.fill then
		cairo_set_source_rgba(
			cr,
			lualib.rgbToRgba(
				override and override.fill and override.fill.color or def.fill.color, 
				override and override.fill and override.fill.alpha or def.fill.alpha or 1
			)
		)
		cairo_fill_preserve(cr)
	end

	if def.stroke ~= nil then
		cairo_set_source_rgba(
			cr,
			lualib.rgbToRgba(
				override and override.stroke and override.stroke.color or def.stroke.color,
				override and override.stroke and override.stroke.alpha or def.stroke.alpha or 1
			)
		)
		cairo_set_line_width(cr, override and override.stroke and override.stroke.width or def.stroke.width)
		cairo_stroke_preserve(cr)
	end

	cairo_new_path(cr)
	
	if def.widgetKey then
		return { [def.widgetKey] = { x=pos.x, y=pos.y, width=size.width, height=size.height } }
	end
end

return cairoT
