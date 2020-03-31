local composer = require( "composer" )
local scene = composer.newScene()

---------------------------------------------------------------------------------
--| VARIABLES |--
	local _W = display.contentWidth
	local _H = display.contentHeight

	local _W_Orig = display.pixelWidth
	local _H_Orig = display.pixelHeight

	local _W_Real = (_W_Orig / _H_Orig) * _H
	local _H_Real = (_H_Orig / _W_Orig) * _W

	local sizeSmall_W = 550
	local sizeSmall_H = 150
	
	local _font = "HelveticaNeue-Light"

	--Buttons
	local rateMenu
	local rateText
	local rateTimer
	local rate_NO
	local rate_YES
	local rate_appStore

---------------------------------------------------------------------------------
--| GLOBAL REQUIRE |--
	--local analytics = require( "analytics" )
		--analytics.init("S52RN5ZNSBDH26MY9ZWK")

---------------------------------------------------------------------------------
--| REQUIRE |--
	local dbfunctions = require("dbfunctions")
	dbfunctions.init("dbGear.db")

---------------------------------------------------------------------------------
--| FUNCTIONS |--

local function destroyScene()

	display.remove( rateMenu ); rateMenu = nil
	display.remove( rateText ); rateText = nil
	display.remove( rateTimer ); rateTimer = nil
	display.remove( rate_NO ); rate_NO = nil
	display.remove( rate_YES ); rate_YES = nil
	display.remove( rate_appStore ); rate_appStore = nil
end

local function go_CustomizeCharacter()

	--composer.gotoScene("customizeCharacter")
	local options = {
		isModal = true,
		effect = "fade",
		time = 500
	}
	composer.showOverlay( "customizeCharacter",options )
end

local function tickTock(event)
	if event == nil then
		event = rateTimer
	end

	local _startTime = dbfunctions.getTableValue("generalSettings", "rateStart", "value")
	_startTime = tonumber( _startTime )
	--print("START TIME")
	--print(_startTime)

	local _currentTime = os.time( os.date( '*t' ) )
	_currentTime = tonumber( _currentTime )
	--print("Current")
	--print(_currentTime)

	--print("Change")
	--print( _currentTime - _startTime )

	local _waitTime = 45 - ( _currentTime - _startTime )
	event.text = _waitTime

	if _waitTime <= 1 then

		dbfunctions.updateTableValue("generalSettings", "rate", "value", "yes")
		timer.cancel( event.timerHandle )
		go_CustomizeCharacter()
	end
end

local function go_mainMenu()

	--print("GO TO Rate")
	composer.hideOverlay( "flip",125 )

	local options = {
		isModal = true,
		effect = "fade",
		time = 500
	}
	composer.showOverlay( "mainMenu",options )
end

local function createButtons()

	rateMenu = display.newImage("images/mainMenu/rateMenu.png")
	rateMenu.x = _W/2
	rateMenu.y = _H/2
	rateMenu.xScale = 1.75
	rateMenu.yScale = 1.5

	local options = 
		{
		    --parent = textGroup,
		    text = "Take 45 seconds to rate?  Rate to unlock Custom Character!",     
		    x = rateMenu.x,
		    y = rateMenu.y - 300,
		    width = 460,
		    height = 0,     --required for multi-line and alignment
		    font = _font,   
		    fontSize = 60,
		    align = "center"  --new alignment parameter
		}
	rateText = display.newText( options )
	rateText:setFillColor(1,1,1)
	rateText.anchorY = 0

	rateTimer = display.newText("--",999, 999, "Helvetica" ,60)
	rateTimer.x = rateMenu.x
	rateTimer.y = rateMenu.y + 100
	rateTimer:setFillColor(0.2,0.2,0.2)
	rateTimer.isVisible = false


	rate_NO =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_NotNow.png",width = sizeSmall_W/2,
		height = sizeSmall_H,

		onEvent = function(event) 
			if "ended" == event.phase then
				go_mainMenu()
				analytics.logEvent( "RateMenu", {Rate = "No"})
			end
		end
	}
	rate_NO.x = rateMenu.x - 150
	rate_NO.y = rateMenu.y + 225


	rate_YES =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_Rate.png",
		font = _font,
		width = sizeSmall_W/2,
		height = sizeSmall_H,

		onEvent = function(event) 
			if "ended" == event.phase then
			
				--print("RATE")
				system.openURL( "itms-apps://itunes.apple.com/app/id959398889")--Downhill Dash
				--system.openURL( "itms-apps://itunes.apple.com/app/id817950936")--Floppy Fin


				rateText.text = "Your game will return shortly.  Please take this time to rate. Thanks!"

				rate_YES.isVisible = false
				rate_NO.isVisible = false
				rate_appStore.isVisible = true

				local _time = os.date( '*t' )  -- get table of current date and time
				_time = tonumber( os.time( _time ) )

				dbfunctions.updateTableValue("generalSettings", "rate", "value", "inProgress")
				dbfunctions.updateTableValue("generalSettings", "rateStart", "value", _time)

				rateTimer.isVisible = true
				rateTimer.timer = tickTock
				rateTimer.timerHandle = timer.performWithDelay(250,rateTimer,0)
				tickTock()

				analytics.logEvent( "RateMenu", {Rate = "Yes"})
			end
		end
	}
	rate_YES.x = rateMenu.x + 150
	rate_YES.y = rateMenu.y + 225

	--print( rateMenu.x )
	rate_appStore =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_AppStore.png",
		width = sizeSmall_W,
		height = sizeSmall_H,

		onEvent = function(event) 
			if "ended" == event.phase then
			
				--print("RATE")
				system.openURL( "itms-apps://itunes.apple.com/app/id959398889")--Downhill Dash
				--system.openURL( "itms-apps://itunes.apple.com/app/id817950936")--Floppy Fin

				--dbfunctions.updateTableValue("generalSettings", "rate", "value", "yes")

				analytics.logEvent( "RateMenu", {Rate = "Go Back To App Store"})
			end
		end
	}
	rate_appStore.x = rateMenu.x
	rate_appStore.y = rateMenu.y + 225
	rate_appStore.isVisible = false
	
	local tempValue = dbfunctions.getTableValue("generalSettings", "rate", "value")

	if tempValue == "inProgress" then
		rateText.text = "Your game will return shortly.  Please take this time to rate, Thanks!"

		rate_YES.isVisible = false
		rate_NO.isVisible = false
		rate_appStore.isVisible = true

		rateTimer.isVisible = true
		rateTimer.timer = tickTock
		rateTimer.timerHandle = timer.performWithDelay(250,rateTimer,0)
		tickTock()
	end
end




---------------------------------------------------------------------------------

function scene:create( event )

	local sceneGroup = self.view

	--print("--==| CREATE SCENE rate|==--")
	createButtons()

	scene.view:insert(rateMenu )
	scene.view:insert(rateText )
	scene.view:insert(rateTimer )
	scene.view:insert(rate_NO )
	scene.view:insert(rate_YES )
	scene.view:insert(rate_appStore )
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		--print("--==| SHOW SCENE rate|==--")
	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		--print("--==| HIDE SCENE rate|==--")
	end
end

function scene:destroy( event )

	local sceneGroup = self.view

	--print("--==| DESTROY SCENE rate|==--")
	destroyScene()
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene