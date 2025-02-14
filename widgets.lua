------------------------------------------------------------------------
--      WeatherAPI widgets
------------------------------------------------------------------------

local widgets ={}

local lualib = require 'lib/lua-library'
local cairoT = require 'lib/cairo-tools'
local json = require 'lib/json-rxi'
local weatherArray = {}
local config, conkyWidgets = require 'config'
config.set.queryM = config.set.queryM*60

function widgets.main(cr)
	local wURL = config.set.weatherAPIurl.prefix..
		'key='..config.set.weatherAPIurl.key..
		'&q='..config.set.weatherAPIurl.city..
		'&days='..config.set.weatherAPIurl.days..
		'&aqi='..config.set.weatherAPIurl.aqi..
		'&alerts='..config.set.weatherAPIurl.alerts..
		'&lang='..config.set.weatherAPIurl.lang..
		'"'
--	print('# URL parse: check')
	local weatherCMD = 'qvm-run --pass-io --quiet --dispvm '..config.set.dispVM..' curl -s '..wURL

	if lualib.mtime() > config.set.timeLoop then
		config.set.timeLoop = lualib.mtime() + config.set.queryM
		local weatherFile = os.capture(weatherCMD)
		weatherArray = json.decode(weatherFile)
--		print('# WeatherAPI pull: check')
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
--	print('# Units: check')

-- current widget
	conkyWidgets = cairoT.roundRectangle(cr, config.tab.current)
	if conkyWidgets == nil then return '### Error: current widget: "nil" value of "conkyWidgets"' end
--	print('# Widget box: check')
	local bb10 = cairoT.text_print(cr, 'Current', config.tab.current, {
		pos = {	x = conkyWidgets.current.x+conkyWidgets.current.width/2,
				y = conkyWidgets.current.y+32 },
				font = { 'significant', 16, 1 },
				color = config.set.colors.highlight,
	})
--	print('# Widget write: check')
	local bb11 = cairoT.text_print(cr, weatherArray.location.name..'   /   '..weatherArray.location.country, config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb10.bottom+2 },
				color = config.set.colors.pastelgreen,
	})
	local bb12 = cairoT.text_print(cr, 'Temp: '..weatherArray.current['temp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb11.bottom+8 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Feels: '..weatherArray.current['feelslike_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb11.bottom+8 },
	})
	cairoT.text_print(cr, 'Dew: '..weatherArray.current['dewpoint_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.width-24,
				y = bb11.bottom+8 },
		align = { 'right', 'top' },
	})
	local bb13 = cairoT.text_print(cr, 'Clouds: '..weatherArray.current.cloud..' %', config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb12.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'VIS: '..weatherArray.current['vis_'..unitsArr[config.set.units].dist[1]]..unitsArr[config.set.units].dist[2], config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb12.bottom+2 },
	})
	cairoT.text_print(cr, 'PRES: '..weatherArray.current['pressure_'..unitsArr[config.set.units].psi[1]]..unitsArr[config.set.units].psi[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.width-24,
				y = bb12.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb14 = cairoT.text_print(cr, 'Condition: '..weatherArray.current.condition.text, config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb13.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb15 = cairoT.text_print(cr, 'Wind: '..weatherArray.current['wind_'..unitsArr[config.set.units].spd[1]]..unitsArr[config.set.units].spd[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb14.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, '"'..weatherArray.current.wind_dir..'"', config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb14.bottom+2 },
	})
	cairoT.text_print(cr, 'Gust: '..weatherArray.current['gust_'..unitsArr[config.set.units].spd[1]]..unitsArr[config.set.units].spd[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.width-24,
				y = bb14.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb16 = cairoT.text_print(cr, 'Humidity: '..weatherArray.current.humidity..' %', config.tab.current, {
		pos = {	x = conkyWidgets.current.x+24,
				y = bb15.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Precip: '..weatherArray.current['precip_'..unitsArr[config.set.units].rain[1]]..unitsArr[config.set.units].rain[2], config.tab.current, {
		pos = {	x = conkyWidgets.current.width-24,
				y = bb15.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb17 = cairoT.text_print(cr, 'Air quality', config.tab.current, {
		pos = {	x = bb10.left+bb10.width/2,
				y = bb16.bottom+2 },
	})
	local bb18 = cairoT.text_print(cr, 'EPA index:  '..weatherArray.current.air_quality['us-epa-index'], config.tab.current, {
		pos = {	x = bb17.left,
				y = bb17.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.text_print(cr, 'Defra index:  '..weatherArray.current.air_quality['gb-defra-index'], config.tab.current, {
		pos = {	x = bb17.right,
				y = bb17.bottom+2 },
		align = { 'left', 'top' },
	})


	
-- today widget
	conkyWidgets = cairoT.roundRectangle(cr, config.tab.today)
	if conkyWidgets == nil then return '### Error: today widget: "nil" value of "conkyWidgets"' end
	local bb20 = cairoT.text_print(cr, 'Forecast   -   Today', config.tab.today, {
		pos = {	x = conkyWidgets.today.x+conkyWidgets.today.width/2,
				y = conkyWidgets.today.y+32 },
				font = { 'significant', 16, 1 },
				color = config.set.colors.highlight,
	})
	local bb21 = cairoT.text_print(cr, 'TMax: '..weatherArray.forecast.forecastday[1].day['maxtemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb20.bottom+8 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'TAvg: '..weatherArray.forecast.forecastday[1].day['avgtemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.today, {
		pos = {	x = bb20.left+bb20.width/2,
				y = bb20.bottom+8 },
	})
	cairoT.text_print(cr, 'TMin: '..weatherArray.forecast.forecastday[1].day['mintemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb20.bottom+8 },
		align = { 'right', 'top' },
	})
	local bb22 = cairoT.text_print(cr, 'Condition: '..weatherArray.forecast.forecastday[1].day.condition.text, config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb21.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb23 = cairoT.text_print(cr, 'Wind: '..weatherArray.forecast.forecastday[1].day['maxwind_'..unitsArr[config.set.units].spd[1]]..unitsArr[config.set.units].spd[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb22.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Humidity: '..weatherArray.forecast.forecastday[1].day.avghumidity..' %', config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb22.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb24 = cairoT.text_print(cr, 'Precip: '..weatherArray.forecast.forecastday[1].day['totalprecip_'..unitsArr[config.set.units].rain[1]]..unitsArr[config.set.units].rain[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb23.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Chance of rain: '..weatherArray.forecast.forecastday[1].day.daily_chance_of_rain..' %', config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb23.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb25 = cairoT.text_print(cr, 'Snow: '..weatherArray.forecast.forecastday[1].day['totalsnow_'..unitsArr[config.set.units].snow[1]]..unitsArr[config.set.units].snow[2], config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb24.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Chance of snow: '..weatherArray.forecast.forecastday[1].day.daily_chance_of_snow..' %', config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb24.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb26 = cairoT.text_print(cr, 'Air quality', config.tab.today, {
		pos = {	x = bb20.left+bb20.width/2,
				y = bb25.bottom+2 },
	})
	local bb27 = cairoT.text_print(cr, 'EPA index:  '..weatherArray.forecast.forecastday[1].day.air_quality['us-epa-index'], config.tab.today, {
		pos = {	x = bb26.left,
				y = bb26.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.text_print(cr, 'Defra index:  '..weatherArray.forecast.forecastday[1].day.air_quality['gb-defra-index'], config.tab.today, {
		pos = {	x = bb26.right,
				y = bb26.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb28 = cairoT.text_print(cr, 'Sunrise: '..weatherArray.forecast.forecastday[1].astro.sunrise, config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb27.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Sunset: '..weatherArray.forecast.forecastday[1].astro.sunset, config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb27.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb29 = cairoT.text_print(cr, 'Moonrise: '..weatherArray.forecast.forecastday[1].astro.moonrise, config.tab.today, {
		pos = {	x = conkyWidgets.today.x+24,
				y = bb28.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Moonset: '..weatherArray.forecast.forecastday[1].astro.moonset, config.tab.today, {
		pos = {	x = conkyWidgets.today.width-24,
				y = bb28.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.text_print(cr, 'Moon phase: '..weatherArray.forecast.forecastday[1].astro.moon_phase, config.tab.today, {
		pos = {	x = bb20.left+bb20.width/2,
				y = bb29.bottom+2 },
	})


	
-- tomorrow widget
	conkyWidgets = cairoT.roundRectangle(cr, config.tab.tomorrow)
	if conkyWidgets == nil then return '### Error: tomorrow widget: "nil" value of "conkyWidgets"' end
	local bb30 = cairoT.text_print(cr, 'Forecast   -   Tomorrow', config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+conkyWidgets.tomorrow.width/2,
				y = conkyWidgets.tomorrow.y+32 },
				font = { 'significant', 16, 1 },
				color = config.set.colors.highlight,
	})
	local bb31 = cairoT.text_print(cr, 'TMax: '..weatherArray.forecast.forecastday[2].day['maxtemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb30.bottom+8 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'TAvg: '..weatherArray.forecast.forecastday[2].day['avgtemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.tomorrow, {
		pos = {	x = bb30.left+bb30.width/2,
				y = bb30.bottom+8 },
	})
	cairoT.text_print(cr, 'TMin: '..weatherArray.forecast.forecastday[2].day['mintemp_'..unitsArr[config.set.units].temp[1]]..unitsArr[config.set.units].temp[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb30.bottom+8 },
		align = { 'right', 'top' },
	})
	local bb32 = cairoT.text_print(cr, 'Condition: '..weatherArray.forecast.forecastday[2].day.condition.text, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb31.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb33 = cairoT.text_print(cr, 'Wind: '..weatherArray.forecast.forecastday[2].day['maxwind_'..unitsArr[config.set.units].spd[1]]..unitsArr[config.set.units].spd[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb32.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Humidity: '..weatherArray.forecast.forecastday[2].day.avghumidity..' %', config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb32.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb34 = cairoT.text_print(cr, 'Precip: '..weatherArray.forecast.forecastday[2].day['totalprecip_'..unitsArr[config.set.units].rain[1]]..unitsArr[config.set.units].rain[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb33.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Chance of rain: '..weatherArray.forecast.forecastday[2].day.daily_chance_of_rain..' %', config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb33.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb35 = cairoT.text_print(cr, 'Snow: '..weatherArray.forecast.forecastday[2].day['totalsnow_'..unitsArr[config.set.units].snow[1]]..unitsArr[config.set.units].snow[2], config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb34.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Chance of snow: '..weatherArray.forecast.forecastday[2].day.daily_chance_of_snow..' %', config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb34.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb36 = cairoT.text_print(cr, 'Air quality', config.tab.tomorrow, {
		pos = {	x = bb30.left+bb30.width/2,
				y = bb35.bottom+2 },
	})
	local bb37 = cairoT.text_print(cr, 'EPA index:  '..weatherArray.forecast.forecastday[2].day.air_quality['us-epa-index'], config.tab.tomorrow, {
		pos = {	x = bb36.left,
				y = bb36.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.text_print(cr, 'Defra index:  '..weatherArray.forecast.forecastday[2].day.air_quality['gb-defra-index'], config.tab.tomorrow, {
		pos = {	x = bb36.right,
				y = bb36.bottom+2 },
		align = { 'left', 'top' },
	})
	local bb38 = cairoT.text_print(cr, 'Sunrise: '..weatherArray.forecast.forecastday[2].astro.sunrise, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb37.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Sunset: '..weatherArray.forecast.forecastday[2].astro.sunset, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb37.bottom+2 },
		align = { 'right', 'top' },
	})
	local bb39 = cairoT.text_print(cr, 'Moonrise: '..weatherArray.forecast.forecastday[2].astro.moonrise, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.x+24,
				y = bb38.bottom+2 },
		align = { 'left', 'top' },
	})
	cairoT.text_print(cr, 'Moonset: '..weatherArray.forecast.forecastday[2].astro.moonset, config.tab.tomorrow, {
		pos = {	x = conkyWidgets.tomorrow.width-24,
				y = bb38.bottom+2 },
		align = { 'right', 'top' },
	})
	cairoT.text_print(cr, 'Moon phase: '..weatherArray.forecast.forecastday[2].astro.moon_phase, config.tab.tomorrow, {
		pos = {	x = bb30.left+bb30.width/2,
				y = bb39.bottom+2 },
	})
end

return widgets
