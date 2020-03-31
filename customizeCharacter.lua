local composer = require( "composer" )
local scene = composer.newScene()

---------------------------------------------------------------------------------
--| VARIABLES |--
--ADS_SHOWING

---------------------------------------------------------------------------------
--| VARIABLES |--
	local _W = display.contentWidth
	local _H = display.contentHeight

	local _W_Orig = display.pixelWidth
	local _H_Orig = display.pixelHeight

	local _W_Real = (_W_Orig / _H_Orig) * _H
	local _H_Real = (_H_Orig / _W_Orig) * _W

	local newRecordSound = audio.loadSound("soundClips/newRecordSound.mp3")
	local introLoopingSound = audio.loadSound("soundClips/introLoopingSound.wav")

	local gbackground = display.newGroup()
	local gground = display.newGroup()
	local gforeground1 = display.newGroup()
	local gforeground2 = display.newGroup()

	local sizeSmall_W = 550
	local sizeSmall_H = 150

	local _alphaPressed = 0.9
	local _alphaReleased = 0.5

	local _alphaTextPressed = 1
	local _alphaTextReleased = 0.6

	local _characterX = _W/2 + 150
	local _characterY = _H_Real - 900

	--DISPLAY OBJECTS
	local loadedGearTextureTable = {}
	local viewGearTable = {
				{},
				{},
				{},
				{},
				}

	local secBtnTable = {}
	local screenElementsTable = {}

	local btn_Purchase
	local btn_Back
	local txt_Coins
	local loadingImage

	local coinsImage
	local btn_AddCoins
	local btn_Music
	--local btn_Music.offImage
	local btn_Sound
	--local btn_Sound.offImage

	local screen
	local AddCoinsMenu
	local txt_MoreCoins
	local txt_MoreCoinsState
	local btn_Start
	local btn_Stop
	local btn_Done
	local btn_IAP_50k
	
	local _font = "HelveticaNeue-Light"
	local _fontSize = 60
	
	local platform = system.getInfo( "platformName" )
	if platform == "Mac OS X" or platform == "Win" then
		platform = system.getInfo("environment") -- For ease in checking platforms later
	end

---------------------------------------------------------------------------------
--| GLOBAL REQUIRE |--
	--local analytics = require( "analytics" )
	--analytics.init("S52RN5ZNSBDH26MY9ZWK")
	--ADS_SHOWING = nil

---------------------------------------------------------------------------------
--| REQUIRE |--
	require("sqlite3")
	local rate = require("rateMenu")
	local dbfunctions = require("dbfunctions")
	dbfunctions.init("dbGear.db")
	local manageSounds = require("manageSounds")
	
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
	
	--IN APP PURCHASES
	-- Init Store
	local store = require ( "store" ) -- Available in Corona build #261 or later

	-- Unbuffer console output for debugging 
	--io.output( ):setvbuf( 'no' )  -- Remove me for production code
	
---------------------------------------------------------------------------------
--| FUNCTION |--

local function recycle2(obj)

	display.remove(obj)
	obj = nil
end

local function destroyScene2()

	Runtime:removeEventListener( "enterFrame", onEveryFrame2 )

	for i = #viewGearTable,1,-1 do
		display.remove( viewGearTable[i].image )
		table.remove( viewGearTable, i )
	end
	viewGearTable = nil

	if sledImage ~= nil then
		if sledImage.decal ~= nil then
			recycle2(sledImage.decal)
		end
	end
	recycle2(sledImage)

	for i = #screenElementsTable,1,-1 do
		if screenElementsTable[i].transitionHandle ~= nil then
			transition.cancel( screenElementsTable[i].transitionHandle )
		end
		display.remove( screenElementsTable[i] )
		table.remove( screenElementsTable, i )
	end
	screenElementsTable = nil

	for i = #mainBtnTable,1,-1 do
		display.remove( mainBtnTable[i] )
		display.remove( mainBtnTable[i].imagePressed )
		display.remove( mainBtnTable[i].imageText )
	end
	mainBtnTable = nil

	for i = #secBtnTable,1,-1 do
		display.remove( secBtnTable[i] )
		display.remove( secBtnTable[i].imagePressed )
		display.remove( secBtnTable[i].imageLockedReleased )
		display.remove( secBtnTable[i].imageLockedPressed )
		display.remove( secBtnTable[i].imageText )
	end
	secBtnTable = nil
	
	for i = #loadedGearTextureTable,1,-1 do
		display.remove( loadedGearTextureTable[i] )
	end
	loadedGearTextureTable = nil

	display.remove( btn_Purchase ); btn_Purchase = nil
	display.remove( btn_Back ); btn_Back = nil
	display.remove( txt_Coins); txt_Coins = nil
	display.remove( loadingImage); loadingImage = nil
	display.remove( coinsImage ); coinsImage = nil
	display.remove( btn_AddCoins ); btn_AddCoins = nil
	display.remove( btn_Sound.offImage ); btn_Sound.offImage = nil
	display.remove( btn_Sound ); btn_Sound = nil
	display.remove( btn_Music.offImage ); btn_Music.offImage = nil
	display.remove( btn_Music ); btn_Music = nil
end

--dbfunctions.updateTableValue("generalSettings", "coins", "value", 50000)

--SPRITE Functions
local function frontOrder()

	if viewGearTable[3].image ~= nil then
		viewGearTable[3].image:toFront()
	end

	if viewGearTable[2].image ~= nil then
		viewGearTable[2].image:toFront()
	end

	if viewGearTable[4].image ~= nil then
		viewGearTable[4].image:toFront() --Head
	end

	if viewGearTable[1].image ~= nil then
		viewGearTable[1].image:toFront()
	end
end

local function createHead()

	local sheetData = { 
		width=184,
		height=189,
		numFrames=28,
		sheetContentWidth=2024,
		sheetContentHeight=567
	}


	local _offsetX = -34
	local _offsetY = -148

	log_Sheet = graphics.newImageSheet( "images/gearCC/Head_Custom.png", sheetData)

	log_sequenceData = {
		{name = "normal", start = 1, count = 28, time=2000, loopCount=0}
		}

		
	viewGearTable[4].image = display.newSprite( log_Sheet, log_sequenceData)
	viewGearTable[4].image.timeScale = 1
	viewGearTable[4].image.xScale = 2
	viewGearTable[4].image.yScale = 2
	viewGearTable[4].image:setFrame(1)
	viewGearTable[4].image:play()
	
	viewGearTable[4].image.x = _characterX + _offsetX*2
	viewGearTable[4].image.y = _characterY + _offsetY*2

	gground:insert( viewGearTable[4].image )
	frontOrder()
end

local function createHat(tempImage)

	recycle2(viewGearTable[1].image)

	local sheetData = { 
		width=222,
		height=180,
		numFrames=28,
		sheetContentWidth=1998,
		sheetContentHeight=720
	}


	local _offsetX = -14+34
	local _offsetY = -184+148

	log_Sheet = graphics.newImageSheet( "images/gearCC/"..tempImage, sheetData)

	log_sequenceData = {
		{name = "normal", start = 1, count = 28, time=2000, loopCount=0}
		}

		
	viewGearTable[1].image = display.newSprite( log_Sheet, log_sequenceData)
	viewGearTable[1].image.timeScale = 1
	viewGearTable[1].image.xScale = 2
	viewGearTable[1].image.yScale = 2
	viewGearTable[1].image:setFrame(1)
	--viewGearTable[1].image:play()
	
	viewGearTable[1].image.x = viewGearTable[4].image.x + _offsetX*2
	viewGearTable[1].image.y = viewGearTable[4].image.y + _offsetY*2

	gground:insert( viewGearTable[1].image )
	viewGearTable[1].image:toFront()
	frontOrder()
	--viewGearTable[1].image:setFillColor(TABLE.r,TABLE.g,TABLE.b)--1,0,0 for blue image
end

local function createJacket(tempImage, _x, _y)

	recycle2(viewGearTable[2].image)

	local sheetData = { 
		width=187,
		height=279,
		numFrames=28,
		sheetContentWidth=1870,
		sheetContentHeight=837
	}


	local _offsetX = 0
	local _offsetY = 12


	if tempImage == false then
		log_Sheet = graphics.newImageSheet( "images/gearCC/Jacket_Locked_Custom.png", sheetData)
	elseif tempImage ~= false then
		log_Sheet = graphics.newImageSheet( "images/gearCC/"..tempImage, sheetData)
	end

	
	log_sequenceData = {
		{name = "normal", start = 1, count = 28, time=2000, loopCount=0}
		}
	
	viewGearTable[2].image = display.newSprite( log_Sheet, log_sequenceData)
	viewGearTable[2].image.timeScale = 1
	viewGearTable[2].image.xScale = 2
	viewGearTable[2].image.yScale = 2
	viewGearTable[2].image:setFrame(1)
	--viewGearTable[2].image:play()
	
	viewGearTable[2].image.x = _characterX + _offsetX*2
	viewGearTable[2].image.y = _characterY + _offsetY*2

	gground:insert( viewGearTable[2].image )
	frontOrder()
end

local function createPants(tempImage)

	recycle2(viewGearTable[3].image)

	local sheetData = { 
		width=131,
		height=224,
		numFrames=28,
		sheetContentWidth=1965,
		sheetContentHeight=450
	}


	local _offsetX = 4+34
	local _offsetY = 170+148

	log_Sheet = graphics.newImageSheet( "images/gearCC/"..tempImage, sheetData)

	log_sequenceData = {
		{name = "normal", start = 1, count = 28, time=2000, loopCount=0}
		}

		
	viewGearTable[3].image = display.newSprite( log_Sheet, log_sequenceData)
	viewGearTable[3].image.timeScale = 1
	viewGearTable[3].image.xScale = 2
	viewGearTable[3].image.yScale = 2
	viewGearTable[3].image:setFrame(1)
	--viewGearTable[3].image:play()
	
	viewGearTable[3].image.x = viewGearTable[4].image.x + _offsetX*2
	viewGearTable[3].image.y = viewGearTable[4].image.y + _offsetY*2

	gground:insert( viewGearTable[3].image )
	viewGearTable[3].image:toBack()
	frontOrder()
	--viewGearTable[1].image:setFillColor(TABLE.r,TABLE.g,TABLE.b)
end

local function createSled(tempImage, _color)

	if _color == nil then
		_color = 1
	end

	recycle2(sledImage)
	if sledImage ~= nil then
		if sledImage.decal ~= nil then
			recycle2(sledImage.decal)
		end
	end

	sledImage = display.newImage("images/gearCC/"..tempImage)
	sledImage.x = 750
	sledImage.y = _H_Real-698
	sledImage.xScale = 1
	sledImage.yScale = 1

	sledImage:setFillColor( _color, _color, _color )

	gground:insert( sledImage )

	--Thrusters
	if tempImage == "Sled_Turbo_MainMenu.png" then
		tempImageDecal = "Sled_TurboFlames_MainMenu.png"

		local sheetData = { 
			width=476,
			height=287,
			numFrames=10,
			sheetContentWidth=1904,
			sheetContentHeight=861
		}


		local _offsetX = -230
		local _offsetY = 134


		local _offsetX = -220
		local _offsetY = 186

		log_Sheet = graphics.newImageSheet( "images/gearCC/"..tempImageDecal, sheetData)

		
		log_sequenceData = {
			{name = "normal", start = 1, count = 10, time=400, loopCount=0}
			}
		
		sledImage.decal = display.newSprite( log_Sheet, log_sequenceData)
		sledImage.decal.timeScale = 1
		sledImage.decal.xScale = 1
		sledImage.decal.yScale = 1
		sledImage.decal:setFrame(1)
		sledImage.decal:play()
		
		sledImage.decal.x = sledImage.x + _offsetX--100
		sledImage.decal.y = sledImage.y + _offsetY

		sledImage.decal:setFillColor( _color, _color, _color )

		gground:insert( sledImage.decal )
		sledImage.decal:toBack()
	end
	
	sledImage:toBack()
end



local function createLock( _index)

	if TEMP_gearTable ~= "sledTable" then

		local height
		local gearCost
		
		local id = #screenElementsTable + 1

		local sheetData = { 
			width=340,
			height=478,
			numFrames=19,
			sheetContentWidth=2040,
			sheetContentHeight=1912
		}

		local sheet = graphics.newImageSheet( "images/gearCC/lock_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 19, time=1500, loopCount=0}
			}
			
		screenElementsTable[id] = display.newSprite( sheet, sequenceData)
		screenElementsTable[id].timeScale = 1
		screenElementsTable[id].xScale = 0.75
		screenElementsTable[id].yScale = 0.75
		screenElementsTable[id]:setFrame(1)
		screenElementsTable[id]:play()

		screenElementsTable[id].type = "lock"
		
		screenElementsTable[id].x = _characterX

		if TEMP_gearTable == "hatTable" then
			height = _H_Real - 1500
		elseif TEMP_gearTable == "jacketTable" then
			height = _H_Real - 900
		elseif TEMP_gearTable == "pantsTable" then
			height = _H_Real - 600
		elseif TEMP_gearTable == "sledTable" then
			height = _H_Real - 300
		end
		screenElementsTable[id].y = height

		gforeground1:insert( screenElementsTable[id] )
	end




		local id = #screenElementsTable + 1

		for i = 1,#secBtnTable do
			if secBtnTable[i].state == "pressed"
			or secBtnTable[i].state == "lockedPressed" then
				gearCost = dbfunctions.getTableValue(TEMP_gearTable, _index, "cost")
				gearCost = tonumber( gearCost )
			end
		end
	
		local options = 
			{
			    text = "Cost: "..gearCost,     
			    x = _W - 100,
			    y = _H_Real-600,
			    font = _font,   
			    fontSize = _fontSize,
			    align = "center"  --new alignment parameter
			}
		screenElementsTable[id] = display.newText( options )
		screenElementsTable[id].type = "cost"
		screenElementsTable[id]:setFillColor(0,0,0)
		screenElementsTable[id].anchorY = 0
		screenElementsTable[id].anchorX = 1
end

local function removeLock()

	for i = #screenElementsTable,1,-1 do
		if screenElementsTable[i].type == "lock" 
		or screenElementsTable[i].type == "cost" then
			display.remove( screenElementsTable[i] )
			table.remove( screenElementsTable, i )
		end
	end
end



--GENERAL Functions
local function secBtn_touched(event, self)

	--_alphaReleased = 0.25

	
	if event.phase == "ended"
	and event.target.state ~= "pressed" then

		for i = 1,#secBtnTable do

			if secBtnTable[i].state == "pressed" then
				secBtnTable[i].state = "released"
				secBtnTable[i].imagePressed.isVisible = false
				secBtnTable[i].isVisible = true
				

			elseif secBtnTable[i].state == "lockedPressed" then
				secBtnTable[i].state = "lockedReleased"
				secBtnTable[i].imageLockedPressed.isVisible = false
				secBtnTable[i].imageLockedReleased.isVisible = true
			end

			secBtnTable[i].imageText.alpha = _alphaTextReleased
			
		end

		if secBtnTable[event.target.position].state == "released" then
			secBtnTable[event.target.position].state = "pressed"
			secBtnTable[event.target.position].imagePressed.isVisible = true
		else
			secBtnTable[event.target.position].state = "lockedPressed"
			secBtnTable[event.target.position].imageLockedPressed.isVisible = true
		end

		event.target.isVisible = false
		event.target.imageText.alpha = _alphaTextPressed





		btn_Purchase.isVisible = false
		removeLock()

		
		
		index = event.target.position--table.indexOf(secBtnTable, event)
		newUnlocked = dbfunctions.getTableValue(TEMP_gearTable, index, "unlocked")

		if newUnlocked == "yes" then
			--Part 1 set all values to false
			for i = 1,5 do
			
				unlocked = dbfunctions.getTableValue(TEMP_gearTable, i, "selected")

				if unlocked == "yes" then
					dbfunctions.updateTableValue(TEMP_gearTable, i, "selected", "no")
				end
			end
			
			--Part 2 set selected value to true, otherwise show btn_Purchase
			dbfunctions.updateTableValue(TEMP_gearTable, index, "selected", "yes")
		else
			btn_Purchase.isVisible = true

			createLock(event.target.position)
		end

		if TEMP_gearTable == "hatTable" then
		
			--if newUnlocked == "yes" then
				tempImage = dbfunctions.getTableValue("hatTable", index, "image")
				createHat(tempImage)
			--elseif TEMP_gearTable[event.target.position].unlocked == false then
			--	print("USE LOCKED IMAGE")
			--end
				
		elseif TEMP_gearTable == "jacketTable" then
			
			if newUnlocked == "yes" then
				tempImage = dbfunctions.getTableValue("jacketTable", index, "image")
				createJacket(tempImage)
			else
				createJacket(false)
			end
		
		elseif TEMP_gearTable == "pantsTable" then

			tempImage = dbfunctions.getTableValue("pantsTable", index, "image")
			createPants(tempImage)

		elseif TEMP_gearTable == "sledTable" then

			if newUnlocked == "yes" then
				tempImage = dbfunctions.getTableValue("sledTable", index, "image")
				createSled(tempImage)
			else
				tempImage = dbfunctions.getTableValue("sledTable", index, "image")
				createSled(tempImage, 0)
			end
		end
	end
end

local function create_secBtn( TEMP_gearTable, i )

	local unlocked = dbfunctions.getTableValue( TEMP_gearTable, i, "unlocked" )
	local selected = dbfunctions.getTableValue( TEMP_gearTable, i, "selected" )
	local tempLabel = dbfunctions.getTableValue( TEMP_gearTable, i, "gearName" )

	_x = 250*i
	_y = _H_Real - 150
	--_alphaPressed = 0.5

	secBtnTable[i] = display.newImage( "images/mainMenu/button_Sec_Released.png" )
	secBtnTable[i].isVisible = false
	secBtnTable[i].x = _x
	secBtnTable[i].y = _y
	secBtnTable[i].alpha = _alphaReleased
	secBtnTable[i].isHitTestable = true
	secBtnTable[i].state = "released"
	secBtnTable[i]:addEventListener( "touch", secBtn_touched )
	gforeground2:insert( secBtnTable[i] )

	secBtnTable[i].imagePressed = display.newImage( "images/mainMenu/button_Sec_Pressed.png" )
	secBtnTable[i].imagePressed.isVisible = false
	secBtnTable[i].imagePressed.x = _x
	secBtnTable[i].imagePressed.y = _y
	secBtnTable[i].imagePressed.alpha = _alphaPressed
	gforeground2:insert( secBtnTable[i].imagePressed )

	secBtnTable[i].imageLockedReleased = display.newImage( "images/mainMenu/button_Sec_LockedReleased.png" )
	secBtnTable[i].imageLockedReleased.isVisible = false
	secBtnTable[i].imageLockedReleased.x = _x
	secBtnTable[i].imageLockedReleased.y = _y
	secBtnTable[i].imageLockedReleased.alpha = _alphaReleased
	gforeground2:insert( secBtnTable[i].imageLockedReleased )

	secBtnTable[i].imageLockedPressed = display.newImage( "images/mainMenu/button_Sec_LockedPressed.png" )
	secBtnTable[i].imageLockedPressed.isVisible = false
	secBtnTable[i].imageLockedPressed.x = _x
	secBtnTable[i].imageLockedPressed.y = _y
	secBtnTable[i].imageLockedPressed.alpha = _alphaPressed
	gforeground2:insert( secBtnTable[i].imageLockedPressed )

	if TEMP_gearTable == "hatTable" then
		if i == 1 then
			_textImage = "button_Text_White.png"
		elseif i == 2 then
			_textImage = "button_Text_Blue.png"
		elseif i == 3 then
			_textImage = "button_Text_Red.png"
		elseif i == 4 then
			_textImage = "button_Text_Gold.png"
		elseif i == 5 then
			_textImage = "button_Text_Black.png"
		end
	elseif TEMP_gearTable == "jacketTable" then
		if i == 1 then
			_textImage = "button_Text_Classic.png"
		elseif i == 2 then
			_textImage = "button_Text_Pixel.png"
		elseif i == 3 then
			_textImage = "button_Text_Camo.png"
		elseif i == 4 then
			_textImage = "button_Text_Razor.png"
		elseif i == 5 then
			_textImage = "button_Text_Eclipse.png"
		end

	elseif TEMP_gearTable == "pantsTable" then
		if i == 1 then
			_textImage = "button_Text_Gold.png"
		elseif i == 2 then
			_textImage = "button_Text_Red.png"
		elseif i == 3 then
			_textImage = "button_Text_Green.png"
		elseif i == 4 then
			_textImage = "button_Text_Black.png"
		end

	elseif TEMP_gearTable == "sledTable" then
		if i == 1 then
			_textImage = "button_Text_Toboggan2.png"
		elseif i == 2 then
			_textImage = "button_Text_LeadSled.png"
		elseif i == 3 then
			_textImage = "button_Text_Turbo.png"
		end
	end

	if _textImage ~= nil then
		secBtnTable[i].imageText = display.newImage( "images/mainMenu/".._textImage )
		secBtnTable[i].imageText.x = _x
		secBtnTable[i].imageText.y = _y
		secBtnTable[i].imageText.alpha = _alphaTextReleased
		gforeground2:insert( secBtnTable[i].imageText )
	end

	if selected == "yes" then
		secBtnTable[i].imagePressed.isVisible = true
		secBtnTable[i].imageText.alpha = _alphaTextPressed
		secBtnTable[i].state = "pressed"

	elseif unlocked == "no" then
		secBtnTable[i].isVisible = false

		secBtnTable[i].imageLockedReleased.isVisible = true
		secBtnTable[i].state = "lockedReleased"
	else
		secBtnTable[i].isVisible = true
	end

	
	--secBtnTable[i]:toFront()
	secBtnTable[i].position = i
end

local function showSelectedGear() --Shows currently selected gear, need to remove and replace "LOCKED GEAR"

	if mainBtnTable[1].state == "pressed" then
		tbl = "hatTable"
		tempImage = dbfunctions.getSelectedImage(tbl, "image")
		createHat(tempImage)
	elseif mainBtnTable[2].state == "pressed" then
		tbl = "jacketTable"
		tempImage = dbfunctions.getSelectedImage(tbl, "image")
		createJacket(tempImage)
	elseif mainBtnTable[3].state == "pressed" then
		tbl = "pantsTable"
		tempImage = dbfunctions.getSelectedImage(tbl, "image")
		createPants(tempImage)
	elseif mainBtnTable[4].state == "pressed" then
		tbl = "sledTable"
		tempImage = dbfunctions.getSelectedImage(tbl, "image")
		createSled(tempImage)
	end
end

local function mainBtn_touched(event) --SHOW SECONDARY BUTTONS w/ settings (LOCKED,SELECTED)

	if event.phase == "ended"
	and event.target.state == "released" then

		--_alphaPressed = 0.5

		btn_Purchase.isVisible = false
		removeLock()

		showSelectedGear()
		
		--adjust alpha
		for i = 1,#mainBtnTable do
			if mainBtnTable[i] ~= event.target then
				mainBtnTable[i].imagePressed.isVisible = false
				mainBtnTable[i].imageText.alpha = _alphaTextReleased
				mainBtnTable[i].isVisible = true
				mainBtnTable[i].state = "released"
			end
		end
		
		event.target.isVisible = false
		event.target.imagePressed.isVisible = true
		event.target.imageText.alpha = _alphaTextPressed
		event.target.state = "pressed"

		
		
		--REMOVE SECONDARY BUTTONS
		for i = #secBtnTable,1,-1 do

			secBtnTable[i].imageText:removeSelf()
			secBtnTable[i].imageText = nil

			secBtnTable[i].imagePressed:removeSelf()
			secBtnTable[i].imagePressed = nil

			secBtnTable[i].imageLockedReleased:removeSelf()
			secBtnTable[i].imageLockedReleased = nil

			secBtnTable[i].imageLockedPressed:removeSelf()
			secBtnTable[i].imageLockedPressed = nil

			secBtnTable[i]:removeSelf()
			secBtnTable[i] = nil
		end
		
		--find loop end
		if event.target.type == "hat" then
			loopEnd = dbfunctions.numberOfRows("hatTable")
			TEMP_gearTable = "hatTable"
		elseif event.target.type == "jacket" then
			loopEnd = dbfunctions.numberOfRows("jacketTable")
			TEMP_gearTable = "jacketTable"
		elseif event.target.type == "pants" then
			loopEnd = dbfunctions.numberOfRows("pantsTable")
			TEMP_gearTable = "pantsTable"
		elseif event.target.type == "sled" then
			loopEnd = dbfunctions.numberOfRows("sledTable")
			TEMP_gearTable = "sledTable"
			end
		

		for i = 1,loopEnd do
			create_secBtn( TEMP_gearTable, i )
		end
		
		
	end
end

local function changeButtonPosition( bannerAds, self )

	if bannerAds == "on" then
		txt_Coins.y = 300
		coinsImage.y = txt_Coins.y
		btn_AddCoins.y = txt_Coins.y
		
		btn_Music.x = 350
		btn_Music.y = 350
		
		btn_Music.offImage.x = btn_Music.x
		btn_Music.offImage.y = btn_Music.y
	
		btn_Sound.x = 150
		btn_Sound.y = 350
		
	elseif bannerAds == "off" then
		txt_Coins.y = 100
		coinsImage.y = txt_Coins.y
		btn_AddCoins.y = txt_Coins.y
		
		btn_Music.x = 150
		btn_Music.y = 150
		
		btn_Music.offImage.x = btn_Music.x
		btn_Music.offImage.y = btn_Music.y
	
		btn_Sound.x = 150
		btn_Sound.y = 350
	end
end




local function unlock(tempTable, tempKeyID)

	btn_Purchase.isVisible = false
	removeLock()
	
	for i = 1,loopEnd do
		dbfunctions.updateTableValue(tempTable, i, "selected", "no")
	end
	
	dbfunctions.updateTableValue(tempTable, tempKeyID, "unlocked", "yes")
	dbfunctions.updateTableValue(tempTable, tempKeyID, "selected", "yes")

	
	local soundState = dbfunctions.getTableValue("generalSettings", "sound", "value")
	
	if soundState == "on" then
		manageSounds.createSound(newRecordSound)
	end
end

local function updateCoins()

	local tempCoins = dbfunctions.getTableValue("generalSettings", "coins", "value")
	tempCoins = tonumber(tempCoins)
	
	txt_Coins.text = tempCoins

	if tempCoins >= 1000000 then
		coinsImage.x = txt_Coins.x - 305
	elseif tempCoins >= 100000 then
		coinsImage.x = txt_Coins.x - 270
	elseif tempCoins >= 10000 then
		coinsImage.x = txt_Coins.x - 235
	elseif tempCoins >= 1000 then
		coinsImage.x = txt_Coins.x - 200
	elseif tempCoins >= 100 then
		coinsImage.x = txt_Coins.x - 175
	elseif tempCoins >= 10 then
		coinsImage.x = txt_Coins.x - 150
	else
		coinsImage.x = txt_Coins.x - 125
	end
end

local function buyGear(event)

	local myCoins = dbfunctions.getTableValue("generalSettings", "coins", "value")
	myCoins = tonumber( myCoins )

	for i = 1,#secBtnTable do
		if secBtnTable[i].state == "lockedPressed" then
			gearCost = dbfunctions.getTableValue(TEMP_gearTable, i, "cost")
			gearCost = tonumber( gearCost )
		end
	end

	if event.phase == "ended" 
	and myCoins >= gearCost then

		for i = 1,#secBtnTable do
			if secBtnTable[i].state == "lockedPressed" then
				--Change what is visible
				secBtnTable[i].imageLockedReleased.isVisible = false
				secBtnTable[i].imageLockedPressed.isVisible = false
				secBtnTable[i].imagePressed.isVisible = true
				secBtnTable[i].state = "pressed"
			end
		end

		myCoins = myCoins - gearCost
		dbfunctions.updateTableValue("generalSettings", "coins", "value", myCoins)
		
		updateCoins()


		
		for i = 1,#secBtnTable do
		
			if secBtnTable[i].state == "pressed" then	
				
				--unlock in table
				if TEMP_gearTable == "hatTable" then

					unlock("hatTable",i)
					tempImage = dbfunctions.getTableValue("hatTable", i, "image")
					createHat(tempImage)
					analytics.logEvent( "BuyHat", {i})
					
				elseif TEMP_gearTable == "jacketTable" then

					unlock("jacketTable",i)
					tempImage = dbfunctions.getTableValue("jacketTable", i, "image")
					createJacket(tempImage)
					analytics.logEvent( "BuyJacket", {i})
					
				elseif TEMP_gearTable == "pantsTable" then

					unlock("pantsTable",i)
					tempImage = dbfunctions.getTableValue("pantsTable", i, "image")
					createPants(tempImage)
					analytics.logEvent( "BuyPants", {i})

				elseif TEMP_gearTable == "sledTable" then

					unlock("sledTable",i)
					tempImage = dbfunctions.getTableValue("sledTable", i, "image")
					createSled(tempImage)
					analytics.logEvent( "BuySled", {i})
				end

			end
		end

	elseif event.phase == "ended" then

		local function colorCostText()
			for i = 1,#screenElementsTable do
				if screenElementsTable[i].type == "cost" then
					screenElementsTable[i]:setFillColor(0,0,0)
					screenElementsTable[i].transitionHandle = nil
					break
				end
			end
		end

		local function shrinkCostText()
			for i = 1,#screenElementsTable do
				if screenElementsTable[i].type == "cost" then
					newXScale = screenElementsTable[i].xScale / 1.25
					newYScale = screenElementsTable[i].yScale / 1.25

					screenElementsTable[i].transitionHandle = transition.to( screenElementsTable[i],
						{ time=250, xScale = newXScale, yScale = newYScale, onComplete = colorCostText} )
					break
				end
			end
		end

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "cost"
			and screenElementsTable[i].transitionHandle == nil then
				screenElementsTable[i]:setFillColor(1,0,0)
				newXScale = screenElementsTable[i].xScale * 1.25
				newYScale = screenElementsTable[i].yScale * 1.25

				screenElementsTable[i].transitionHandle = transition.to( screenElementsTable[i],
					{ time=250, xScale = newXScale, yScale = newYScale, onComplete = shrinkCostText} )
				break
			end
		end
	end
end




--Add Coins Menu Functions
local function blockTouch()

	return true
end

local function destroyBuyCoinsMenu(event)

	if event.phase == "ended" then
		blockTouch()

		display.remove( AddCoinsMenu ); AddCoinsMenu = nil
		display.remove( txt_MoreCoins ); txt_MoreCoins = nil
		display.remove( txt_MoreCoinsState ); txt_MoreCoinsState = nil
		display.remove( btn_Start ); btn_Start = nil
		display.remove( btn_Stop ); btn_Stop = nil
		
		display.remove( IAP_Menu ); IAP_Menu = nil
		display.remove( txt_IAP ); txt_IAP = nil
		display.remove( txt_Connection ); txt_Connection = nil
		if btn_IAP_50k ~= nil then
			display.remove( btn_IAP_50k); btn_IAP_50k = nil
		end
		
		btn_AddCoins.isVisible = true
	end
end

local function createBuyCoinsMenu()

	screen = display.newRect(_W/2, _H/2, _W, _H)
	screen.isVisible = false
	screen.isHitTestable = true
	screen:addEventListener("touch",destroyBuyCoinsMenu)

	

	AddCoinsMenu = display.newImage("images/mainMenu/rateMenu.png")
	AddCoinsMenu.x = _W/2
	AddCoinsMenu.y = _H/2 - 400
	AddCoinsMenu.xScale = 1.75
	AddCoinsMenu.yScale = 1.5

	AddCoinsMenu.isHitTestable = true
	AddCoinsMenu:addEventListener("touch",blockTouch)



	local options = 
	{
		parent = textGroup,
		text = "Enable Banner Ads for 10% more coins per round!",     
		x = _W/2,
		y = _H/2-600,
		width = 460,
		height = 0,     --required for multi-line and alignment
		font = _font,   
		fontSize = _fontSize,
		align = "left"  --new alignment parameter
	}
	txt_MoreCoins = display.newText( options )
	txt_MoreCoins:setFillColor(1,1,1)
	txt_MoreCoins.anchorX = 0.5



	btn_Start =  require("widget").newButton
	{
		--x = AddCoinsMenu.x,
		top = AddCoinsMenu.y + 125,
		defaultFile = "images/mainMenu/button_StartSmall.png",
		width = sizeSmall_W/2,
		height = sizeSmall_H,

		onEvent = function(event) 
			if "ended" == event.phase then
				btn_Start.isVisible = false
				btn_Stop.isVisible = true

				dbfunctions.updateTableValue("generalSettings", "bannerAds", "value","on")
				changeButtonPosition( "on" )
				ADS_SHOWING = true
				ads.show( "banner", { x=adX, y=adY, appId=appID } )

				analytics.logEvent( "Show Ads" )
			end
		end
	}
	btn_Start.x = AddCoinsMenu.x
	btn_Start.anchorX = 0.5
	btn_Start.isVisible = true



	btn_Stop =  require("widget").newButton
	{
		--x = AddCoinsMenu.x,
		top = AddCoinsMenu.y + 125,
		defaultFile = "images/mainMenu/button_Stop.png",
		width = sizeSmall_W/2,
		height = sizeSmall_H,

		onEvent = function(event) 
			if "ended" == event.phase then

				btn_Start.isVisible = true
				btn_Stop.isVisible = false

				dbfunctions.updateTableValue("generalSettings", "bannerAds", "value","off")
				changeButtonPosition( "off" )
				ADS_SHOWING = nil
				ads.hide()

				analytics.logEvent( "Stop Ads" )
			end
		end
	}
	btn_Stop.x = AddCoinsMenu.x
	btn_Stop.anchorX = 0.5
	btn_Stop.isVisible = false



	--Add to Display Group
	gforeground2:insert( screen )
	gforeground2:insert( AddCoinsMenu )
	gforeground2:insert( txt_MoreCoins )
	gforeground2:insert( btn_Start )
	gforeground2:insert( btn_Stop )

	--Show Correct Buttons
	local bannerAdState = dbfunctions.getTableValue("generalSettings", "bannerAds", "value")

	if bannerAdState == "on" then
		btn_Start.isVisible = false
		btn_Stop.isVisible = true
	else
		btn_Start.isVisible = true
		btn_Stop.isVisible = false
	end
end






--InAppPurchases
local function transactionCallback( event )

	if event.transaction.state == "purchased" then
	
		if event.transaction.productIdentifier == "com.goldenegg.downhilldash.coins.50k" then
			--Update Coins
			local tempCoins = dbfunctions.getTableValue("generalSettings", "coins", "value")
			tempCoins = tempCoins + 50000
			dbfunctions.updateTableValue("generalSettings", "coins", "value", tempCoins)
			
			updateCoins()
			
			local soundState = dbfunctions.getTableValue("generalSettings", "sound", "value")
	
			if soundState == "on" then
				manageSounds.createSound(newRecordSound)
			end
			
			txt_Connection.text = ""
			btn_IAP_50k.isVisible = true
			
		end

	elseif  event.transaction.state == "restored" then

	elseif event.transaction.state == "consumed"  then
		-- Consume notifications is only supported by the Google Android Marketplace.
		-- Apple's app store does not support this.
		-- This is your opportunity to note that this object is available for purchase again.

	elseif  event.transaction.state == "refunded" then
		-- Refunds notifications is only supported by the Google Android Marketplace.
		-- Apple's app store does not support this.
		-- This is your opportunity to remove the refunded feature/product if you want.

	elseif event.transaction.state == "cancelled" then
		txt_Connection.text = ""
		btn_IAP_50k.isVisible = true
	elseif event.transaction.state == "failed" then        
		txt_Connection.text = ""
		btn_IAP_50k.isVisible = true
	end
	store.finishTransaction( event.transaction )
end
if store.availableStores.apple then
	store.init( "apple", transactionCallback )
end

local function createInAppPurchaseMenu()

	IAP_Menu = display.newImage("images/mainMenu/rateMenu.png")
	IAP_Menu.x = _W/2
	IAP_Menu.y = _H/2 + 400
	IAP_Menu.xScale = 1.75
	IAP_Menu.yScale = 1.5

	IAP_Menu.isHitTestable = true
	IAP_Menu:addEventListener("touch",blockTouch)
	
	
	
	local options = 
	{
		parent = textGroup,
		text = "Get 50,000 coins for $0.99!",     
		x = _W/2,
		y = _H/2+200,
		width = 460,
		height = 0,     --required for multi-line and alignment
		font = _font,   
		fontSize = _fontSize,
		align = "left"  --new alignment parameter
	}
	txt_IAP = display.newText( options )
	txt_IAP:setFillColor(1,1,1)
	txt_IAP.anchorX = 0.5
	
	
	
	local options = 
	{
		parent = textGroup,
		text = "",     
		x = _W/2,
		y = _H/2+400,
		width = 460,
		height = 0,     --required for multi-line and alignment
		font = _font,   
		fontSize = _fontSize,
		align = "left"  --new alignment parameter
	}
	txt_Connection = display.newText( options )
	txt_Connection:setFillColor(1,1,1)
	txt_Connection.anchorX = 0.5
	
	
	
	btn_IAP_50k = require("widget").newButton
	{ 
		defaultFile = "images/mainMenu/button_Yes.png", 
		overFile = "images/mainMenu/button_Yes.png",
		width = sizeSmall_W/2,
		height = sizeSmall_H,
		x = _W/2,
		y = _H/2 + 600,
		onEvent = function(event)
			if event.phase == "ended" then
				if platform == "simulator" or store.isActive then
					store.purchase( { "com.goldenegg.downhilldash.coins.50k" } )
					txt_Connection.text = "Loading..."
					btn_IAP_50k.isVisible = false
				else
					native.showAlert( "Notice", "In-app purchases are not available.", { "OK" } )
				end
			end
		end
	}
	btn_IAP_50k.anchorX = 0.5
	btn_IAP_50k.isVisible = true
	
	
	
	gforeground2:insert( IAP_Menu )
	gforeground2:insert( txt_IAP )
	gforeground2:insert( txt_Connection )
	gforeground2:insert( btn_IAP_50k )

	analytics.logEvent( "Show Add Coins Menu" )
end





--Setup Functions
local function createBackground()
	
	id = #screenElementsTable+1
	screenElementsTable[id] = display.newImageRect("images/mainMenu/CC_Sky.png",_W,_H_Real)--display.newRect(_W/2,_H_Real/2, _W, _H_Real)
	screenElementsTable[id].x = _W/2
	screenElementsTable[id].y = _H_Real/2 -- +0.5*(_H_Real-_H)
	--screenElementsTable[id].xScale = 2 --Unknown Error Should be 1
	--screenElementsTable[id].yScale = 2 -- *(_H_Real/_H) --Unknown Error Should be 1
	--screenElementsTable[id]:setFillColor(0.9,0.9,0.9)
	screenElementsTable[id].type = "background"
	gbackground:insert( screenElementsTable[id] )

	id = #screenElementsTable+1
	screenElementsTable[id] = display.newImageRect("images/mainMenu/CC_Mountain.png",_W,_H)--display.newRect(_W/2,_H_Real/2, _W, _H_Real)
	screenElementsTable[id].x = _W/2
	screenElementsTable[id].y = _H_Real - _H/2
	--screenElementsTable[id].xScale = 2 --Unknown Error Should be 1
	--screenElementsTable[id].yScale = 2 --Unknown Error Should be 1
	--screenElementsTable[id]:setFillColor(0.9,0.9,0.9)
	screenElementsTable[id].type = "background"
	gbackground:insert( screenElementsTable[id] )
end

local function loadGearTexturesToMemory()

	local tempTable = {
		"Hat_White_Custom.png",
		"Hat_Blue_Custom.png",
		"Hat_Red_Custom.png",
		"Hat_Gold_Custom.png",
		"Hat_Black_Custom.png",

		"Jacket_Classic_Custom.png",
		"Jacket_Pixel_Custom.png",
		"Jacket_Camo_Custom.png",
		"Jacket_Razor_Custom.png",
		"Jacket_Eclipse_Custom.png",
		
		"lock_Sprite.png",
		
		"Pants_Gold_Custom.png",
		"Pants_Red_Custom.png",
		"Pants_Green_Custom.png",
		"Pants_Black_Custom.png",

		"Sled_Lead_MainMenu.png",
		"Sled_OldFaithful_MainMenu.png",
		"Sled_Turbo_MainMenu.png",
		"Sled_TurboFlames_MainMenu.png"
	}

	for i = 1,#tempTable do
		local id = #loadedGearTextureTable+1
		loadedGearTextureTable[id] = display.newImage("images/gearCC/"..tempTable[i])
		loadedGearTextureTable[id].isVisible = false
	end
end

local function createMainBtn()

	--_alphaPressed = 0.5
	local tempLabel
	mainBtnTable = {}


	for i = 1,4 do
		_x = 150
		_y = _H_Real-1700 + 300*i

		id = #mainBtnTable+1

		if i == 1 then
			_textImage = "button_Text_Hats.png"
			_type = "hat"
		elseif i == 2 then
			_textImage = "button_Text_Jackets.png"
			_type = "jacket"
		elseif i == 3 then
			_textImage = "button_Text_Pants.png"
			_type = "pants"
		elseif i == 4 then
			_textImage = "button_Text_Sleds.png"
			_type = "sled"
		end

		mainBtnTable[i] = display.newImage( "images/mainMenu/button_Main_Released.png" )
		mainBtnTable[i].x = _x
		mainBtnTable[i].y = _y
		mainBtnTable[i].alpha = _alphaPressed
		mainBtnTable[i].isHitTestable = true
		mainBtnTable[i].type = _type
		mainBtnTable[i].state = "released"
		mainBtnTable[i]:addEventListener( "touch", mainBtn_touched )
		gforeground2:insert( mainBtnTable[i] )

		mainBtnTable[i].imagePressed = display.newImage( "images/mainMenu/button_Main_Pressed.png" )
		mainBtnTable[i].imagePressed.isVisible = false
		mainBtnTable[i].imagePressed.x = _x
		mainBtnTable[i].imagePressed.y = _y
		mainBtnTable[i].imagePressed.alpha = _alphaPressed
		gforeground2:insert( mainBtnTable[i].imagePressed )

		mainBtnTable[i].imageText = display.newImage( "images/mainMenu/".._textImage )
		mainBtnTable[i].imageText.x = _x
		mainBtnTable[i].imageText.y = _y
		mainBtnTable[i].imageText.alpha = _alphaTextReleased
		gforeground2:insert( mainBtnTable[i].imageText )
	end



	--[[

	local tempLabel



	mainBtnTable = {}
	
	for i = 1,4 do

		id = #mainBtnTable+1


		if i == 1 then
			_image = "images/mainMenu/button_MainHat_Dark.png"
		elseif i == 2 then
			_image = "images/mainMenu/button_MainJacket_Dark.png"
		elseif i == 3 then
			_image = "images/mainMenu/button_MainPants_Dark.png"
		elseif i == 4 then
			_image = "images/mainMenu/button_MainSled_Dark.png"
		else print("WE HAVE A PROMBLEM")
		end

		mainBtnTable[id] =  require("widget").newButton
		{
			left = 150,
			top =  _H_Real-1900 + 300*i,
			defaultFile = _image,
			font = "Helvetica",
			--fontSize = 0,
			--label = tempLabel,
			width = 250,
			height = 250,
			--cornerRadius = 4,

			onEvent = function(event)
				mainBtn_touched(event)
			end
		}
		mainBtnTable[id].anchorX = 1
		mainBtnTable[id].alpha = 0.75


		mainBtnTable[id].overlay = display.newImageRect( "images/mainMenu/buttonSquare_Mask.png", 250, 250 )
		mainBtnTable[id].overlay.x = mainBtnTable[id].x
		mainBtnTable[id].overlay.y = mainBtnTable[id].y
		mainBtnTable[id].overlay.anchorX = 1
		mainBtnTable[id].overlay.alpha = 0.1
		mainBtnTable[id].overlay:setFillColor(0.3,1,0.3)
		mainBtnTable[id].overlay.isVisible = false

		mainBtnTable[id].trim = display.newImageRect( "images/mainMenu/buttonSquare_Trim.png", 250, 250 )
		mainBtnTable[id].trim.x = mainBtnTable[id].x
		mainBtnTable[id].trim.y = mainBtnTable[id].y
		mainBtnTable[id].trim.anchorX = 1
		--mainBtnTable[id].trim.alpha = 0.3
		mainBtnTable[id].trim:setFillColor(1,1,0.5)
		--mainBtnTable[id].trim:setFillColor(0.8,0.8,0.8)
		mainBtnTable[id].trim.isVisible = false
		
		
		
		if i == 1 then mainBtnTable[id].type = "hat"
		elseif i == 2 then mainBtnTable[id].type = "jacket"
		elseif i == 3 then mainBtnTable[id].type = "pants"
		elseif i == 4 then mainBtnTable[id].type = "sled"
		else print("WE HAVE A PROMBLEM")
		end
		
		gforeground1:insert( mainBtnTable[id] )
	end
	]]
end

local function initialGear()

	tempImage = dbfunctions.getSelectedImage("sledTable", "image")
	createSled(tempImage)

	createHead()

	tempImage = dbfunctions.getSelectedImage("hatTable", "image")
	createHat(tempImage)
	
	tempImage = dbfunctions.getSelectedImage("jacketTable", "image")
	createJacket(tempImage)
	
	tempImage = dbfunctions.getSelectedImage("pantsTable", "image")
	createPants(tempImage)
end

local function createExtraButtons()

	btn_Purchase =  require("widget").newButton
	{
		left = _W - 175,
		top = _H_Real - 500,
		defaultFile = "images/mainMenu/button_BuyGear.png",
		width = sizeSmall_W,
		height = sizeSmall_H,

		onEvent = function(event) 
			if event.phase == "ended" then
				buyGear(event)
			end
		end
	}
	btn_Purchase.isVisible = false
	btn_Purchase.anchorY = 1
	btn_Purchase.x = _W/2
	btn_Purchase.y = _H_Real - 300 - 15



	btn_Back =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_Back.png",
		width = sizeSmall_W/2,
		height = sizeSmall_H +  30,
		cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				composer:hideOverlay("fade",250)
			end
		end
	}
	btn_Back.isVisible = true
	btn_Back.anchorY = 1
	btn_Back.x = _W-150
	btn_Back.y = _H_Real - 300


	--==|COINS|==--
	--local tempCoins = dbfunctions.getTableValue("generalSettings", "coins", "value")
	tempCoins = ""--tonumber(tempCoins)
	local options = 
		{
		    parent = textGroup,
		    text = tempCoins,     
		    x = _W - 150,
		    y = 100,
		    font = _font,   
		    fontSize = _fontSize,
		}
	txt_Coins = display.newText( options )
	txt_Coins:setFillColor(1,1,1)
	txt_Coins.anchorX = 1



	coinsImage = display.newImage("images/mainMenu/coin_glare.png")
	
	updateCoins()
	
	coinsImage.y = txt_Coins.y
	coinsImage.xScale = 0.4
	coinsImage.yScale = 0.4



	btn_AddCoins =  require("widget").newButton
	{
		left = _W - 175,
		top = _H_Real - 500,
		defaultFile = "images/mainMenu/button_Add.png",
		width = 100,
		height = 100,

		onEvent = function(event) 
			if event.phase == "ended" then

				createBuyCoinsMenu()
				
				createInAppPurchaseMenu()
				
				btn_AddCoins.isVisible = false
			end
		end
	}
	btn_AddCoins.anchorX = 0.5
	btn_AddCoins.anchorY = 0.5
	btn_AddCoins.x = txt_Coins.x + 75
	btn_AddCoins.y = txt_Coins.y


	
	--==|MUSIC AND SOUND BUTTONS and FUNCTIONS|==--
	btn_Music =  require("widget").newButton
	{
		left = _W - 175,
		top = _H_Real - 500,
		defaultFile = "images/mainMenu/button_Music_On.png",
		width = 150,
		height = 150,

		onEvent = function(event) 
			if event.phase == "ended" then
				--Turn Music Off
				audio.stop( 1 )

				dbfunctions.updateTableValue("generalSettings", "music", "value","off")
				btn_Music.isVisible = false
				btn_Music.offImage.isVisible = true
			end
		end
	}
	btn_Music.isVisible = false
	btn_Music.anchorX = 0.5
	btn_Music.anchorY = 0.5
	btn_Music.x = 150
	btn_Music.y = 150



	btn_Music.offImage =  require("widget").newButton
	{
		left = _W - 175,
		top = _H_Real - 500,
		defaultFile = "images/mainMenu/button_Music_Off.png",width = 150,
		height = 150,

		onEvent = function(event) 
			if event.phase == "ended" then
			
				local soundState = dbfunctions.getTableValue("generalSettings", "sound", "value")
				
				if soundState == "on" then
					--Turn Music On
					manageSounds.createSound(introLoopingSound,0.125,20000, 5000)

					dbfunctions.updateTableValue("generalSettings", "music", "value","on")
					btn_Music.isVisible = true
					btn_Music.offImage.isVisible = false
				end
			end
		end
	}
	btn_Music.offImage.isVisible = false
	btn_Music.offImage.anchorX = 0.5
	btn_Music.offImage.anchorY = 0.5
	btn_Music.offImage.x = btn_Music.x
	btn_Music.offImage.y = btn_Music.y



	btn_Sound =  require("widget").newButton
	{
		left = _W - 175,
		top = _H_Real - 500,
		defaultFile = "images/mainMenu/button_Sound_On.png",
		width = 150,
		height = 150,

		onEvent = function(event) 
			if event.phase == "ended" then
				--Turn Sound Off
				--Turn Music Off
				audio.stop( 1 )

				dbfunctions.updateTableValue("generalSettings", "sound", "value","off")
				dbfunctions.updateTableValue("generalSettings", "music", "value","off")
				btn_Sound.isVisible = false
				btn_Sound.offImage.isVisible = true
				
				btn_Music.isVisible = false
				btn_Music.offImage.isVisible = true
			end
		end
	}
	btn_Sound.isVisible = false
	btn_Sound.anchorX = 0.5
	btn_Sound.anchorY = 0.5
	btn_Sound.x = 150
	btn_Sound.y = 350



	btn_Sound.offImage =  require("widget").newButton
	{
		left = _W - 175,
		top = _H_Real - 500,
		defaultFile = "images/mainMenu/button_Sound_Off.png",
		width = 150,
		height = 150,

		onEvent = function(event) 
			if event.phase == "ended" then
				--Turn Sound On
				--Turn Music On
				manageSounds.createSound(introLoopingSound,0.125,20000, 5000)
				
				dbfunctions.updateTableValue("generalSettings", "sound", "value","on")
				dbfunctions.updateTableValue("generalSettings", "music", "value","on")
				btn_Sound.isVisible = true
				btn_Sound.offImage.isVisible = false

				btn_Music.isVisible = true
				btn_Music.offImage.isVisible = false
	 		end
		end
	}
	btn_Sound.offImage.isVisible = false
	btn_Sound.offImage.anchorX = 0.5
	btn_Sound.offImage.anchorY = 0.5
	btn_Sound.offImage.x = btn_Sound.x
	btn_Sound.offImage.y = btn_Sound.y


	--Add to Display Group
	gforeground2:insert( btn_Purchase )
	gforeground1:insert( btn_Back )
	gforeground1:insert( txt_Coins )
	gforeground1:insert( coinsImage )
	gforeground2:insert( btn_AddCoins )
	gforeground2:insert( btn_Music )
	gforeground2:insert( btn_Music.offImage )
	gforeground2:insert( btn_Sound )
	gforeground2:insert( btn_Sound.offImage )

	

	--Show and Position Buttons
	local musicState = dbfunctions.getTableValue("generalSettings", "music", "value")
	local soundState = dbfunctions.getTableValue("generalSettings", "sound", "value")

	if soundState == "off" then
		btn_Music.offImage.isVisible = true
		btn_Sound.offImage.isVisible = true
	else
		btn_Sound.isVisible = true
		
		if musicState == "off" then
			btn_Music.offImage.isVisible = true
		elseif musicState == "on" then
			btn_Music.isVisible = true
		end
	end

	local bannerAdState = dbfunctions.getTableValue("generalSettings", "bannerAds", "value")

	if bannerAdState == "on" then
		changeButtonPosition( "on" )
	elseif bannerAdState == "off" then
		changeButtonPosition( "off" )
	end
end




local function onEveryFrame2()
	
	if viewGearTable~= nil then

		if viewGearTable[4] ~= nil then
			if viewGearTable[4].image ~= nil then
				SET_FRAME = viewGearTable[4].image.frame + 0
				viewGearTable[1].image:setFrame(SET_FRAME)
				viewGearTable[2].image:setFrame(SET_FRAME)
				viewGearTable[3].image:setFrame(SET_FRAME)
			end
		end
	end
end





---------------------------------------------------------------------------------

function scene:create( event )

	local sceneGroup = self.view
	--print("--==| CREATED SCENE CC |==--")

	scene.view:insert(gbackground)
	scene.view:insert(gground)
	scene.view:insert(gforeground1)
	scene.view:insert(gforeground2)

	createBackground()

	loadingImage = display.newImage("images/mainMenu/loading.png")
	loadingImage.x = _W/2
	loadingImage.y = _H_Real - 200
	gforeground2:insert( loadingImage )
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		

	elseif ( phase == "did" ) then

		--print("--==| SHOW SCENE CC |==--")
		loadGearTexturesToMemory()
		createMainBtn()
		createExtraButtons()

		initialGear()
		Runtime:addEventListener( "enterFrame", onEveryFrame2 )
		function removeLoading()
			loadingImage.isVisible = false
		end
		timer.performWithDelay(1,removeLoading)
		
		
	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

		--composer.removeScene( "customizeCharacter", false ) 
		
	elseif ( phase == "did" ) then

		--print("--==| HIDE SCENE CC |==--")

		local options = {
			isModal = true,
			effect = "fade",
			time = 500
		}
		composer.showOverlay( "mainMenu",options )
	end
end

function scene:destroy( event )

	local sceneGroup = self.view

	--print("--==| DESTROYED SCENE CC |==--")
	destroyScene2()
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene