#!/usr/bin/lua

local lualib = require 'lib/conky-lua-library'
local cairoT = require 'lib/conky-cairo-tools'
local json = require 'lib/json-rxi'
conky = {}
local config, conkyWidgets = require 'weatherapi-conky-config'
local cr
config.set.queryM = config.set.queryM*60
local weatherArray = {}

local function main_body()
	local wURL = config.set.weatherAPIurl.prefix..
		'key='..config.set.weatherAPIkey.key..
		'&q='..config.set.weatherAPIcity.city..
		'&days='..config.set.weatherAPIdays.days..
		'&aqi='..config.set.weatherAPIaqi.aqi..
		'&alerts='..config.set.weatherAPIalerts.alerts..
		'&lang='..config.set.weatherAPIlang.lang..
		'"'

	local weatherCMD = 'qvm-run --pass-io --quiet --dispvm '..config.set.dispVM..' curl -s '..wURL

	if lualib.mtime() > config.set.timeLoop then
		config.set.timeLoop = lualib.mtime() + config.set.queryM
		local weatherFile = os.capture(weatherCMD)
		weatherArray = json.decode(weatherFile)
	end
	local unitsArr = {
		metric = {
			temp = { 'c', ' °C' },
			spd = { 'kph', ' km/h' },
			dist = { 'km', ' km' },
			psi = { 'mb', ' hPa' },
			rain = { 'mm', ' mm' },
			snow = { 'cm', ' cm' },
		},
		imperial = {
			temp = { 'f', ' °F' },
			spd = { 'mph', ' mph' },
			dist = { 'miles', ' miles' },
			psi = { 'in', ' inHg' },
			rain = { 'in', ' inch' },
			snow = { 'cm' , ' inch' },
		},
	}
	
--	weatherArray.current.condition.code
--	weatherArray.current.is_day

	if config.set.units=='imperial' then
		weatherArray.forecast.forecastday[1].day['totalsnow_'..unitsArr[config.set.units].snow[1]]=lualib.round((weatherArray.forecast.forecastday[1].day['totalsnow_'..unitsArr[config.set.units].snow[1]]/2.54), 2)
	end
	
-- current widget
	conkyWidgets = cairoT.roundRectangle(cr, config.tab.current)
	if conkyWidgets == nil then return '### Error: current widget: "nil" value of "conkyWidgets"' end
	local bb10 = cairoT.write(cr, 'Current', config.tab.current, {
		pos = {	x = conkyWidgets.current.x+conkyWidgets.current.width/2,
				y = conkyWidgets.current.y+8 },
				font = { 'significant', 16, 1 },
				color = config.set.colors.highlight,
	})
	local bb11 = cairoT.write(cr, weatherArray.location.name..'   /   '..weatherArray.location.country, config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb10.bottom+2 },
				color = config.set.colors.pastelgreen,
	})
	local bb12 = cairoT.write(cr, 'Temp: '..weatherArray.current['temp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb11.bottom+8 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Feels: '..weatherArray.current['feelslike_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb11.bottom+8 },
	})
	cairoT.write(cr, 'Dew: '..weatherArray.current['dewpoint_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.width-24,
				y = bb11.bottom+8 },
		align = { 'right', 'top' },
	})
	local bb13 = cairoT.write(cr, 'Clouds: '..weatherArray.current.cloud..' %', config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb12.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'VIS: '..weatherArray.current['vis_'..unitsArr[config.set.units].dist[1]]..unitsArr[config.set.units].dist[2], config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb12.bottom+2 },
	})
	cairoT.write(cr, 'PRES: '..weatherArray.current['pressure_'..unitsArr[config.set.units].psi[1]]..unitsArr[config.set.units].psi[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.width-24,
				y = bb12.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb14 = cairoT.write(cr, 'Condition: '..weatherArray.current.condition.text, config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb13.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb15 = cairoT.write(cr, 'Wind: '..weatherArray.current['wind_'..unitsArr[config.set.units].spd[1]]..unitsArr[config.set.units].spd[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb14.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, '"'..weatherArray.current.wind_dir..'"', config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb14.bottom+2 },
	})
	cairoT.write(cr, 'Gust: '..weatherArray.current['gust_'..unitsArr[config.set.units].spd[1]]..unitsArr[config.set.units].spd[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.width-24,
				y = bb14.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb16 = cairoT.write(cr, 'Humidity: '..weatherArray.current.humidity..' %', config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb15.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Precip: '..weatherArray.current['precip_'..unitsArr[config.set.units].rain[1]]..unitsArr[config.set.units].rain[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.width-24,
				y = bb15.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb17 = cairoT.write(cr, 'Air quality', config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb16.bottom+2 },
	})
	local bb18 = cairoT.write(cr, 'EPA index:  '..weatherArray.current.air_quality['us-epa-index'], config.tab.current, {
		pos = {	x = bb17.left,
				y = bb17.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.write(cr, 'Defra index:  '..weatherArray.current.air_quality['gb-defra-index'], config.tab.current, {
		pos = {	x = bb17.right,
				y = bb17.bottom+2 },
		align = { 'left', 'top' },
	})


	
-- today widget
	conkyWidgets = cairoT.roundRectangle(cr, config.tab.today)
	if conkyWidgets == nil then return '### Error: today widget: "nil" value of "conkyWidgets"' end
	local bb20 = cairoT.write(cr, 'Forecast   -   Today', config.tab.today, {
		pos = {	x = conkyWidgets.today.x+conkyWidgets.today.width/2,
				y = conkyWidgets.today.y+8 },
				font = { 'significant', 16, 1 },
				color = config.set.colors.highlight,
	})
	local bb21 = cairoT.write(cr, 'TMax: '..weatherArray.forecast.forecastday[1].day['maxtemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb20.bottom+8 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'TAvg: '..weatherArray.forecast.forecastday[1].day['avgtemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.today, {
		pos = {	x = bb20.left+bb20.width/2,
				y = bb20.bottom+8 },
	})
	cairoT.write(cr, 'TMin: '..weatherArray.forecast.forecastday[1].day['mintemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb20.bottom+8 },
		align = { 'right', 'top' },
	})
	local bb22 = cairoT.write(cr, 'Condition: '..weatherArray.forecast.forecastday[1].day.condition.text, config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb21.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb23 = cairoT.write(cr, 'Wind: '..weatherArray.forecast.forecastday[1].day['maxwind_'..unitsArr[config.set.units].spd[1]]..unitsArr[config.set.units].spd[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb22.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Humidity: '..weatherArray.forecast.forecastday[1].day.avghumidity..' %', config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb22.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb24 = cairoT.write(cr, 'Precip: '..weatherArray.forecast.forecastday[1].day['totalprecip_'..unitsArr[config.set.units].rain[1]]..unitsArr[config.set.units].rain[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb23.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Chance of rain: '..weatherArray.forecast.forecastday[1].day.daily_chance_of_rain..' %', config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb23.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb25 = cairoT.write(cr, 'Snow: '..weatherArray.forecast.forecastday[1].day['totalsnow_'..unitsArr[config.set.units].snow[1]]..unitsArr[config.set.units].snow[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb24.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Chance of snow: '..weatherArray.forecast.forecastday[1].day.daily_chance_of_snow..' %', config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb24.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb26 = cairoT.write(cr, 'Air quality', config.tab.today, {
		pos = {	x = bb20.left+bb20.width/2,
				y = bb25.bottom+2 },
	})
	local bb27 = cairoT.write(cr, 'EPA index:  '..weatherArray.forecast.forecastday[1].day.air_quality['us-epa-index'], config.tab.today, {
		pos = {	x = bb26.left,
				y = bb26.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.write(cr, 'Defra index:  '..weatherArray.forecast.forecastday[1].day.air_quality['gb-defra-index'], config.tab.today, {
		pos = {	x = bb26.right,
				y = bb26.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb28 = cairoT.write(cr, 'Sunrise: '..weatherArray.forecast.forecastday[1].astro.sunrise, config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb27.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Sunset: '..weatherArray.forecast.forecastday[1].astro.sunset, config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb27.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb29 = cairoT.write(cr, 'Moonrise: '..weatherArray.forecast.forecastday[1].astro.moonrise, config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb28.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Moonset: '..weatherArray.forecast.forecastday[1].astro.moonset, config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb28.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.write(cr, 'Moon phase: '..weatherArray.forecast.forecastday[1].astro.moon_phase, config.tab.today, {
		pos = {	x = bb20.left+bb20.width/2,
				y = bb29.bottom+2 },
	})


	
-- tomorrow widget
	conkyWidgets = cairoT.roundRectangle(cr, config.tab.tomorrow)
	if conkyWidgets == nil then return '### Error: tomorrow widget: "nil" value of "conkyWidgets"' end
	local bb30 = cairoT.write(cr, 'Forecast   -   Tomorrow', config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+conkyWidgets.tomorrow.width/2,
				y = conkyWidgets.tomorrow.y+8 },
				font = { 'significant', 16, 1 },
				color = config.set.colors.highlight,
	})
	local bb31 = cairoT.write(cr, 'TMax: '..weatherArray.forecast.forecastday[2].day['maxtemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb30.bottom+8 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'TAvg: '..weatherArray.forecast.forecastday[2].day['avgtemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.tomorrow, {
		pos = {	x = bb30.left+bb30.width/2,
				y = bb30.bottom+8 },
	})
	cairoT.write(cr, 'TMin: '..weatherArray.forecast.forecastday[2].day['mintemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb30.bottom+8 },
		align = { 'right', 'top' },
	})
	local bb32 = cairoT.write(cr, 'Condition: '..weatherArray.forecast.forecastday[2].day.condition.text, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb31.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb33 = cairoT.write(cr, 'Wind: '..weatherArray.forecast.forecastday[2].day['maxwind_'..unitsArr[config.set.units].spd[1]]..unitsArr[config.set.units].spd[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb32.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Humidity: '..weatherArray.forecast.forecastday[2].day.avghumidity..' %', config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb32.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb34 = cairoT.write(cr, 'Precip: '..weatherArray.forecast.forecastday[2].day['totalprecip_'..unitsArr[config.set.units].rain[1]]..unitsArr[config.set.units].rain[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb33.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Chance of rain: '..weatherArray.forecast.forecastday[2].day.daily_chance_of_rain..' %', config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb33.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb35 = cairoT.write(cr, 'Snow: '..weatherArray.forecast.forecastday[2].day['totalsnow_'..unitsArr[config.set.units].snow[1]]..unitsArr[config.set.units].snow[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb34.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Chance of snow: '..weatherArray.forecast.forecastday[2].day.daily_chance_of_snow..' %', config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb34.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb36 = cairoT.write(cr, 'Air quality', config.tab.tomorrow, {
		pos = {	x = bb30.left+bb30.width/2,
				y = bb35.bottom+2 },
	})
	local bb37 = cairoT.write(cr, 'EPA index:  '..weatherArray.forecast.forecastday[2].day.air_quality['us-epa-index'], config.tab.tomorrow, {
		pos = {	x = bb36.left,
				y = bb36.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.write(cr, 'Defra index:  '..weatherArray.forecast.forecastday[2].day.air_quality['gb-defra-index'], config.tab.tomorrow, {
		pos = {	x = bb36.right,
				y = bb36.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb38 = cairoT.write(cr, 'Sunrise: '..weatherArray.forecast.forecastday[2].astro.sunrise, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb37.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Sunset: '..weatherArray.forecast.forecastday[2].astro.sunset, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb37.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb39 = cairoT.write(cr, 'Moonrise: '..weatherArray.forecast.forecastday[2].astro.moonrise, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb38.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.write(cr, 'Moonset: '..weatherArray.forecast.forecastday[2].astro.moonset, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb38.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.write(cr, 'Moon phase: '..weatherArray.forecast.forecastday[2].astro.moon_phase, config.tab.tomorrow, {
		pos = {	x = bb30.left+bb30.width/2,
				y = bb39.bottom+2 },
	})
end



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

	local error = main_body()
	if error then print(error) return false end
	
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	
	cr, cs, width, height, updates = nil, nil, nil, nil, nil
	cairo_debug_reset_static_data()
	collectgarbage("collect")
end
