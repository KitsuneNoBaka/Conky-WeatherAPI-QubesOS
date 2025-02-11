--[[
------------------------------------------------------------------------
-- configuration file                                                 --
------------------------------------------------------------------------

Here are config parameters required for widget to works
You need to paste WheaterAPI url here
and decide if you want metric or imperial units
]]

------------------------------------------------------------------------
-- width and height of whole Conky drawing space                      --
local width, height = 360, 524                                        --
------------------------------------------------------------------------

--[[
]]


local config = {}
local conkyWidgets = {}


--[[
Legacy Conky style configuration
change only those settings that have commentary at the end
]]
conky.config = {
--	Conky settings #
	background = false,
	update_interval = 60,

	cpu_avg_samples = 3,
	net_avg_samples = 3,

	override_utf8_locale = true,
	use_xft = true,

	double_buffer = true,
	no_buffers = true,

	text_buffer_size = 2048,
	--imlib_cache_size 0

	temperature_unit = 'celsius',

--	XFCE lightdm and gnome backround issue
	own_window_argb_visual = true,
	own_window_argb_value = 0,

--	Window specifications #
	own_window_class = 'Conky',
	own_window = true,
	own_window_type = 'desktop',
	own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
	own_window_transparent = false,

	border_inner_margin = 0,
	border_outer_margin = 0,

	minimum_width = width,
	minimum_height = height,

	alignment = 'top_right',	-- alignment of Conky window (top_right/top_left/bottom_right/bottom_left/center)
	gap_x = -44,				-- gap between border of the screen and border of the Conky window in X axis (screen widht) dependent on alignment
	gap_y = 38,					-- gap between border of the screen and border of the Conky window in Y axis (screen height) dependent on alignment

    lua_load = 'weatherapi-conky.lua',
	lua_draw_hook_pre = 'conky_main',
}

conky.text = [[]]

--[[
Here you can change fonts and colors (color are in HEX RGB format)
Chose units metric / imperial
Set WeatherAPI url of weather data
]]
config.set = {
	-- chose units betwen metric or imperial (comment/uncomment right one)
	units = 'metric',
	--units = 'imperial',
	
	-- chose how often ask WeatherAPI about weather data, in minutes (default and minimal: 15 minutes)
	queryM = 15,
	timeLoop = 0,
	-- chose minimal disposable qube with net capability
	dispVM = 'dvm-minimal',
	-- url with api from https://weatherapi.com
	-- key=########	- it's your personal API key
	-- q=City_Name 	- it's your place for which you want forecast
	-- days=2 		- it's number of days forecast is for
	-- aqi=yes		- air quality index
	-- alerts=no	- textual alerts
	-- lang=fr		- language of conditions text (optional - if not set it will be english)
	weatherAPIurl = '"https://api.weatherapi.com/v1/forecast.json?key=########&q=City_Name&days=2&aqi=yes&alerts=no&lang=en"',

	fonts = {
		default = 'Liberation Mono',
		significant = 'Noto Serif',
	},
	colors = {
		default = 0xffffff,
		highlight = 0x00bfa5,
		gaugeBg = 0xffffff,
		gaugeBgAlpha = 0.1,
		gauge = 0xffffff,
		gaugeAlpha = 0.8,
		gaugeInfo = 0x00bfa5,
		gaugeWarn = 0xfbc02d,
		gaugeCrit = 0xdd2c00,
		black = 0x000000,
		white = 0xffffff,
		pastelred = 0xffb060,
		pastelgreen = 0x60ffb0,
		pastelblue = 0x60b0ff,
	},
}



--[[
Here are configurations of widgets:
	possition inside Conky window
	size
	background color
	fonts
	fonts colors
]]
config.tab = {
	current = {
		pos = { x=0, y=0 },
		size = { width = width, height = 180 },
		fill = {color = config.set.colors.pastelblue, alpha = 0.1},
		stroke = {width = 2, color = config.set.colors.black, alpha = 0.1},
		cornerRadius = 48,
		widgetKey = 'current',
		align = { 'center', 'top' },
		font = { 'significant', 12, 1 },	-- font face, font size, font style ( 0/1/2/3 -> normal/bold/italic/bold-italic )
		color = config.set.colors.pastelblue,		-- font and drawing color (can be override in main script)
	},
	today = {
		pos = { x=0, y=180+4 },
		size = { width = width, height = 210 },
		fill = {color = config.set.colors.pastelblue, alpha = 0.1},
		stroke = {width = 2, color = config.set.colors.black, alpha = 0.1},
		cornerRadius = 48,
		widgetKey = 'today',
		align = { 'center', 'top' },
		font = { 'significant', 12, 1 },	-- font face, font size, font style ( 0/1/2/3 -> normal/bold/italic/bold-italic )
		color = config.set.colors.pastelblue,		-- font and drawing color (can be override in main script)
	},
	tomorrow = {
		pos = { x=0, y=180+4+210+4 },
		size = { width = width, height = 210 },
		fill = {color = config.set.colors.pastelblue, alpha = 0.1},
		stroke = {width = 2, color = config.set.colors.black, alpha = 0.1},
		cornerRadius = 48,
		widgetKey = 'tomorrow',
		align = { 'center', 'top' },
		font = { 'significant', 12, 1 },	-- font face, font size, font style ( 0/1/2/3 -> normal/bold/italic/bold-italic )
		color = config.set.colors.pastelblue,		-- font and drawing color (can be override in main script)
	},
}



config.icons = {
	[1000] = { '113', 'clear' },
	[1003] = { '116', 'partly_cloudy' },
	[1006] = { '119', 'cloudy' },
	[1009] = { '122', 'overcast' },
	[1030] = { '143', 'mist' },
	[1063] = { '176', 'patchy_rain_nerby' },
	[1066] = { '179', 'patchy_snow_nerby' },
	[1069] = { '182', 'patchy_sleet_nerby' },
	[1072] = { '185', 'patchy_freezing_drizzle_nerby' },
	[1087] = { '200', 'thundery_outbreaks_in_nerby' },
	[1114] = { '227', 'blowing_snow' },
	[1117] = { '230', 'blizzard' },
	[1135] = { '248', 'fog' },
	[1147] = { '260', 'freezing_fog' },
	[1150] = { '263', 'patchy_light_drizzle' },
	[1153] = { '266', 'light_drizzle' },
	[1168] = { '281', 'freezing_drizzle' },
	[1171] = { '284', 'heavy_freezing_drizzle' },
	[1180] = { '293', 'patchy_light_rain' },
	[1183] = { '296', 'light_rain' },
	[1186] = { '299', 'moderate_rain_at_times' },
	[1189] = { '302', 'moderate_rain' },
	[1192] = { '305', 'heavy_rain_at_times' },
	[1195] = { '308', 'heavy_rain' },
	[1198] = { '311', 'light_freezing_rain' },
	[1201] = { '314', 'moderate_or_heavy_freezing_rain' },
	[1204] = { '317', 'light_sleet' },
	[1207] = { '320', 'moderate_or_heavy_sleet' },
	[1210] = { '323', 'patchy_light_snow' },
	[1213] = { '326', 'light_snow' },
	[1216] = { '329', 'patchy_moderate_snow' },
	[1219] = { '332', 'moderate_snow' },
	[1222] = { '335', 'patchy_heavy_snow' },
	[1225] = { '338', 'heavy_snow' },
	[1237] = { '350', 'ice_pellets' },
	[1240] = { '353', 'light_rain_shower' },
	[1243] = { '356', 'moderate_or_heavy_rain_shower' },
	[1246] = { '359', 'torrential_rain_shower' },
	[1249] = { '362', 'light_sleet_showers' },
	[1252] = { '365', 'moderate_or_heavy_sleet_showers' },
	[1255] = { '368', 'light_snow_showers' },
	[1258] = { '371', 'moderate_or_heavy_snow_showers' },
	[1261] = { '374', 'light_showers_of_ice_pellets' },
	[1264] = { '377', 'moderate_or_heavy_showers_of_ice_pellets' },
	[1273] = { '386', 'patchy_light_rain_in_area_with_thunder' },
	[1276] = { '389', 'moderate_or_heavy_rain_in_area_with_thunder' },
	[1279] = { '392', 'patchy_light_snow_in_area_with_thunder' },
	[1282] = { '395', 'moderate_or_heavy_snow_in_area_with_thunder' },
}

return config, conkyWidgets
