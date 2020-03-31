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

	local newRecordSound = audio.loadSound("soundClips/newRecordSound.mp3")

	local gbackground = display.newGroup()
	local gforeground = display.newGroup()
	
	local _font = "HelveticaNeue-Light"
	local _fontSize = 60

	local GAME_SCENE_VIEW

	--Create Buttons
	local downHillDashText
	local menuFrame
	local btn_fb
	local btn_twitter
	local txt_Score
	local txt_Coins
	local coinsImage
	local btn_MainMenu
	local btn_Restart
---------------------------------------------------------------------------------
--| GLOVAL REQUIRE |--
	--local analytics = require( "analytics" )
		--analytics.init("S52RN5ZNSBDH26MY9ZWK")

---------------------------------------------------------------------------------
--| REQUIRE |--

	require("sqlite3")
	local dbfunctions = require("dbfunctions")
	dbfunctions.init("dbGear.db")
	local manageSounds = require("manageSounds")
	
	local gameNetwork = require( "gameNetwork" )

---------------------------------------------------------------------------------
--| GLOBAL FUNCTIONS |--
	--removeEverything() -- Game File
	--prepareGame()  -- Game File

---------------------------------------------------------------------------------
--| FUNCTIONS |--

local function destroyScene2()

	display.remove( downHillDashText ); downHillDashText = nil
	display.remove( menuFrame ); menuFrame = nil

	display.remove( btn_fb ); btn_fb = nil
	
	display.remove( btn_twitter ); btn_twitter = nil
	
	display.remove( txt_Score ); txt_Score = nil
	display.remove( txt_Coins ); txt_Coins = nil
	display.remove( coinsImage ); coinsImage = nil
	display.remove( btn_MainMenu ); btn_MainMenu = nil
	display.remove( btn_Restart ); btn_Restart = nil

	if txt_New ~= nil then
		display.remove( txt_New ); txt_New = nil
	end
end

local function saveScore(score)

	local highScore = dbfunctions.getTableValue("generalSettings", "score", "value")
	highScore = tonumber( highScore )

	if score > highScore then

		txt_New = display.newImage("images/mainMenu/new.png")
		txt_New.xScale = 0.25
		txt_New.yScale = 0.25
		txt_New.x = txt_Score.x - 150
		txt_New.y = txt_Score.y - 25

		gameNetwork.request( "setHighScore",
			{
				localPlayerScore = { category="com.goldenegg.downhilldash.highscore", value=score },
				listener = requestCallback
			}
		)

		--Play Sound
		local soundState = dbfunctions.getTableValue("generalSettings", "sound", "value")

		if soundState == "on" then

			dbfunctions.updateTableValue("generalSettings", "score", "value", score)
			manageSounds.createSound(newRecordSound)
		end		
	end
end

local function saveCoins(tempCoins)

	local tempValue = dbfunctions.getTableValue("generalSettings", "coins", "value")
	tempValue = tonumber( tempValue ) + tempCoins


	dbfunctions.updateTableValue("generalSettings", "coins", "value", tempValue)
end

--[[local function mergeImages()

	local function mergeImagesPart2()

		local tempGroup = display.newGroup()

		tempBackground = display.newImage("tempBackground.png", system.DocumentsDirectory
			)
		tempBackground.x = _W/2
		tempBackground.y = _H/2
		tempGroup:insert( tempBackground )
		
		scale = 1536 / tempBackground.width
		
		tempBackground.xScale = scale
		tempBackground.yScale = scale

		tempScoreMenu = display.newImage("tempScoreMenu.png", system.DocumentsDirectory)
		tempScoreMenu.x = _W/2
		tempScoreMenu.y = _H/2
		tempScoreMenu.xScale = scale
		tempScoreMenu.yScale = scale
		tempGroup:insert( tempScoreMenu )

		display.save( tempGroup,
			{filename="tempScoreImage.png",
			baseDir=system.DocumentsDirectory,
			backgroundColor={ 0, 0 },
			isFullResolution=true
			}
		)

		display.remove(tempGroup)
	end

	display.save( GAME_SCENE_VIEW,
		{filename="tempBackground.png",
		baseDir=system.DocumentsDirectory,
		backgroundColor={ 0, 0 },
		isFullResolution=false
		}
	)

	display.save( scene.view,
		{filename="tempScoreMenu.png",
		baseDir=system.DocumentsDirectory,
		backgroundColor={ 0, 0 },
		isFullResolution=false
		}
	)
	timer.performWithDelay(1,mergeImagesPart2)
end]]

local function go_MainMenu(event)

	--print("GO TO MAIN MENU")
	composer.hideOverlay( "flip",125 )

	local options = {
		isModal = true,
		effect = "fade",
		time = 500
	}
	composer.showOverlay( "mainMenu",options )
end

local function go_restart(event)

	--print("RESTART GAME")
	removeEverything() -- Game File
	prepareGame()  -- Game File
	composer.hideOverlay( "flip",125 )
end

local function postScore(serviceName)

	-- Supported values are "twitter", "facebook", or "sinaWeibo"

	local isAvailable = native.canShowPopup( "social", serviceName )

	if ( isAvailable ) then

		local listener = {}

		function listener:popup( event )
			--print( "name: " .. event.name )
			--print( "type: " .. event.type )
			--print( "action: " .. tostring( event.action ) )
			--print( "limitReached: " .. tostring( event.limitReached ) )
		end

		if serviceName == "twitter" then
			native.showPopup( "social",
				{
					service = serviceName,
					message = "Check out my new highscore! #DownhillDash",
					listener = listener,
					image = 
						{
							{ filename="tempScoreImage.png", baseDir=system.DocumentsDirectory }
						},
						--url = 
						--{
						--	"http://www.coronalabs.com",
						--	"http://docs.coronalabs.com"
						--}
				}
			)
		elseif serviceName == "facebook" then
			native.showPopup( "social",
				{
					service = serviceName,
					listener = listener,
					image = 
						{
							{ filename="tempScoreImage.png", baseDir=system.DocumentsDirectory }
						},
						--url = 
						--{
						--	"http://www.coronalabs.com",
						--	"http://docs.coronalabs.com"
						--}
				}
			)
		end

		else

			native.showAlert(
				"Cannot send " .. serviceName .. " message.",
				"Please setup your " .. serviceName .. " account or check your network connection.",
				{ "OK" }
			)
	end
end

--[[local function postToFB()

		analytics.logEvent( "facebook" )
		mergeImages()
		postScore("facebook")
end]]

--[[local function postToTwitter()

		analytics.logEvent( "twitter" )
		mergeImages()
		postScore("twitter")
end]]
local function postScoreStep3_Send(event)

	local serviceName = event.source.params.serviceName
	
	--print("post", serviceName)

	-- Supported values are "twitter", "facebook", or "sinaWeibo"
	analytics.logEvent( serviceName )

	local isAvailable = native.canShowPopup( "social", serviceName )

	if ( isAvailable ) then

		local listener = {}

		function listener:popup( event )
			--print( "name: " .. event.name )
			--print( "type: " .. event.type )
			--print( "action: " .. tostring( event.action ) )
			--print( "limitReached: " .. tostring( event.limitReached ) )
		end

		if serviceName == "twitter" then
			--print("post twitter")
			native.showPopup( "social",
				{
					service = serviceName,
					message = "Check out my new highscore! #DownhillDash",
					listener = listener,
					image = 
						{
							{ filename="tempScoreImage.png", baseDir=system.DocumentsDirectory }
						}
				}
			)
		elseif serviceName == "facebook" then
			--print("post fb")
			native.showPopup( "social",
				{
					service = serviceName,
					listener = listener,
					image = 
						{
							{ filename="tempScoreImage.png", baseDir=system.DocumentsDirectory }
						}
				}
			)
		end
	else

			native.showAlert(
				"Cannot send " .. serviceName .. " message.",
				"Please setup your " .. serviceName .. " account or check your network connection.",
				{ "OK" }
			)
	end
end

local function postScoreStep2_MergImages2(event)

	local serviceName = event.source.params.serviceName
	
	--print("mergeimages2", serviceName)

	local tempGroup = display.newGroup()

	local tempBackground = display.newImage("tempBackground.png", system.DocumentsDirectory
		)
	tempBackground.x = _W/2
	tempBackground.y = _H/2
	tempGroup:insert( tempBackground )
	
	local scale = 1536 / tempBackground.width
	
	tempBackground.xScale = scale
	tempBackground.yScale = scale

	local tempScoreMenu = display.newImage("tempScoreMenu.png", system.DocumentsDirectory)
	tempScoreMenu.x = _W/2
	tempScoreMenu.y = _H/2
	tempScoreMenu.xScale = scale
	tempScoreMenu.yScale = scale
	tempGroup:insert( tempScoreMenu )

	display.save( tempGroup,
		{filename="tempScoreImage.png",
		baseDir=system.DocumentsDirectory,
		backgroundColor={ 0, 0 },
		isFullResolution=true
		}
	)

	display.remove(tempGroup)

	local tempTimer = timer.performWithDelay(1,postScoreStep3_Send,1)
	tempTimer.params = {}
	tempTimer.params.serviceName = serviceName
end

local function postScoreStep1_MergeImages(serviceName)

	--print("mergeimages1")

	display.save( GAME_SCENE_VIEW,
		{filename="tempBackground.png",
		baseDir=system.DocumentsDirectory,
		backgroundColor={ 0, 0 },
		isFullResolution=false
		}
	)

	display.save( scene.view,
		{filename="tempScoreMenu.png",
		baseDir=system.DocumentsDirectory,
		backgroundColor={ 0, 0 },
		isFullResolution=false
		}
	)

	local tempTimer = timer.performWithDelay(1,postScoreStep2_MergImages2,1)
	tempTimer.params = {}
	tempTimer.params.serviceName = serviceName
end



local function createButtons()

	downHillDashText = display.newImage("images/mainMenu/downHillDash.png")
	downHillDashText.x = _W/2
	downHillDashText.y = _H/6
	downHillDashText.xScale = 1
	downHillDashText.yScale = 1

	local shift = 20 - 75

	menuFrame = display.newImage("images/mainMenu/rateMenu.png")
	menuFrame.x = _W/2
	menuFrame.y = _H/2
	menuFrame.xScale = 1.5
	menuFrame.yScale = 1.7

	
	
	--SCORE
	local scoreTotal = configGame.score
	local options = 
		{
		    --parent = textGroup,
		    text = "Score: "..scoreTotal,     
		    x = menuFrame.x,
		    y = menuFrame.y - 300 + shift,
		    width = 460,
		    height = 0,     --required for multi-line and alignment
		    font = _font,   
		    fontSize = _fontSize,
		    align = "center"  --new alignment parameter
		}
	txt_Score = display.newText( options )
	txt_Score:setFillColor(1,1,1)
	txt_Score.anchorY = 0

	saveScore(scoreTotal)
	analytics.logEvent( "scoreMenu", {score = scoreTotal} )
	
	local function requestCallback( event )

    	if ( event.type == "setHighScore" ) then
        	-- High score has been set
   		end
	end

	gameNetwork.request( "setHighScore",
    	{
        	localPlayerScore = { category="com.appledts.EasyTapList", value=25 },
        	listener = requestCallback
    	}
	)

	--COINS
	local tempCoins = math.round( configGame.coins + configGame.coinsBonus)
	local bannerBonus = dbfunctions.getTableValue("generalSettings","bannerAds","value")
	local options = nil

	if bannerBonus == "off" then

		saveCoins( tempCoins )

		options = 
		{
		    text = ""..tempCoins,     
		    font = _font,   
		    fontSize = _fontSize,
		}
	elseif bannerBonus == "on" then

		local tempCoinsBannerBonus = math.round( 0.1*tempCoins )
		saveCoins( tempCoins + tempCoinsBannerBonus )

		options = 
		{
		    text = ""..tempCoins.." + "..tempCoinsBannerBonus,     
		    font = _font,   
		    fontSize = _fontSize,
		}
	end
	
	txt_Coins = display.newText( options )
	txt_Coins:setFillColor(1,1,1)
	txt_Coins.anchorX = 0
	txt_Coins.anchorY = 0
	txt_Coins.x = menuFrame.x - 50
	txt_Coins.y = menuFrame.y - 200 + shift	

	--Image
	coinsImage = display.newImage("images/mainMenu/coin_glare.png")
	coinsImage.x = txt_Coins.x - 80
	coinsImage.y = txt_Coins.y + 30
	coinsImage.xScale = 0.35
	coinsImage.yScale = 0.35

	--BUTTONS
	btn_MainMenu =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_MainMenu.png",
		font = _font,
		width = sizeSmall_W,
		height = sizeSmall_H,

		onEvent = function(event) 
			if "ended" == event.phase then
				go_MainMenu()
			end
		end
	}
	btn_MainMenu.x = menuFrame.x
	btn_MainMenu.y = menuFrame.y + shift



	btn_Restart =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_Restart.png",
		width = sizeSmall_W,
		height = sizeSmall_H,

		onEvent = function(event) 
			if "ended" == event.phase then
				go_restart()
			end
		end
	}
	btn_Restart.x = menuFrame.x
	btn_Restart.y = menuFrame.y + sizeSmall_H*5/4 +shift



	btn_fb =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_Facebook.png",

		onEvent = function(event) 
			if "ended" == event.phase then
				postScoreStep1_MergeImages("facebook")
			end
		end
	}
	btn_fb.xScale = 0.4
	btn_fb.yScale = 0.4
	btn_fb.anchorX = 1
	btn_fb.anchorY = 1
	btn_fb.x = menuFrame.x - 25
	btn_fb.y = menuFrame.y + shift + 425
	btn_fb.isVisible = true


	btn_twitter =  require("widget").newButton
	{
		defaultFile = "images/mainMenu/button_Twitter.png",

		onEvent = function(event) 
			if "ended" == event.phase then
				postScoreStep1_MergeImages("twitter")
			end
		end
	}
	btn_twitter.xScale = 0.4
	btn_twitter.yScale = 0.4
	btn_twitter.anchorX = 0
	btn_twitter.anchorY = 1
	btn_twitter.x = menuFrame.x + 25
	btn_twitter.y = menuFrame.y + shift + 425
	
	btn_twitter.isVisible = true

	--Add to Display Group
	gforeground:insert(downHillDashText)
	gbackground:insert(menuFrame)
	gbackground:insert(btn_fb)
	gbackground:insert(btn_twitter)
	gforeground:insert(txt_Score)
	gforeground:insert(txt_Coins)
	gforeground:insert(coinsImage)
	gforeground:insert(btn_MainMenu)
	gforeground:insert(btn_Restart)
end


---------------------------------------------------------------------------------

function scene:create( event )

	--print("--==| CREATED SCENE scoreMenu|==--")
	local sceneGroup = self.view

	sceneGroup:insert(gbackground)
	sceneGroup:insert(gforeground)
	
	createButtons()
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		--print("--==| SHOW SCENE scoreMenu|==--")
		GAME_SCENE_VIEW = event.params.screenImage
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		--print("--==| HIDE SCENE scoreMenu|==--")
	end
end

function scene:destroy( event )

	--print("--==| DESTROYED SCENE scoreMenu|==--")

	local sceneGroup = self.view
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