local composer = require( "composer" )
local scene = composer.newScene()

---------------------------------------------------------------------------------
--| GLOBAL VARIABLES |--
	--ADS_SHOWING
	--CURRENT_STAGE
	--CURRENT_STAGE_VALUE

---------------------------------------------------------------------------------
--| VARIABLES |--
	local _W = display.contentWidth
	local _H = display.contentHeight

	local _W_Orig = display.pixelWidth
	local _H_Orig = display.pixelHeight

	local _W_Real = (_W_Orig / _H_Orig) * _H
	local _H_Real = (_H_Orig / _W_Orig) * _W

	local _offset = 500
	local _miliseconds = 250
	local _color = 0.75
	local _scale = 0.75
	local _font = "HelveticaNeue-Light"
	local _fontSizeSmall = 60

	local regionTable = {
			{environment = "tutorial", first = 1, last = 2, length = 0, stageImage = "Stage_Tutorial.png"},
			{environment = "Bunny Hill", first = 1, last = 2, length = 30000, stageImage = "Stage_BunnyHill.png"},
			{environment = "Back Country", first = 1, last = 2, length = 30000, stageImage = "Stage_BackCountry.png"},
			{environment = "Wilderness", first = 1, last = 2, length = 30000, stageImage = "Stage_Wilderness.png"},
			{environment = "Town", first = 1, last = 5, length = 45000, stageImage = "Stage_Town.png"},
			{environment = "Forest", first = 1, last = 3, length = 60000, stageImage = "Stage_Forest.png"},
			{environment = "Ski Park", first = 1, last = 2, length = 60000, stageImage = "Stage_SkiPark.png"},
			{environment = "City", first = 1, last = 3, length = 60000, stageImage = "Stage_City.png"},
			--{environment = "Wasteland", first = 1, last = 1, length = 60000},
			{environment = "Military Camp", first = 1, last = 5, length = 90000, stageImage = "Stage_MilitaryCamp.png"},
			{environment = "Random", first = 1, last = 5, length = 9999999999999999},
		}

	local sizeBtnSq = 325

	local sizeSmall_W = 550
	local sizeSmall_H = 150

	local sizeLarge_W = sizeSmall_W * 1.5
	local sizeLarge_H = sizeSmall_H * 1.5

	local salpha = 0.95
	local dalpha = 0.75

	local highy = 900
	local midy = 500
	local lowy = 250

	local stageButtonTable = {}

	--Display Objects
	local btn_Play
	local btn_LeaderBoards
	local btn_CustomCharacter
	local btn_Start
	local btn_Back
	local txt_HighScore

	local introLoopingSound = audio.loadSound("soundClips/introLoopingSound.wav")

---------------------------------------------------------------------------------
--| REQUIRE |--
	require("sqlite3") 
	local dbfunctions = require("dbfunctions")
		dbfunctions.init("dbGear.db")
	local manageSounds = require("manageSounds")
	
	local gameNetwork = require( "gameNetwork" )
	
	--==|Ads|==--
	local ads = require( "ads" )
	local appID = "ca-app-pub-6363387017327952/2841428229"
	local adNetwork = "admob"
	--local adNetwork = "iads"
	--local appID = "com.goldenegg.downhilldash"
	ads.init( adNetwork, appID, adListener )

	--local function adListener( event )
	    --(more on this later)
	--end


--[[monitorMem 
	local monitorMem = function()

		collectgarbage()
		print( "MemUsage: " .. collectgarbage("count") )

		local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
		print( "TexMem: " .. textMem )
	end
	 
	Runtime:addEventListener( "enterFrame", monitorMem )
--]]

---------------------------------------------------------------------------------
--| FUNCTIONS |--

local function destroyScene()

	--print("DESTORY SCENE")

	display.remove( btn_Play ); btn_Play = nil
	display.remove( btn_LeaderBoards ); btn_LeaderBoards = nil
	display.remove( btn_CustomCharacter ); btn_CustomCharacter = nil
	display.remove( btn_Start ); btn_Start = nil
	display.remove( btn_Back ); btn_Back = nil
	display.remove( txt_HighScore ); txt_HighScore = nil

	display.remove( touchBar ); touchBar = nil

	if stageButtonTable ~= nil then
		for i = 1,#stageButtonTable do
			display.remove( stageButtonTable[i] )
		end
	end
	stageButtonTable = nil

	if txt_FreeCoins ~= nil then
		transition.cancel( txt_FreeCoins )
		display.remove( txt_FreeCoins )
	end

	if image_FreeCoins ~= nil then
		transition.cancel( image_FreeCoins )
		display.remove( image_FreeCoins )
	end
end

local function findPositions()

	for i = 1,#stageButtonTable do

		if stageButtonTable[i].region == CURRENT_STAGE then
			if i-2 >= 1 then
				stageFarLeft = stageButtonTable[i-2]
			else
				stageFarLeft = nil
			end

			if i-1 >= 1 then
				stageLeft = stageButtonTable[i-1]
			else
				stageLeft = nil
			end

			stageMiddle = stageButtonTable[i]

			if i+1 <= FURTHEST_STAGE_VALUE then
				stageRight = stageButtonTable[i+1]
			else
				stageRight = nil
			end

			if i+2 <= FURTHEST_STAGE_VALUE then
				stageFarRight = stageButtonTable[i+2]
			else
				stageFarRight = nil
			end
		end
	end
end

local function slide(direction)

	if direction == "left"
	and stageRight ~= nil then

		if stageLeft ~= nil then
			transition.to(stageLeft, {x = _W/2-_offset*2,
				time = _miliseconds } )
		end

		if stageMiddle ~= nil then
			transition.to(stageMiddle, {x = _W/2-_offset,
				xScale = _scale,
				yScale = _scale,
				time = _miliseconds } )
				stageMiddle:setFillColor(_color,_color,_color)
		end

		if stageRight ~= nil then
			transition.to(stageRight, {x = _W/2,
				xScale = 1,
				yScale = 1,
				time = _miliseconds } )
				stageRight:setFillColor(1,1,1)
		end

		if stageFarRight ~= nil then
			stageFarRight.x = _W/2+_offset*2
			stageFarRight.y =  _H_Real - lowy
			stageFarRight.xScale = _scale
			stageFarRight.yScale = _scale
			stageFarRight:setFillColor(0.7,0.7,0.7)

			transition.to(stageFarRight, {x = _W/2+_offset,
				time = _miliseconds } )
				
		end


		stageMiddle = stageRight

	elseif direction == "right"
	and stageLeft ~= nil then

		if stageFarLeft ~= nil then
			stageFarLeft.x = _W/2-_offset*2
			stageFarLeft.y = _H_Real - lowy
			stageFarLeft.xScale = _scale
			stageFarLeft.yScale = _scale
			stageFarLeft:setFillColor(0.7,0.7,0.7)

			transition.to(stageFarLeft, {x = _W/2-_offset,
				time = _miliseconds } )
		end

		if stageLeft ~= nil then
			transition.to(stageLeft, {x = _W/2,
				xScale = 1,
				yScale = 1,
				time = _miliseconds } )
			stageLeft:setFillColor(1,1,1)
		end

		if stageMiddle ~= nil then
			transition.to(stageMiddle, {x = _W/2+_offset,
				xScale = _scale,
				yScale = _scale,
				time = _miliseconds } )
				stageMiddle:setFillColor(_color,_color,_color)
		end

		if stageRight ~= nil then
			transition.to(stageRight, {x = _W/2+_offset*2,
				xScale = _scale,
				yScale = _scale,
				time = _miliseconds } )
		end

		stageMiddle = stageLeft	
	end

	CURRENT_STAGE = stageMiddle.region
	--print(CURRENT_STAGE)
	CURRENT_STAGE_VALUE = stageMiddle.regionIndex
	--print(CURRENT_STAGE_VALUE)
	findPositions()
end

local function change(event)

	if event.phase == "began" then
		stageSelectTouch = true

	elseif event.phase == "moved" 
	and stageSelectTouch == true then

		if event.x - event.xStart < 0 
		and math.abs(event.x - event.xStart) > 100 then 
			
			stageSelectTouch = false
			slide("left")

		elseif event.x - event.xStart > 0 
		and math.abs(event.x - event.xStart) > 100 then

			stageSelectTouch = false
			slide("right")	
		end
	end
end

local function createStageButtons()

	--print("Select Stage")

	touchBar = display.newRect( _W/2, _H_Real-250, _W, 400 )
	touchBar.alpha = 0.5
	touchBar.isVisible = false
	touchBar.isHitTestable = true
	touchBar:addEventListener("touch",change)
	--gforeground3:insert( touchBar )

	for i = 1,#regionTable-1 do
		local id = #stageButtonTable+1
		stageButtonTable[id] = display.newImage("images/mainMenu/"..regionTable[i].stageImage)
		stageButtonTable[id].x = -500
		stageButtonTable[id].y = -500
		stageButtonTable[id].region = regionTable[i].environment
		stageButtonTable[id].regionIndex = id
		scene.view:insert( stageButtonTable[id] )
	end

	--CURRENT_STAGE = "Forest"
	--print(CURRENT_STAGE)

	for i = 1,#stageButtonTable do
		if stageButtonTable[i].region == CURRENT_STAGE then
			CURRENT_STAGE_VALUE = i
			break
		end
	end

	for i = 1,#stageButtonTable do
		if stageButtonTable[i].region == FURTHEST_STAGE then
			FURTHEST_STAGE_VALUE = i
			break
		end
	end
		
	if CURRENT_STAGE_VALUE > 2 then
		stageFarLeft = stageButtonTable[CURRENT_STAGE_VALUE-2]
		stageFarLeft.x = _W/2-_offset*2
		stageFarLeft.y = _H_Real - lowy
		stageFarLeft.xScale = _scale
		stageFarLeft.yScale = _scale
		stageFarLeft:setFillColor(_color,_color,_color)
	end

	if CURRENT_STAGE_VALUE > 1 then
		stageLeft = stageButtonTable[CURRENT_STAGE_VALUE-1]
		stageLeft.x = _W/2-_offset
		stageLeft.y = _H_Real - lowy
		stageLeft.xScale = _scale
		stageLeft.yScale = _scale
		stageLeft:setFillColor(_color,_color,_color)
	end

	stageMiddle = stageButtonTable[CURRENT_STAGE_VALUE]
	stageMiddle.x = _W/2
	stageMiddle.y = _H_Real - lowy

	if CURRENT_STAGE_VALUE+1 <= FURTHEST_STAGE_VALUE then
		stageRight = stageButtonTable[CURRENT_STAGE_VALUE+1]
		stageRight.x = _W/2+_offset
		stageRight.y = _H_Real - lowy
		stageRight.xScale = _scale
		stageRight.yScale = _scale
		stageRight:setFillColor(_color,_color,_color)
	end

	if CURRENT_STAGE_VALUE+2 <= FURTHEST_STAGE_VALUE then
		stageFarRight = stageButtonTable[CURRENT_STAGE_VALUE+2]
		stageFarRight.x = _W/2+_offset*2
		stageFarRight.y = _H_Real - lowy
		stageFarRight.xScale = _scale
		stageFarRight.yScale = _scale
		stageFarRight:setFillColor(_color,_color,_color)
	end

	btn_Start.isVisible = true
end

local function showHideMainButtons(_isVisible)
	btn_Play.isVisible = _isVisible
	btn_LeaderBoards.isVisible = _isVisible
	btn_CustomCharacter.isVisible = _isVisible
end

local function showHideStageButtons(_isVisible)

	--print("showHideStageButtons", _isVisible)

	if stageButtonTable[1] ~= nil then
		for i = 1,#stageButtonTable do
			stageButtonTable[i].isVisible = _isVisible
		end
	elseif stageButtonTable[1] == nil
	and _isVisible == true then
		createStageButtons()
	end

	btn_Back.isVisible = _isVisible
	btn_Start.isVisible = _isVisible
end

local function grow(tempObject)

	tempObject.transitionHandle = nil

	tempObject.transitionHandle = transition.to(tempObject, {
		xScale = tempObject.xScale*1.1,
		yScale = tempObject.yScale*1.1,
		time = 500,
		onComplete = shrinkButton }
	)
end

function shrinkButton(tempObject)

	tempObject.transitionHandle = nil

	tempObject.transitionHandle = transition.to(tempObject, {
		xScale = tempObject.xScale/1.1,
		yScale = tempObject.yScale/1.1,
		time = 500,
		onComplete = grow }
	)
end

function removeExtras(tempObject)

	transition.cancel( tempObject.transitionHandle )
	display.remove(tempObject)
	tempObject = nil
end




--GO TO LOCATIONS
local function go_gameScene()

	--print("GO TO Game Scene")
	txt_HighScore.isVisible = false
	btn_Back.isVisible = false
	composer.hideOverlay( "flip",125 )
	
	ads.hide()
	ADS_SHOWING = nil

	local options = {
		params = {
	        startGame = true
	    }
	}
	composer.gotoScene("game",options)	
end

local function go_LeaderBoards()

	--print("GO TO Leader Boards")
	
	
	
		
	-- Show leaderboard panel
		gameNetwork.show( "leaderboards", { leaderboard={ category="com.goldenegg.downhilldash.highscore" } } )

	--[[ Submit high score
		gameNetwork.request( "setHighScore",
			{
				localPlayerScore = { category=composer.getVariable( "currentLeaderboardID" ), value=composer.getVariable( "currentScore" ) },
				listener = requestCallback
			}
	
		)
	]]
		--gameNetwork.show( "leaderboards" )

	--showHideMainButtons(false)
	--btn_Back.isVisible = true
end

local function go_CustomCharacter()

	--print("GO TO Custom Character")
	--[[local options = {
		isModal = true,
		effect = "fromBottom",
		time = 500
	}
	composer.loadScene("customizeCharacter")]]
	local options = {
		isModal = true,
		effect = "fade",
		time = 500
	}
	composer.showOverlay( "customizeCharacter",options )
end

local function go_Rate()

	--print("GO TO Rate")
	txt_HighScore.isVisible = false
	composer.hideOverlay( "flip",125 )
	
	local options = {
		isModal = true,
		effect = "fade",
		time = 500
	}
	composer.showOverlay( "rateMenu",options )
end





--SETUP
local function getCurrentStage()
	if CURRENT_STAGE == nil then
		FURTHEST_STAGE = dbfunctions.getTableValue("generalSettings", "furthestStage", "value")
		--FURTHEST_STAGE = "militaryCamp"
		CURRENT_STAGE = FURTHEST_STAGE
		--print("getCurrentStage")
	end
end

local function createButtons()

	btn_LeaderBoards =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_LeaderBoards.png",
		font = _font,
		--fontSize = 50,
		--label = "Leader Boards",
		width = sizeSmall_W,
		height = sizeSmall_H,
		cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				go_LeaderBoards()
			end
		end
	}
	--btn_LeaderBoards.anchorX = 0.5
	btn_LeaderBoards.anchorY = 1
	btn_LeaderBoards.x = _W*1/4
	btn_LeaderBoards.y = _H_Real - lowy
	btn_LeaderBoards.alpha = salpha


	btn_Play =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_Play.png",
		font = _font,
		--fontSize = 75,
		--label = "Play",
		width = sizeLarge_W,
		height = sizeLarge_H,
		cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				showHideMainButtons(false)
				showHideStageButtons(true)
			end
		end
	}
	--btn_Play.anchorX = 0.5
	btn_Play.anchorY = 1
	btn_Play.x = _W*2/4
	btn_Play.y = _H_Real - midy
	btn_Play.alpha = salpha


	btn_CustomCharacter =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_CustomizeCharacter.png",
		font = _font,
		--fontSize = 50,
		--label = "Custom Character",
		width = sizeSmall_W,
		height = sizeSmall_H,
		cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then

				local tempValue = dbfunctions.getTableValue("generalSettings", "rate", "value")
				--print(tempValue)

				if tempValue == "no" then
					go_Rate()
				elseif tempValue == "inProgress" then
					go_Rate()
				else
					go_CustomCharacter()
				end

			end
		end
	}
	--btn_CustomCharacter.anchorX = 0.5
	btn_CustomCharacter.anchorY = 1
	btn_CustomCharacter.x = _W*3/4
	btn_CustomCharacter.y = _H_Real - lowy
	btn_CustomCharacter.alpha = salpha

	local rated = dbfunctions.getTableValue("generalSettings", "rate", "value")
	local myCoins = dbfunctions.getTableValue("generalSettings", "coins", "value")
	myCoins = tonumber( myCoins )
	if rated == "no"
	and myCoins >= 100 then
		btn_CustomCharacter.transitionHandle = transition.to(btn_CustomCharacter, {
			xScale = btn_CustomCharacter.xScale*1.1,
			yScale = btn_CustomCharacter.yScale*1.1,
			time = 500,
			onComplete = shrinkButton }
		)
	end

	btn_Back =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_Back.png",
		font = _font,
		--fontSize = 50,
		--label = "Back",
		width = sizeSmall_W/2,
		height = sizeSmall_H +  30,
		--cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				--print(stageButtonTable[1])
				showHideStageButtons(false)
				showHideMainButtons(true)
			end
		end
	}
	--btn_Back.anchorX = 0.5
	btn_Back.anchorY = 1
	btn_Back.x = _W-150
	btn_Back.y = _H_Real - midy - 15
	btn_Back.alpha = salpha
	btn_Back.isVisible = false


	btn_Start =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_Start.png",
		font = _font,
		--fontSize = 75,
		--label = "Start",
		width = sizeLarge_W,
		height = sizeLarge_H,
		cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				go_gameScene()
			end
		end
	}
	--btn_Start.anchorX = 0.5
	btn_Start.anchorY = 1
	btn_Start.x = _W*2/4
	btn_Start.y = _H_Real - midy
	btn_Start.alpha = salpha
	btn_Start.isVisible = false
	
	
	local score = dbfunctions.getTableValue("generalSettings", "score", "value")
	local options = 
		{
		    --parent = textGroup,
		    text = "High Score: "..score,
		    x = 100,
		    font = _font,   
		    fontSize = _fontSizeSmall,
		    align = "right"  --new alignment parameter
		}
	txt_HighScore = display.newText( options )
	txt_HighScore:setFillColor(1,1,1)
	txt_HighScore.anchorY = 0
	txt_HighScore.anchorX = 0

	local bannerAdState = dbfunctions.getTableValue("generalSettings", "bannerAds", "value")
	
	if bannerAdState == "on" then
		txt_HighScore.y = 275
		if ADS_SHOWING == nil then
			ads.show( "banner", { x=adX, y=adY, appId=appID } )
		end
	else
		txt_HighScore.y = 75
	end
end


---------------------------------------------------------------------------------

function scene:create( event )

	--print("--==| CREATED SCENE mainMenu|==--")
	local sceneGroup = self.view
	
	createButtons()

	sceneGroup:insert(btn_Play)
	sceneGroup:insert(btn_LeaderBoards)
	sceneGroup:insert(btn_CustomCharacter)
	sceneGroup:insert(btn_Start)
	sceneGroup:insert(btn_Back)
	sceneGroup:insert(txt_HighScore)
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		audio.stop( 1 )

	elseif ( phase == "did" ) then

		--print("--==| SHOW SCENE mainMenu|==--")

		local musicState = dbfunctions.getTableValue("generalSettings", "music", "value")
		if musicState == "on" then
			manageSounds.createSound(introLoopingSound,0.125,20000, 5000)
		end
		
		--Check for Free Coins
		if FREE_COINS ~= nil then

			--txt_FreeCoins
			local options = 
				{
				    --parent = textGroup,
				    text = "+ "..FREE_COINS,     
				    x = 100,
				    y = 75,
				    --width = 460,    --required for multi-line
				    --height = 0,     --required for multi-line and alignment
				    font = _font,   
				    fontSize = _fontSizeSmall,
				    align = "right"  --new alignment parameter
				}
			txt_FreeCoins = display.newText( options )
			txt_FreeCoins:setFillColor(1,1,1)
			txt_FreeCoins.anchorY = 0.5
			txt_FreeCoins.anchorX = 1
			txt_FreeCoins.x = _W/2
			txt_FreeCoins.y = _H/2

			txt_FreeCoins.transitionHandle = transition.to(txt_FreeCoins, {
				alpha = 0,
				time = 1500,
				onComplete = removeExtras }
			)
			scene.view:insert( txt_FreeCoins )

			--image_FreeCoins
			image_FreeCoins = display.newImage( "images/mainMenu/coin_glare.png")
			image_FreeCoins.x = txt_FreeCoins.x + 100
			image_FreeCoins.y = txt_FreeCoins.y
			image_FreeCoins.xScale = 0.4
			image_FreeCoins.yScale = 0.4

			image_FreeCoins.transitionHandle = transition.to(image_FreeCoins, {
				alpha = 0,
				time = 1500,
				onComplete = removeExtras }
			)
			scene.view:insert( image_FreeCoins )
			
			FREE_COINS = nil
		end
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		--print("--==| HIDE SCENE mainMenu|==--")
		--print(CURRENT_STAGE)

		--composer.removeScene( "mainMenu", false ) 
	end
end

function scene:destroy( event )

	--print("--==| DESTROYED SCENE mainMenu|==--")

	local sceneGroup = self.view
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