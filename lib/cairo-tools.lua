------------------------------------------------------------------------
--      cairo-tools - Conky Cairo functions
------------------------------------------------------------------------

require 'cairo'
local lualib = require 'lib/lua-library'

local cairoT = {}

--require 'imlib2' # imlib2 is broken in conky 1.19.1 - 1.19.7


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
--	print('# Cairo: variables: check')

	cairo_new_sub_path(cr)
--	print('# Cairo: sub_path: check')
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


--[[
Makes array of glyph from text, which can be shown on surface by `cairo_show_glyphs()` and `cairo_show_text_glyphs()`
Returns:
	number*status
	cairo_glyph_t*glyphs
	number*glyph_count
	cairo_cluster_t*clusters
	number*cluster_count
	number*cluster_flags
--]]
function cairoT.text2glyph( cr, text, fontFace, fontSize, fontStyle )
	local fontSlant = CAIRO_FONT_SLANT_NORMAL
	local fontWeight = CAIRO_FONT_WEIGHT_NORMAL
	if fontStyle %2 == 1 then 
		fontSlant = CAIRO_FONT_SLANT_BOLD
	end
	if fontStyle and fontStyle / 2 >= 1 then
		fontWeight = CAIRO_FONT_SLANT_ITALIC
	end
	
	cairo_set_font_face( cr, fontFace, fontSlant, fontWeight )
	cairo_set_font_size( cr, fontSize )
	local scaledFont = cairo_get_scaled_font( cr )
	local status
	local glyphs = {}
	local glyph_count = 0
	local clusters = {}
	local cluster_count = 0
	local cluster_flags = 1

	return cairo_scaled_font_text_to_glyphs( scaledFont, 0, 0, text, string.len(text) )
end


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
	center = %d,
	right = %d,
	width = %d,
	height = %d,
	top = %d,
	middle = %d,
	bottom = %d,
}
]]
function cairoT.text_print( cr, text, def, override )
	local font = {}
	font[1] = (override and override.font and override.font[1]) or def.font[1] or 'Liberation Mono'
	font[2] = (override and override.font and override.font[2]) or def.font[2] or 12
	font[3] = (override and override.font and override.font[3]) or def.font[3] or 0
	local x = (override and override.pos and override.pos.x) or def.pos.x or 0
	local y = (override and override.pos and override.pos.y) or def.pos.y or 0

	local status, glyphs, glyph_count, clusters, cluster_count, cluster_flags = cairoT.text2glyph( cr, text, font[1], font[2], font[3] )

	local te = cairo_text_extents_t:create()
	cairo_glyph_extents( cr, glyphs, glyph_count, te )

	local alignV, alignH = 'left', 'bottom'
	if override and override.align then alignV, alignH = override.align[1], override.align[2]
	elseif def.align then alignV, alignH = def.align[1], def.align[2] end

	te.height = def.font[2]
	if alignV == 'right' then
		x = x - te.width - te.x_bearing
	elseif alignV == 'center' then
		x = x - te.width/2
	elseif alignV == 'left' then
		x = x + te.x_bearing
	end
	if alignH == 'bottom' then
		y = y + te.height + te.y_advance
	elseif alignH == 'middle' then
		y =  y + te.height/2
	elseif alignH == 'top' then
		y = y + te.y_advance
	end
	
	local boundingBox = {
		x = x ,
		y = y,
		left = x + te.x_bearing,
		center = x + te.width/2,
		right = x - te.x_bearing + te.width,
		width = te.width,
		height = te.height,
		top = y - te.y_advance,
		middle = y + te.height/2,
		bottom = y + te.y_advance + te.height
	}
	
	cairo_save(cr)
	cairo_translate( cr, x, y )
	cairo_set_source_rgba(cr, lualib.rgbToRgba((override and override.color) or def.color or 0xffffff, (override and override.alpha) or def.alpha or 1))
	cairo_show_text_glyphs( cr, text, string.len(text), glyphs, glyph_count, clusters, cluster_count, cluster_flags )
	cairo_restore(cr)

	te:destroy()
	cairo_glyph_free(glyphs)
	cairo_text_cluster_free(clusters)
	
	return boundingBox
end

return cairoT
