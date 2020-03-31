local composer = require( "composer" )
local scene = composer.newScene()

--******************************************************************
--Ipad Draw
--Corona Version: 2015.2731 (2015.10.5)
--******************************************************************

local mode = "normal"
local debugMode = false
---------------------------------------------------------------------------------
--| REQUIRE |--
	local pause = require("pauseMenu")
	local scoreMenu = require("scoreMenu")
	--local tree = require("tree")
	local dbfunctions = require("dbfunctions")
	local common = require("common")
	local manageSounds = require("manageSounds")

---------------------------------------------------------------------------------
--| GLOBAL VARIABLES |--
	--CURRENT_STAGE
	--CURRENT_STAGE_VALUE
	--local analytics = require( "analytics" )
		--analytics.init("S52RN5ZNSBDH26MY9ZWK")

---------------------------------------------------------------------------------
--| VARIABLES |--
	local old_tpf = timer.performWithDelay
	if debugMode == true then

		function timer.performWithDelay (n, func, ...)

			local info = debug.getinfo(2)

			--function trackError(e)
			

			--[[
			local tempTimer = old_tpf(n,

				function(e)
					print(e)
					print("===")
					local ok, err = pcall(func, e)
					print("===")
					print(ok)
					print(err)
					if ok ~= true then
						local message = ("Error with timer created in %q at line: %i\n\n"):format(info.short_src, info.currentline)

						error(message .. tostring(err)) -- rethrow the error
					end
				end
			, ...)
			print(info.currentline)
			]]
			local tempTimer = old_tpf(n, func, ...)
			--print(info.currentline)
			tempTimer.info = info.currentline
			

			return tempTimer
			--timer.performWithDelay(n, function, ...)
		end
	end



	--PRELOAD MATH
	local atan2 = math.atan2
	local pi = math.pi
	local degrees_conversion = (180/math.pi)
	local sqrt2 = math.sqrt(2)

	local _W = display.contentWidth
	local _H = display.contentHeight

	local _W_Orig = display.pixelWidth
	local _H_Orig = display.pixelHeight

	local _W_Real = (_W_Orig / _H_Orig) * _H
	local _H_Real = (_H_Orig / _W_Orig) * _W

	local _H_Que_Trigger = _H_Real + 400 --+ 152

	--print(_W)
	--print(_H)

	--print(_W_Orig)
	--print(_H_Orig)

	--print(_W_Real)
	--print(_H_Real)

	--SOUND CLIPS
	local barrelSound = audio.loadSound("soundClips/barrelSound.wav")
	local buttonClickSound = audio.loadSound("soundClips/buttonClickSound.wav")
	local clickSound = audio.loadSound("soundClips/clickSound.wav")
	local collectCoinsSound = audio.loadSound("soundClips/collectCoinsSound.wav")
	local cutRopeSound = audio.loadSound("soundClips/cutRopeSound.wav")
	local energyReleaseSound = audio.loadSound("soundClips/energyReleaseSound.wav")
	local explosionSound = audio.loadSound("soundClips/explosionSound.wav")
	local gunFireSound = audio.loadSound("soundClips/gunFireSound.wav")
	local helicopterRotorSound = audio.loadSound("soundClips/helicopterRotorSound.wav")
	local hitMetalSound = audio.loadSound("soundClips/hitMetalSound.wav")
	local hitWoodSound = audio.loadSound("soundClips/hitWoodSound.wav")
	local introLoopingSound = audio.loadSound("soundClips/introLoopingSound.wav")
	local iceCrackSound_100 = audio.loadSound("soundClips/iceCrackSound_100.wav")
	local newRecordSound = audio.loadSound("soundClips/newRecordSound.mp3")
	local pokeSound = audio.loadSound("soundClips/pokeSound.wav")
	local shockwaveExplosionSound = audio.loadSound("soundClips/shockwaveExplosionSound.wav")
	local splashSound = audio.loadSound("soundClips/splashSound.wav")
	local swooshSound = audio.loadSound("soundClips/swooshSound.wav")
	local thumpSound = audio.loadSound("soundClips/thumpSound.wav")
	local thumpWoodSound = audio.loadSound("soundClips/thumpWoodSound.wav")
	local treeShakeSound = audio.loadSound("soundClips/treeShakeSound.wav")

	---VARIABLES
	local gameBall_warping = nil

	--TABLES
	local drawTable = {}
	local checkTable = {}
	local temp = {}

	local screenElementsTable = {}
	local wallTable = {}
	local backgroundTable = {}
	local bridgeTable = {}
	local contactTable = {}
	local portalTable = {}
	local snowPlowTable = {}
	local effectsTable = {}
	local timerTable = {} --TIMERS Forever Timers
	local transitionTable = {} --Transitions need to be cancelled at end of game.

	local bulletTable2 = {}
	local fighterTable = {}
	local chopperTable = {}
	local missleTable = {}
	local effectsTable = {} -- Needs to be humveeTable

	local regionTable = {
		{environment = "tutorial", first = 1, last = 2, length = 0},
		{environment = "Bunny Hill", first = 1, last = 2, length = 30000},
		{environment = "Back Country", first = 1, last = 2, length = 30000},
		{environment = "Wilderness", first = 1, last = 2, length = 30000},
		{environment = "Town", first = 1, last = 5, length = 45000},
		{environment = "Forest", first = 1, last = 3, length = 60000},
		{environment = "Ski Park", first = 1, last = 2, length = 60000},
		{environment = "City", first = 1, last = 3, length = 60000},
		--{environment = "Wasteland", first = 1, last = 1, length = 60000},
		{environment = "Military Camp", first = 1, last = 5, length = 90000},
		{environment = "Random", first = 1, last = 5, length = 9999999999999999},
	}

	local player1CollisionFilter = { categoryBits = 1, maskBits = 14 }
	local drawLinesCollisionFilter = { categoryBits = 2, maskBits = 9 }
	local wallCollisionFilter = { categoryBits = 4, maskBits = 1 }
	local interactiveWallCollisionFilter = { categoryBits = 8, maskBits = 3 }
	local graphicCollisionFilter = { categoryBits = 16, maskBits = 0 }

	local gfenceMask = display.newGroup()
	local gbackground1 = display.newGroup()
	local gbackground2 = display.newGroup()
	local gbackground3 = display.newGroup()
	local gground1 = display.newGroup()
	local gground2 = display.newGroup()
	local gground3 = display.newGroup()
	local gsky1 = display.newGroup()
	local gsky2 = display.newGroup()
	local gsky3 = display.newGroup()
	local gforeground1 = display.newGroup()
	local gforeground2 = display.newGroup()
	local gforeground3 = display.newGroup()
	
	local _font = "HelveticaNeue-Light"
	local _fontSize = 90
	local _fontSizeSmall = 75
	

	--
	local vTable = {}

---------------------------------------------------------------------------------
--| FUNCTIONS |--

--Load Function
	local function loadGameTexturesToMemory()
		--
		--local lfs = require( "lfs" )
		---------------------------------------------------------------------------------
		--| Load Player Graphics |--
		local loadedPlayerTextureTable = {}
		local basePath = "images/gearGame/"

		local tempImageStringTable = {}
		tempImageStringTable[#tempImageStringTable+1] = dbfunctions.getSelectedImage("hatTable", "imageGame")
		tempImageStringTable[#tempImageStringTable+1] = "Head_Game.png"
		tempImageStringTable[#tempImageStringTable+1] = dbfunctions.getSelectedImage("jacketTable", "imageGame")
		tempImageStringTable[#tempImageStringTable+1] = dbfunctions.getSelectedImage("pantsTable", "imageGame")
		--tempImageStringTable[#tempImageStringTable+1] = dbfunctions.getSelectedImage("sled", "imageGame")

		mask = graphics.newMask( "images/game/mask.png" )

		for i = 1,#tempImageStringTable do
			id = #loadedPlayerTextureTable+1
			loadedPlayerTextureTable[id] = display.newImage(basePath..tempImageStringTable[i])
			loadedPlayerTextureTable[id]:setMask( mask )
			loadedPlayerTextureTable[id].isVisible = false
		end

		tempImageStringTable = nil
		---------------------------------------------------------------------------------
		--| Load Game Graphics |--
		local loadedGameTextureTable = {}
		local basePath = "images/game/"

		--Load graphics that need fence mask
		local tempImagesTable = {
			"background1.png",
			"barbedWire.png",
			"barrel.png",
			"blades.png",
			"boulder.png",
			"Bullet_Blue.png",
			"cabin_3.png",
			"chopper_Sprite.png",
			"chopperSmoke_Sprite.png",
			"explosion_Sprite.png",
			"fence.png",
			--"fenceMask.jpg",
			"fern_Snowy.png",
			"finger.png",
			"gateFlags_Sprite.png",
			"gateMain_Sprite.png",
			"gateRopeLeft_Sprite.png",
			"gateRopeRight_Sprite.png",
				--"humveeBody_Sprite.png",
				--"humveeClock_Sprite.png",
				--"humveeCounter_Sprite.png",
				--"humveeStraight_Sprite.png",
			"ice_Sprite.png",
			--"jumpLeftCovered.png",
			--"jumpLeftCracked.png",
			--"jumpMiddleCovered.png",
			--"jumpMiddleCracked.png",
			--"jumpMound.png",
			--"jumpRightCovered.png",
			--"jumpRightCracked.png",
			"landmine_Sprite.png",
			"log150_Sprite.png",
			"log250_Sprite.png",
			"log300_Sprite.png",
			--"mask.png",
			"missle.png",
			"orb_Back_Sprite.png",
			"orb_Core.png",
			"orb_Front_Sprite.png",
				--"pipe.png",
			"plane_Sprite.png",
			"poke.png",
			"Road_Back_Cliff.png",
			"Road_Back_Sloped.png",
			"Road_Front.png",
				--"road.png",
			"shield_Sprite.png",
			"shockwave_Sprite.png",
			"smoke_Sprite.png",
			"snowball_Sprite.png",
			"snowMachine_Sprite.png",
				--"snowMound.png",
			"snowPlow_Sprite.png",
			"snowSpray_Sprite.png",
			"tallPine_Sprite.png",
			"warningArrow.png",
				--"wind_Sprite_orig.png",
			"wind_Sprite.png",
			"windmill_Sprite.png"
		}
		
		for i = 1,#tempImagesTable do
			local image = tempImagesTable[i]
			local id = #loadedGameTextureTable + 1
			loadedGameTextureTable[id] = display.newImage(basePath..image)
			loadedGameTextureTable[id].isVisible = false
		end
		
		_fenceMask = graphics.newMask( "images/game/fenceMask.jpg" )
		
		
		local tempImagesToMaskTable = {
			"jumpLeftCovered.png",
			"jumpLeftCracked.png",
			"jumpMiddleCovered.png",
			"jumpMiddleCracked.png",
			"jumpMound.png",
			"jumpRightCovered.png",
			"jumpRightCracked.png"
		}
		
		for i = 1,#tempImagesToMaskTable do
			local image = tempImagesToMaskTable[i]
			local id = #loadedGameTextureTable + 1
			loadedGameTextureTable[id] = display.newImage(basePath..image)
			loadedGameTextureTable[id]:setMask( _fenceMask )
			loadedGameTextureTable[id].isVisible = false
		end
		
		--LOAD CC CHARACTER LOADING SCREEN
		basePath = "images/mainMenu/"
		
		local id = #loadedGameTextureTable + 1
		loadedGameTextureTable[id] = display.newImage(basePath.."CC_Mountain.png")
		loadedGameTextureTable[id].isVisible = false
			
		local id = #loadedGameTextureTable + 1
		loadedGameTextureTable[id] = display.newImage(basePath.."CC_Sky.png")
		loadedGameTextureTable[id].isVisible = false
			
		local id = #loadedGameTextureTable + 1
		loadedGameTextureTable[id] = display.newImage(basePath.."loading.png")
		loadedGameTextureTable[id].isVisible = false
	end

	local function soundCheck( _fileAndPath, _volumePercent, _fadeOutDelay, _fadeOutTime )
		
		local soundState = dbfunctions.getTableValue( "generalSettings", "sound", "value")

		if soundState == "on" then
			manageSounds.createSound( _fileAndPath, _volumePercent, _fadeOutDelay, _fadeOutTime )
		end
	end
--

--GAME STATE
	function initializeGameVariables()

		--print("initializeGameVariables")

		--CONFIG DRAW
		configDraw = nil
		configDraw = {}
		configDraw.type = "continuous"
		configDraw.w = 15
		configDraw.length = 50^2
		configDraw.state = nil
		configDraw.red = 50
		configDraw.green = 100
		configDraw.blue = 150
		configDraw.time = 1500

		local sledOldFaithful = {}
		sledOldFaithful.weight = 50
		sledOldFaithful.bounce = 50
		sledOldFaithful.acceleration = 50
		sledOldFaithful.thrust = 50
		sledOldFaithful.steering = 50

		local tempImage = dbfunctions.getSelectedImage("sledTable", "imageGame")
		local sledWeightSpec
		local sledBounceSpec
		local sledAccelerationSpec
		local sledThrustSpec
		local sledSteeringSpec

		if tempImage == "Sled_OldFaithful_Game.png" then
			sledWeightSpec = 50
			sledBounceSpec = 50
			sledAccelerationSpec = 50
			sledThrustSpec = 50
			sledSteeringSpec = 50
		elseif tempImage == "Sled_Lead_Game.png" then
			sledWeightSpec = 80
			sledBounceSpec = 50
			sledAccelerationSpec = 70
			sledThrustSpec = 50
			sledSteeringSpec = 20
		elseif tempImage == "Sled_Turbo_Game.png" then
			sledWeightSpec = 30
			sledBounceSpec = 65
			sledAccelerationSpec = 65
			sledThrustSpec = 100
			sledSteeringSpec = 50
		end
		
		sledWeight = sledWeightSpec / sledOldFaithful.weight
			sledWeightAmount = 1/( sledWeight^(1/6) )
		sledBounce = sledBounceSpec / sledOldFaithful.bounce
			sledBounceAmount = sledBounce/2 - 0.5
		sledAcceleration = sledAccelerationSpec / sledOldFaithful.acceleration
		sledThrust = sledThrustSpec / sledOldFaithful.thrust
			sledThrustAmount = sledThrust^1.95
		sledSteering = sledSteeringSpec / sledOldFaithful.steering

		--CONFIG GAME
		configGame = nil
		configGame = {}
		configGame.state = "mainMenu" --"play"
		configGame.gravityCurrent_x = 0
		configGame.gravityCurrent_y = 0

		configGame.gravityBaseOrig = 9*sledWeight
		configGame.gravityBase = configGame.gravityBaseOrig
		configGame.gravityBaseTemp = nil

		configGame.gravityPlaneOrig = 3*sledThrustAmount
		configGame.gravityPlane = configGame.gravityPlaneOrig
		configGame.gravityPlaneTemp = nil

		configGame.gravityBoostSmallOrig = 20*sledWeight
		configGame.gravityBoostSmall = configGame.gravityBoostSmallOrig
		configGame.gravityBoostSmallTemp = nil

		configGame.gravityBoostLargeOrig = 30*sledWeight
		configGame.gravityBoostLarge = configGame.gravityBoostLargeOrig
		configGame.gravityBoostLargeTemp = nil

		configGame.wallSpeedOrig = 300
		configGame.wallSpeed = configGame.wallSpeedOrig
		configGame.wallSpeedTemp = nil

		configGame.wallSpeedMax = 600
		configGame.acceleration = 1--0.25

		configGame.wallEdge = 500

		configGame.missleVelocitySlow = 500
		configGame.missleVelocityFast = 800

		--MISC
		configGame.score = 0
		configGame.scoreBonus = 0
		configGame.coins = 0
		configGame.coinsBonus = 0
		configGame.scoreFactor = 1000/30000

		--configGame.region = "tutorial" -- Needs to be loaded
		configGame.regionStart = CURRENT_STAGE
		configGame.region = CURRENT_STAGE

		if configGame.region == "tutorial" then
			configGame.tutorial = true

		elseif configGame.region == "City" then

			tempValue = dbfunctions.getTableValue("generalSettings", "completedCityTutorial", "value")
			tempValue = tonumber(tempValue)
			if tempValue < 1 then
				configGame.tutorial = true
			end

		elseif configGame.region == "Military Camp" then

			tempValue = dbfunctions.getTableValue("generalSettings", "completedMilitaryCampTutorial", "value")
			tempValue = tonumber(tempValue)
			if tempValue < 1 then
				configGame.tutorial = true
			end
		else
			configGame.tutorial = nil
		end



		--CALCLATE SCORE BONUS---------------------
		local tempEnd = 1
		for i = 1,#regionTable do
			if regionTable[i].environment == configGame.region then
				tempEnd = i - 1

				if tempEnd < 1 then
					tempEnd = 1
				end
			end
		end

		local tempValue = 0
		for i = 1,tempEnd do
			if regionTable[i].environment ~= configGame.region then
				tempValue = tempValue + regionTable[i].length
			end
		end

		--configGame.bonusScore = math.round( (440/30000)*tempValue )

		-------------------------------------------

		configGame.pokeRadius = 200^2
		configGame.pokeBoost = 150
		configGame.gameBall_radius = 20
		configGame.portal_w = 50
		configGame.warp_delay = 750
		
		configGame.score = 0

		physics = require( "physics" ); physics.setDrawMode( mode ); physics.start()
		physics.setGravity(0,configGame.gravityBase)
		configGame.gravityCurrent_y = configGame.gravityBase
	end

	function pauseGame(event)

		if event.phase == "began" 
		or event.phase == "ended" then

			if configGame.state == "play" then
				--print("PAUSED GAME")
				
				display.remove(temp[1]) --removes began dot
				
				configGame.state = "paused"

				gameBall.xPaused = gameBall.x
				gameBall.yPaused = gameBall.y
				if gameBall.image.transitionHandle ~= nil then
					transition.pause( gameBall.image.transitionHandle )
				end
				

				--Pauses Tutorial
				if configGame.region == "tutorial" then

					for i = 1,#screenElementsTable do
						if screenElementsTable[i].type == "finger" then
							transition.pause( screenElementsTable[i] )
						end
					end

					if vTable.automatedDrawCircle ~= nil then
						vTable.automatedDrawCircle:setLinearVelocity(0,0)
					end
				end

				for i = 1,#timerTable do
					timer.pause( timerTable[i] )
				end
				
				--Pauses Draw Lines
				for i = #drawTable,1,-1 do
					transition.pause( drawTable[i] )
				end

				for i = 1,#wallTable do

					if wallTable[i].timerHandle ~= nil then
						timer.pause( wallTable[i].timerHandle )
					end

					if wallTable[i].type == "shockwave" 
					or wallTable[i].type == "explosion" then
						wallTable[i]:pause()
					end

					if wallTable[i].type == "pond"
					and wallTable[i].frame > 4
					and	wallTable[i].sequence == "normal" then
						wallTable[i]: pause()
					end
				end

				for i = 1,#snowPlowTable do
					timer.pause( snowPlowTable[i].timerHandle )
				end

				for i = 1,#fighterTable do
					if fighterTable[i].timerHandle ~= nil then
						timer.pause( fighterTable[i].timerHandle )
					end
				end

				for i = 1,#chopperTable do
					if chopperTable[i].timerHandle ~= nil then
						timer.pause( chopperTable[i].timerHandle )
					end
					if chopperTable[i].timerHandle2 ~= nil then
						timer.pause( chopperTable[i].timerHandle2)
					end
				end

				for i = 1,#effectsTable do
					if effectsTable[i].type == "snowBall" then
						effectsTable[i]:pause()
					end
				end

				physics.pause()
				
				--pause.createButton()
				local options = {
					isModal = true,
					effect = "flip",
					time = 125
				}
				composer.showOverlay( "pauseMenu",options )
				pauseButton.isVisible = false
				
				
				


				
			----------------------------------------
			----------------------------------------
			elseif configGame.state == "paused" then
				--print("RESUME GAME")

				configGame.state = "play"

				gameBall.xPaused = nil
				gameBall.yPaused = nil
				if gameBall.image.transitionHandle ~= nil then
					transition.resume( gameBall.image.transitionHandle )
				end

				--TUTORIAL
				if configGame.region == "tutorial" then
					for i = 1,#screenElementsTable do
						if screenElementsTable[i].type == "finger" then
							transition.resume( screenElementsTable[i] )
						end
					end

					if vTable.automatedDrawCircle ~= nil then
						vTable.automatedDrawCircle:setLinearVelocity( 0,-configGame.wallSpeed )
					end
				end

				for i = 1,#timerTable do
					timer.resume(timerTable[i])
				end
				
				for i = #drawTable,1,-1 do
					transition.resume( drawTable[i] )
				end

				for i = 1,#wallTable do

					if wallTable[i].timerHandle ~= nil then
						timer.resume( wallTable[i].timerHandle )
					end

					if wallTable[i].type == "shockwave" 
					or wallTable[i].type == "explosion" then
						wallTable[i]:play()
					end

					if wallTable[i].type == "pond"
					and wallTable[i].frame > 4
					and	wallTable[i].sequence == "normal" then
						wallTable[i]:play()
					end
				end

				--Start Plows
				for i = 1,#snowPlowTable do
					timer.resume( snowPlowTable[i].timerHandle )
				end

				for i = 1,#fighterTable do
					if fighterTable[i].timerHandle ~= nil then
						timer.resume( fighterTable[i].timerHandle )
					end
				end

				for i = 1,#chopperTable do
					if chopperTable[i].timerHandle ~= nil then
						timer.resume( chopperTable[i].timerHandle )
					end
					if chopperTable[i].timerHandle2 ~= nil then
						timer.resume( chopperTable[i].timerHandle2)
					end
				end

				for i = 1,#effectsTable do
					if effectsTable[i].type == "snowBall" then
						effectsTable[i]:play()
					end
				end
				
				physics.start()
				pauseButton.isVisible = true

			end

		end
	end

	function createPauseButton()

		pauseButton =  require("widget").newButton
		{
			left = 999,
			top = 999,
			defaultFile = "images/mainMenu/button_Pause.png",
			font = _font,
			--fontSize = 35,
			--label = regionTable[i].environment,
			width = 140,
			height = 140,
			cornerRadius = 4,
			rotate = 90,

			onEvent = function(event)
				if event.phase == "began" then
					pauseGame(event)
				end
			end
		}
		pauseButton.anchorX = 1
		pauseButton.anchorY = 0
		pauseButton.x = _W-50
		pauseButton.y = 50
		pauseButton.alpha = 0.85

		gforeground3:insert( pauseButton )
	end




	function setupGame()

		--print("setupGame")

		initializeGameVariables()

		createBackground(_H/2)
		createBackground(_H*3/2)
		createBackground(_H*5/2)

		--Create Screen Sensor
		id = #screenElementsTable+1
		screenElementsTable[id] = display.newRect(_W/2,_H_Real/2,_W,_H_Real)
		screenElementsTable[id].alpha = 0
		screenElementsTable[id].type = "screen"
		screenElementsTable[id].isHitTestable = true
		screenElementsTable[id]:addEventListener("touch",screenTouched)

		gforeground3:insert( screenElementsTable[id] )

		Runtime:addEventListener("enterFrame", onEveryFrame)
		createQueWall()
		timerTable[#timerTable+1] = timer.performWithDelay(10,removeWall,0)

		createMainMenuTrees( "autoFillTrees" )
	end

	function prepareGame()

		initializeGameVariables()
		--print("PREPARE!!")
		analytics.logEvent( "NewGame", {region = configGame.region} )
		

		if configGame.tutorial ~= nil 
		and configGame.region == "tutorial" then--TUTORIAL

			configGame.state = "prepare"

			for i = 1,#wallTable do

				if wallTable[i].type == "jump" 
				and wallTable[i].y > -300 then

						if configGame.wallSpeed ~= configGame.wallSpeedOrig*2 then
							configGame.wallSpeed = configGame.wallSpeedOrig*2
							changeWallSpeed(configGame.wallSpeed)
						end
						timerTable[#timerTable+1] = timer.performWithDelay(100,prepareGame,1)
						break

				elseif wallTable[i].type == "road" 
				and wallTable[i].y > -300 then

						if configGame.wallSpeed ~= configGame.wallSpeedOrig*2 then
							configGame.wallSpeed = configGame.wallSpeedOrig*2
							changeWallSpeed(configGame.wallSpeed)
						end
						timerTable[#timerTable+1] = timer.performWithDelay(100,prepareGame,1)
						break
					

				elseif i == #wallTable then
					configGame.wallSpeed = 0
					queWall:setLinearVelocity(0,0)
					stopWallsForTutorial()

					local id = #screenElementsTable+1
					screenElementsTable[id] = display.newCircle( _W/2, _H_Real/2, 50 )
					screenElementsTable[id].isVisible = false
					screenElementsTable[id].type = "target"
					--local tempChopper = createChopper( -150, -150, 45, screenElementsTable[id] )
					tempChopper = createChopper( _W/4, -200, 90, screenElementsTable[id] )
					tempChopper.special = "prepareGame"
					display.remove(tempChopper.shieldImage)
					timer.cancel(tempChopper.timerHandle)

					local id = #timerTable+1
					timerTable[id] = timer.performWithDelay(1,fireMissles,1)
					timerTable[id].params = {}
					timerTable[id].params.option = "option 1"
					timerTable[id].params.chopper = tempChopper

					local id = #timerTable+1
					timerTable[id] = timer.performWithDelay(10,finishPrepareGame,0)
					timerTable[id].params = {}
					timerTable[id].params.option = "option 1"
				end
			end

		else--NOT TUTORIAL
			physics.setGravity(0,0)

			--updateQueWall(queWall.y + 500) --THIS SHOULD BE DIFFERENT
			for i = #wallTable,1,-1 do
				if wallTable[i].x == nil then
					display.remove( wallTable[i] )
					table.remove( wallTable, i )
				end
			end

			id = #screenElementsTable+1
			screenElementsTable[id] = display.newCircle( _W/2, _H_Real/2, 50 )
			screenElementsTable[id].alpha = 0
			screenElementsTable[id].type = "target"
			tempChopper = createChopper( _W/4, -200, 90, screenElementsTable[id] )
			tempChopper:setLinearVelocity(0,500)
			tempChopper.special = "prepareGame"
			display.remove(tempChopper.shieldImage)
			timer.cancel(tempChopper.timerHandle)

			local id = #timerTable+1
			timerTable[id] = timer.performWithDelay(1,fireMissles,1)
			timerTable[id].params = {}
			timerTable[id].params.option = "option 2"
			timerTable[id].params.chopper = tempChopper

			local id = #timerTable+1
			timerTable[id] = timer.performWithDelay(10,finishPrepareGame,0)
			timerTable[id].params = {}
			timerTable[id].params.option = "option 2"

			local id = #timerTable+1
			timerTable[id] = timer.performWithDelay(50,gameReady,0)
			timerTable[id].params = {}
			timerTable[id].params.option = "option 2"
		end
	end

	function gameReady( event )

		for i = 1,#wallTable do

			if configGame.region ~= "tutorial"
			and wallTable[i].x > configGame.wallEdge
			and wallTable[i].x < 1536 - (configGame.wallEdge)
			and wallTable[i].y > 0
			and wallTable[i].y < 1200
			and wallTable[i].type ~= "explosion"
			and wallTable[i].type ~= "wind"
			and wallTable[i].type ~= "pond"
			and wallTable[i].type ~= "road" then

				break

			elseif configGame.region == "tutorial"
			and wallTable[i].x > configGame.wallEdge
			and wallTable[i].x < 1536 - (configGame.wallEdge)
			and wallTable[i].y > 0
			and wallTable[i].y < 300
			and wallTable[i].type ~= "explosion" then

				break

			elseif i == #wallTable then

				--print("READY")

				index = table.indexOf( timerTable, event.source )
				timer.cancel( timerTable[index] )
				table.remove( timerTable, index )

				configGame.state = "ready"
				createGameBall()
				sendNext()
				timer.cancel( event.source )

				if event ~= nil then
					local option = event.source.params.option

					if option == "option 1" then
						startGame()
					elseif option == "option 2" then
						local id = #screenElementsTable+1
						--screenElementsTable[id] = display.newCircle( _W/2, _H_Real*3/4, 100 )
						local options = 
							{
								--parent = textGroup,
								text = "Tap to Start",     
								x = _W/2,
								y = _H_Real*3/4,
								width = 900,
								height = 0,     --required for multi-line and alignment
								font = _font,   
								fontSize = _fontSize,
								align = "center"  --new alignment parameter
							}
						screenElementsTable[id] = display.newText( options )
						screenElementsTable[id].type = "tapText"
					end
				end
			end
		end
	end

	function fireMissles(event)

		local index = table.indexOf( timerTable, event.source )

		timer.cancel( timerTable[index] )
		table.remove( timerTable, index )

		--print("FIRE")
		local tempChopper = event.source.params.chopper

		--DESTROY VEHICLES
		for i = #fighterTable,1,-1 do
			wallExplosion( fighterTable[i] )
			recycle(fighterTable[i], fighterTable, i)
		end

		--Don't Remove Chopper the newest chopper it clears the scene
		for i = #chopperTable-1,1,-1 do
			wallExplosion( chopperTable[i] )
			recycle(chopperTable[i], chopperTable, i)
		end

		for i = #missleTable,1,-1 do
			wallExplosion( missleTable[i] )
			recycle(missleTable[i], missleTable, i)
		end


		--FIRE MISSLES
		if event.source.params.option == "option 1" then -- Fire one missle at a time

			tempChopper:setLinearVelocity(0,0)

			for i = 1,#wallTable do

				if wallTable[i].y > -300
				and wallTable[i].type ~= "pond"
				and wallTable[i].type ~= "jump"
				and wallTable[i].type ~= "wind"
				and wallTable[i].type ~= "road" 
				and wallTable[i].type ~= "fenceHole" then
					local id = #timerTable+1
					timerTable[id] = timer.performWithDelay(100*i, createMissleClosure, 1)
					timerTable[id].params = {}
					timerTable[id].params.object = tempChopper
					timerTable[id].params.animate = "no"
					timerTable[id].params.target = wallTable[i]

				elseif wallTable[i].type == "road" then
					for ii = #wallTable[i].plow,1,-1 do
						wallExplosion( wallTable[i].plow[ii] )
						recycle( wallTable[i].plow[ii], wallTable[i].plow )
					end
					timer.cancel( wallTable[i].timerHandle)

				elseif wallTable[i].type == "pond" 
				and wallTable[i].frame ~= 1 then
					restorePond( wallTable[i] )

				elseif wallTable[i].type == "jump" then
					coverJump( wallTable[i] )
				end
			end

			local tempTime = #wallTable*100
			local id = #timerTable+1
			timerTable[id] = timer.performWithDelay(tempTime, flyAway, 1)
			timerTable[id].params = {}
			timerTable[id].params.chopper = tempChopper
			timerTable[id].params.option = event.source.params.option

		elseif event.source.params.option == "option 2" then -- Fire all at once
			
			local tempTable = {}

			for i = 1,#wallTable do
				if wallTable[i].type == "gate"
				and wallTable[i].y > 0 then
					tempTable[#tempTable+1] = wallTable[i]
				elseif wallTable[i].x > configGame.wallEdge
				and wallTable[i].x < 1536 - configGame.wallEdge
				and wallTable[i].y > 0
				and wallTable[i].type ~= "wind"
				and wallTable[i].type ~= "pond"
				and wallTable[i].type ~= "jump"
				and wallTable[i].type ~= "road"
				and wallTable[i].type ~= "fenceHole" then
					tempTable[#tempTable+1] = wallTable[i]
				elseif wallTable[i].type == "road" then
					for ii = #wallTable[i].plow,1,-1 do
						wallExplosion(wallTable[i].plow[ii])
						recycle( wallTable[i].plow[ii], wallTable[i].plow )
					end
					timer.cancel( wallTable[i].timerHandle)
				elseif wallTable[i].type == "pond" 
				and wallTable[i].frame ~= 1 then
					restorePond( wallTable[i] )

				elseif wallTable[i].type == "jump"
				and wallTable[i].decal == nil then
					coverJump( wallTable[i] )
				end
			end

			for i = 1,#tempTable do
				local id = #timerTable+1
				timerTable[id] = timer.performWithDelay(100, createMissleClosure, 1)
				timerTable[id].params = {}
				timerTable[id].params.object = tempChopper
				timerTable[id].params.animate = "no"
				timerTable[id].params.target = tempTable[i]
			end

			local tempTime = #wallTable*100
			local id = #timerTable+1
			timerTable[id] = timer.performWithDelay(500, flyAway, 1)
			timerTable[id].params = {}
			timerTable[id].params.chopper = tempChopper
			timerTable[id].params.option = event.source.params.option
		end
	end

	function createMissleClosure(event)
		local tempParams = event.source.params
		local tempObject = event.source.params.object

		local _x = tempObject.x
		local _y = tempObject.y
		local _rotation = tempObject.rotation - 180

		local _animate = tempParams.animate
		local _target = tempParams.target
		local _velocity = "fast"

		createMissle( _x, _y, _rotation, _animate, _target, _velocity )
	end

	function flyAway( event )

		index = table.indexOf( timerTable, event.source )
		timer.cancel( timerTable[index] )
		table.remove( timerTable, index )

		local tempChopper = event.source.params.chopper
		local option = event.source.params.option

		local index = table.indexOf( screenElementsTable, tempChopper.target)
		screenElementsTable[index].x = -10000
		screenElementsTable[index].y = _H_Real/2

		tempChopper.attack = false
		tempChopper.velocity = 3000--tempChopper.velocity*10
		tempChopper.acceleration = 30--tempChopper.acceleration*10

		if option == "option 1" then
			timerTable[#timerTable+1] = timer.performWithDelay(50,gameReady,0)
			timerTable[#timerTable].params = {}
			timerTable[#timerTable].params.option = "option 1"
			
		end
	end

	function finishPrepareGame(event)
		for i = #chopperTable,1,-1 do
			animate(chopperTable[i])
			approachChopper(chopperTable[i])
			positionShield(chopperTable[i])

			if chopperTable[i].attack == false
			and chopperTable[i].x < - 150 then

				recycle( chopperTable[i], chopperTable, i)
				if event.source.params.option == "option 1" 
				and gameBall ~= nil then
					startPokeTutorial()
				end
			end
		end

		for i = #missleTable,1,-1 do
			animate(missleTable[i])
			approachFighter(missleTable[i])

			if missleTable[i].target.x ~= nil then
				local distance = common.getDistance( missleTable[i], missleTable[i].target)

				if distance < 30 then
					wallExplosion( missleTable[i].target )
					
					local index = table.indexOf( wallTable, missleTable[i].target )
					recycle( missleTable[i].target, wallTable, index )
					recycle( missleTable[i], missleTable, i)
				end

			else
				wallExplosion( missleTable[i] )
				recycle( missleTable[i], missleTable, i)
			end
		end
	end

	function startGame()

		--print("STARTGAME")
		
		gameBall.isAwake = true
		gameBall:setLinearVelocity(0,50)
		configGame.state = "play"
		for i = #screenElementsTable,1,-1 do
			if screenElementsTable[i].type == "tapText" then
				recycle( screenElementsTable[i], screenElementsTable, i)
			end
		end


		if configGame.region ~= "tutorial" then
			createScoreText()
		end

		if nextRegionTimer ~= nil then
			nextRegionTimer()
		end
		createPauseButton()
		timerTable[#timerTable+1] = timer.performWithDelay(15,gameBallOnScreenCheck,0)
		timerTable[#timerTable+1] = timer.performWithDelay(50,increaseWallSpeed,0)

		if configGame.region == "Wilderness" then
			timerTable[#timerTable+1] = timer.performWithDelay( 5000, sendEffect, 0 )
			timerTable[#timerTable].type = "sendEffect"
		elseif configGame.region == "Military Camp"
		and configGame.tutorial == nil then
			timerTable[#timerTable+1] = timer.performWithDelay( 5000, sendEffect, 0 )
			timerTable[#timerTable].type = "sendEffect"
		end
		--timerTable[#timerTable+1] = timer.performWithDelay(50, removeMisslesOffScreen, 0)
		timerTable[#timerTable+1] = timer.performWithDelay(250, fireAndReload, 0)

		myClosure3 = function() return firePrimaryDetermineSecondary(fighterTable) end
		timerTable[#timerTable+1] = timer.performWithDelay(100, myClosure3, 0)

		updateQueWall( queWall.y + 300 ) -- creates space before the first set of walls
	end

	function gameBallOnScreenCheck()
		if gameBall.x < - 60
		or gameBall.x > _W + 60
		or gameBall.y < -60
		or gameBall.y > _H_Real+ 60 then

			endGame()
		end
	end

	function removeEverything()

		--print("REMOVE EVERYTHING")

		if gameBall ~= nil then

			if gameBall.image.transitionHandle ~= nil then
				transition.cancel( gameBall.image.transitionHandle )
			end

			display.remove( gameBall.sled )
			display.remove( gameBall.pants )
			display.remove( gameBall.image )
			display.remove( gameBall.head )
			display.remove( gameBall.hat )

			gameBall.sled = nil
			gameBall.pants = nil
			gameBall.image = nil
			gameBall.head = nil
			gameBall.hat = nil

			display.remove( gameBall )

			gameBall = nil
		end
		Runtime:removeEventListener("enterFrame",maskAnimation)

		for i = #drawTable,1,-1 do
			killDrawLine( drawTable[i] )
		end
		display.remove( vTable.humanDrawCircle )
		display.remove( vTable.automatedDrawCircle )
		vTable.humanFinger_x = nil
		vTable.humanFinger_y = nil

		for i = #effectsTable,1,-1 do
			--recycle(effectsTable[i], effectsTable, i)
		end
		
		for i = #checkTable,1,-1 do
			checkTable[i] = nil
		end

		--DO NOT REMOVE FIRST TIMER, keeps remove walls
		for i = #timerTable,1+1,-1 do
			timer.cancel( timerTable[i] )
			table.remove( timerTable, i )
		end

		display.remove( txt_Score )
		txt_Score = nil

		display.remove( pauseButton )
		pauseButton = nil

		
		for i = #screenElementsTable,1,-1 do

			if screenElementsTable[i].type ~= "screen" then
				transition.cancel( screenElementsTable[i] )
				display.remove( screenElementsTable[i] )
				table.remove( screenElementsTable, i )
				screenElementsTable[i] = nil
			end
		end

		changeWallSpeed(configGame.wallSpeedOrig)
	end

	function endGame()

		--print("endGame")

		removeEverything()
		configGame.state = "ended"

		if configGame.tutorial ~= nil then
			configGame.tutorial = nil
			configGame.state = "mainMenu"
		end
		--scoreMenu.createButton()
		local options = {
			isModal = true,
			effect = "flip",
			time = 125,
			params = {
				screenImage = scene.view
			}
		}
		composer.showOverlay( "scoreMenu",options )
	end
--

--FUNDAMENTALE SETUP
	function createBackground(_y)
		
		if flip == nil then
			flip = 1
		end

		--Background
		local id = #backgroundTable+1
		backgroundTable[id] = display.newImageRect("images/game/background1.png",1536,2048)
		backgroundTable[id].x = _W/2
		backgroundTable[id].y = _y
		backgroundTable[id].xScale = 1
		backgroundTable[id].yScale = 1*flip
		backgroundTable[id]:setFillColor(0.8,0.8,.8)
		
		if #backgroundTable == 1 then
			physics.addBody( backgroundTable[id], "kinematic",
				{isSensor=true, filter = graphicCollisionFilter})
			backgroundTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		end
		
		gbackground1:insert( backgroundTable[id] )
		--backgroundTable[id]:toBack()
		flip = flip*-1

		

		--CREATE FENCES
		backgroundTable[id].left = display.newImage("images/game/fence.png")
		backgroundTable[id].leftBottom = display.newImage("images/game/fence.png")
		backgroundTable[id].right = display.newImage("images/game/fence.png")
		backgroundTable[id].rightBottom = display.newImage("images/game/fence.png")

		local tempTable = {}
		tempTable[#tempTable+1] = backgroundTable[id].left
		tempTable[#tempTable+1] = backgroundTable[id].leftBottom
		tempTable[#tempTable+1] = backgroundTable[id].right
		tempTable[#tempTable+1] = backgroundTable[id].rightBottom


		for i = 1,#tempTable do

			if i == 1 
			or i == 2 then
				tempTable[i].x = 50
				tempTable[i].xScale = -1
			elseif i == 3
			or i == 4 then
				tempTable[i].x = _W-50
				tempTable[i].xScale = 1
			end

			--tempTable[i].y = _y positioned on enter frame
			tempTable[i].yScale = 1.1
			tempTable[i].type = "fence"

			local tempShape

			if i == 1
			or i == 2 then
				local tempShape = { -50,-_H_Real/4, 50,-_H_Real/4, 50,_H_Real/4, -50,_H_Real/4 }
			elseif i == 3
			or i == 4 then
				local tempShape = { -50,-_H_Real/2, 50,-_H_Real/2, 50,_H_Real/2, -50,_H_Real/2 }
			end
			physics.addBody( tempTable[i], "static",
				{shape = tempShape, bounce=0.3, friction=0, filter = wallCollisionFilter})

			gground1:insert( tempTable[i] )
			--USED TO CREATE NEW FENCE MASK
			--if firstTime2 == nil then
			--	print("insertGroup")
			--	gfenceMask:insert( tempTable[i] )
			--end
		end
		--firstTime2 = true
	end

	function positionBackground()

		--Move Backgrounds to the end of the line
		if backgroundTable[1].y <= -1024 then
			backgroundTable[1].y = backgroundTable[1].y + (2048*3)
			backgroundTable[1].yScale = backgroundTable[1].yScale*-1
			backgroundTable[1].left:toFront()
			backgroundTable[1].right:toFront()
		elseif backgroundTable[2].y <= -1024 then
			backgroundTable[2].y = backgroundTable[1].y + 999 -- moves behind 1
			backgroundTable[2].yScale = backgroundTable[2].yScale*-1 -- flips
			backgroundTable[2].left:toFront()
			backgroundTable[2].right:toFront()
		elseif backgroundTable[3].y <= -1024 then
			backgroundTable[3].y = backgroundTable[1].y + 999
			backgroundTable[3].yScale = backgroundTable[3].yScale*-1
			backgroundTable[3].left:toFront()
			backgroundTable[3].right:toFront()
		end

		--SHOW/HIDE Fences
		for i = 1,#backgroundTable do

			if backgroundTable[i].y > 2048*1.5 then
				if configGame.region == "Military Camp"
				and configGame.state == "play" then
					backgroundTable[i].left.isVisible = false
					backgroundTable[i].left.isSensor = true
					backgroundTable[i].right.isVisible = false
					backgroundTable[i].right.isSensor = true
				else
					backgroundTable[i].left.isVisible = true
					backgroundTable[i].left.isSensor = false
					backgroundTable[i].right.isVisible = true
					backgroundTable[i].right.isSensor = false
				end
			end

			if backgroundTable[i].y > 2048 then
				if configGame.region == "Military Camp"
				and configGame.state == "play" then
					backgroundTable[i].leftBottom.isVisible = false
					backgroundTable[i].leftBottom.isSensor = true
					backgroundTable[i].rightBottom.isVisible = false
					backgroundTable[i].rightBottom.isSensor = true
				else
					backgroundTable[i].leftBottom.isVisible = true
					backgroundTable[i].leftBottom.isSensor = false
					backgroundTable[i].rightBottom.isVisible = true
					backgroundTable[i].rightBottom.isSensor = false
				end
			end
		end

		--Position Backgrounds
		if backgroundTable[1].y < backgroundTable[2].y then
			backgroundTable[2].y = backgroundTable[1].y + 2048
		else
			backgroundTable[2].y = backgroundTable[1].y - (2048*2)
		end

		if backgroundTable[1].y < backgroundTable[3].y then
			backgroundTable[3].y = backgroundTable[1].y + (2048*2)
		else
			backgroundTable[3].y = backgroundTable[1].y - 2048
		end


		--Position Fences
		backgroundTable[1].left.y = backgroundTable[1].y - 1024/2
		backgroundTable[1].leftBottom.y = backgroundTable[1].y + 1024/2
		backgroundTable[1].right.y = backgroundTable[1].y - 1024/2
		backgroundTable[1].rightBottom.y = backgroundTable[1].y + 1024/2

		backgroundTable[2].left.y = backgroundTable[2].y - 1024/2
		backgroundTable[2].leftBottom.y = backgroundTable[2].y + 1024/2
		backgroundTable[2].right.y = backgroundTable[2].y - 1024/2
		backgroundTable[2].rightBottom.y = backgroundTable[2].y + 1024/2

		backgroundTable[3].left.y = backgroundTable[3].y - 1024/2
		backgroundTable[3].leftBottom.y = backgroundTable[3].y + 1024/2
		backgroundTable[3].right.y = backgroundTable[3].y - 1024/2
		backgroundTable[3].rightBottom.y = backgroundTable[3].y + 1024/2

		--[[timer.performWithDelay( 1,
			function()
				if firstTime == nil then
					print("CAPTURE")
					display.save( gfenceMask,
						{filename="temp.jpg",
						baseDir=system.DocumentsDirectory,
						isFullResolution=true
						}
					)

					firstTime = true
				end
			end
		)]]
	end




	function createGameBall( _x, _y, rot, vx, vy )

		

		if _x == nil then _x = _W/2 end
		if _y == nil then _y = 100 end
		if rot == nil then rot = 180 end
		if vx == nil then vx = 0 end
		if vy == nil then vy = 0 end

		_x = _W/2
		_y = 100
		rot = 180
		vx = 0
		vy = 0

		local _Scale = 0.6
		
		gameBall = display.newCircle(999,999,configGame.gameBall_radius)

		gameBall.x = _x
		gameBall.y = _y
		gameBall.isVisible = false
		
		gameBall.type = "gameBall"
		--gameBall.wind = nil
		gameBall.fenceHole = 0 -- If fenceHole > 0 avoid Fence
		gameBall.hitSnowBall = nil
		--gameBall.bridge = nil
		--gameBall.hitVelocity = nil Used for sounds
		gameBall.jumpAirbourne = nil
		gameBall.jumpCleared = nil
		
		physics.addBody( gameBall, "dynamic",
			{radius = configGame.gameBall_radius,
			friction = 0.01,
			bounce = sledBounceAmount,
			filter = player1CollisionFilter})
		gameBall.isBullet = true
		gameBall.hasListener = nil
		gameBall:setLinearVelocity(vx,vy)
		gameBall.isFixedRotation = true
		gameBall.isAwake = false

		gameBall.postCollision = gameBallCollided
		gameBall:addEventListener("postCollision", gameBall)
		
		
		
		--BODY
		local skier_SheetData = {
			width=96,
			height=107,
			numFrames=36,
			sheetContentWidth=2016,
			sheetContentHeight=214
		}


		local _offsetX = 0
		local _offsetY = -5

		local tempImage = dbfunctions.getSelectedImage("jacketTable", "imageGame")
		local skier_Sheet = graphics.newImageSheet( "images/gearGame/"..tempImage, skier_SheetData)
		
		local skier_sequenceData = {
			{name = "normal", start = 1,count = 36, time =1000}--,
			}
			
		gameBall.image = display.newSprite( skier_Sheet, skier_sequenceData)
		gameBall.image.timeScale = 1
		gameBall.image:setFrame( 1 )

		local mask = graphics.newMask( "images/game/mask.png" )
		gameBall.image:setMask( mask )

		gameBall.image.x = _x + _offsetX * _Scale
		gameBall.image.y = _y + _offsetY * _Scale
		gameBall.image.xOffset = _offsetX * _Scale
		gameBall.image.yOffset = _offsetY * _Scale
		gameBall.image.xScale = _Scale
		gameBall.image.yScale = _Scale
		plane_cur_angle = rot
		gameBall.angle = plane_cur_angle
		
		gground2:insert( gameBall.image )

		--HEAD
		local skier_SheetData = {
			width=93,
			height=82,
			numFrames=36,
			sheetContentWidth=2046,
			sheetContentHeight=164
		}


		local _offsetX = 0
		local _offsetY = -60

		local skier_Sheet = graphics.newImageSheet( "images/gearGame/Head_Game.png", skier_SheetData)
			
		gameBall.head = display.newSprite( skier_Sheet, skier_sequenceData)
		gameBall.head.timeScale = 1
		gameBall.head:setFrame( 1 )

		local mask = graphics.newMask( "images/game/mask.png" )
		gameBall.head:setMask( mask )

		gameBall.head.x = _x + _offsetX * _Scale
		gameBall.head.y = _y + _offsetY * _Scale
		gameBall.head.xOffset = _offsetX * _Scale
		gameBall.head.yOffset = _offsetY * _Scale
		gameBall.head.xScale = _Scale
		gameBall.head.yScale = _Scale
		
		gground2:insert( gameBall.head )

		--Pants
		local skier_SheetData = {
			width=54,
			height=54,
			numFrames=36,
			sheetContentWidth=1944,
			sheetContentHeight=54
		}


		local _offsetX = 0
		local _offsetY = 30

		local tempImage = dbfunctions.getSelectedImage("pantsTable", "imageGame")
		local skier_Sheet = graphics.newImageSheet( "images/gearGame/"..tempImage, skier_SheetData)

		gameBall.pants = display.newSprite( skier_Sheet, skier_sequenceData)
		gameBall.pants.timeScale = 1
		gameBall.pants:setFrame( 1 )

		local mask = graphics.newMask( "images/game/mask.png" )
		gameBall.pants:setMask( mask )

		gameBall.pants.x = _x + _offsetX * _Scale
		gameBall.pants.y = _y + _offsetY * _Scale
		gameBall.pants.xOffset = _offsetX * _Scale
		gameBall.pants.yOffset = _offsetY * _Scale
		gameBall.pants.xScale = _Scale
		gameBall.pants.yScale = _Scale
		
		gground2:insert( gameBall.pants )

		--Hat
		local skier_SheetData = {
			width=86,
			height=71,
			numFrames=36,
			sheetContentWidth=1978,
			sheetContentHeight=142
		}


		local _offsetX = 0
		local _offsetY = -70

		local tempImage = dbfunctions.getSelectedImage("hatTable", "imageGame")
		local skier_Sheet = graphics.newImageSheet( "images/gearGame/"..tempImage, skier_SheetData)
		
		gameBall.hat = display.newSprite( skier_Sheet, skier_sequenceData)
		gameBall.hat.timeScale = 1
		gameBall.hat:setFrame( 1 )

		local mask = graphics.newMask( "images/game/mask.png" )
		gameBall.hat:setMask( mask )

		gameBall.hat.x = _x + _offsetX * _Scale
		gameBall.hat.y = _y + _offsetY * _Scale
		gameBall.hat.xOffset = _offsetX * _Scale
		gameBall.hat.yOffset = _offsetY * _Scale
		gameBall.hat.xScale = _Scale
		gameBall.hat.yScale = _Scale
		
		gground2:insert( gameBall.hat )

		--SLED
		local tempImage = dbfunctions.getSelectedImage("sledTable", "imageGame")

		if tempImage == "Sled_OldFaithful_Game.png" then

			skier_SheetData = { 
				width=226,
				height=165,
				numFrames=36,
				sheetContentWidth=2034,
				sheetContentHeight=660
			}


			_offsetX = 0
			_offsetY = 33

		elseif tempImage == "Sled_Lead_Game.png" then

			skier_SheetData = { 
				width=272,
				height=179,
				numFrames=36,
				sheetContentWidth=1904,
				sheetContentHeight=1074
			}


			_offsetX = 0
			_offsetY = 41

		elseif tempImage == "Sled_Turbo_Game.png" then

			skier_SheetData = { 
				width=249,
				height=185,
				numFrames=36,
				sheetContentWidth=1992,
				sheetContentHeight=925
			}

			_offsetX = 0
			_offsetY = 13

		end



		local skier_Sheet = graphics.newImageSheet( "images/gearGame/"..tempImage, skier_SheetData)
		
		gameBall.sled = display.newSprite( skier_Sheet, skier_sequenceData)
		gameBall.sled.timeScale = 1
		gameBall.sled:setFrame( 1 )

		local mask = graphics.newMask( "images/game/mask.png" )
		gameBall.sled:setMask( mask )

		gameBall.sled.x = _x + _offsetX * _Scale
		gameBall.sled.y = _y + _offsetY * _Scale
		gameBall.sled.xOffset = _offsetX * _Scale
		gameBall.sled.yOffset = _offsetY * _Scale
		gameBall.sled.xScale = _Scale
		gameBall.sled.yScale = _Scale
		
		gground2:insert( gameBall.sled )

		--ORDER
		
		gameBall.pants:toFront()
		gameBall.image:toFront()
		gameBall.head:toFront()
		gameBall.hat:toFront()
		gameBall.sled:toFront()
	end

	function gameBallCollided(self, event)

		if event.force > 0.2 then

			multiplyer = (event.force-0.2)*22.5+1
			if multiplyer > 10 then
				multiplyer = 10
			elseif multiplyer < 1 then
				multiplyer = 1
			end

			if event.other.type == "normal" then
				soundCheck(thumpWoodSound,0.1*multiplyer)
			elseif event.other.type == "barrel" then
				soundCheck(barrelSound,0.1*multiplyer)
			elseif event.other.type == "house" then
				soundCheck(thumpSound,0.1*multiplyer)
			elseif event.other.type == "plow" then
				soundCheck(hitMetalSound,0.1*multiplyer)
			elseif event.other.type == "windmill" then
				soundCheck(hitMetalSound,0.1*multiplyer)
			elseif event.other.type == "boulder" then
				soundCheck(thumpWoodSound,0.1*multiplyer)
			elseif event.other.type == "fence" then
				soundCheck(thumpWoodSound,0.1*multiplyer)
			end

		end
	end

	function jetPack(vx, vy, velocity)

		local force_x
		local force_y
		local _f = configGame.wallSpeed / configGame.wallSpeedOrig
		if _f < 1 then
			_f = 1
		end

		if velocity ~= 0 then

			if gameBall.wind ~= nil then
				force_x = (vx/velocity)*configGame.gravityPlane + gameBall.wind
			else
				force_x = (vx/velocity)*configGame.gravityPlane
			end

			
			if math.abs(velocity) < 300 then
				force_y = configGame.gravityBoostLarge
			elseif math.abs(velocity) < 500 then
				force_y = configGame.gravityBoostSmall
			else
				force_y = (vy/velocity)*configGame.gravityPlane + configGame.gravityBase
			end

			if configGame.region == "tutorial" then
				force_x = 0
				force_y = force_y*1.5
			end
			
			physics.setGravity(force_x*_f,force_y*_f)
		end
	end

	function animationRotation( vx, vy, velocity )
		
		local plane_cur_angle
		local new_angle
		local rot
		local clockwise_angle
		local counter_angle

		local _theta
		local frame

		--gameBall.image.x = gameBall.x
		--gameBall.image.y = gameBall.y
		--ANIMATION ROTATION
		plane_cur_angle = gameBall.angle
			
		if math.sqrt(vx^2 + vy^2) > 250 or vy > 0 then

			new_angle = math.atan2(vy,vx)*degrees_conversion +90

			if new_angle < 0 then new_angle = new_angle + 360 end
			if new_angle < plane_cur_angle then new_angle = new_angle + 360 end

			rot = 0
			clockwise_angle = new_angle - plane_cur_angle
			counter_angle = plane_cur_angle - new_angle

			if counter_angle < 0 then
				counter_angle = counter_angle + 360
			end
			
			--CLOCKWISE
			if clockwise_angle < counter_angle
			and clockwise_angle < 10 then
				rot = clockwise_angle
			elseif clockwise_angle < counter_angle
			and clockwise_angle > 10 then
				clockwise_angle = 10 
				rot = clockwise_angle
			--COUNTER CLOCKWISE
			elseif counter_angle < clockwise_angle
			and counter_angle < 10 then
				counter_angle = counter_angle * -1
				rot = counter_angle
			elseif counter_angle < clockwise_angle
			and counter_angle > 10 then
				counter_angle = 10 
				counter_angle = counter_angle * -1
				rot = counter_angle
			end

			_theta = plane_cur_angle

			if _theta < 180 then
				frame = math.round( 19 - ( _theta/10 ) )
			elseif _theta >= 180 then
				frame = math.round( 55 - ( _theta/10 ) )
			end

			while frame > 36 do
				frame = frame - 36
			end

			gameBall.frame = frame
			gameBall.image:setFrame( gameBall.frame )
			
			plane_cur_angle = plane_cur_angle + rot

			if plane_cur_angle > 360 then plane_cur_angle = plane_cur_angle - 360 end
			if plane_cur_angle > 360 then plane_cur_angle = plane_cur_angle - 360 end
			if plane_cur_angle < 0 then plane_cur_angle = plane_cur_angle + 360 end

			gameBall.angle = plane_cur_angle
		end
	end

	function animateGameBallDecals()
		if gameBall.image ~= nil then

			local tempTable = {}
			tempTable[#tempTable+1] = gameBall.hat
			tempTable[#tempTable+1] = gameBall.head
			tempTable[#tempTable+1] = gameBall.image
			tempTable[#tempTable+1] = gameBall.pants
			tempTable[#tempTable+1] = gameBall.sled

			for i = 1,#tempTable do

				local _scaleOrig = 0.6
				local _scaleNew = gameBall.image.xScale
				local _frame = gameBall.frame
				
				--Position
				local _xOffset = tempTable[i].xOffset * (_scaleNew/_scaleOrig)
				local _yOffset = tempTable[i].yOffset * (_scaleNew/_scaleOrig)

				tempTable[i].x = gameBall.x + _xOffset
				tempTable[i].y = gameBall.y + _yOffset

				--Scale
				tempTable[i].xScale = _scaleNew
				tempTable[i].yScale = _scaleNew

				--Frame
				tempTable[i]:setFrame( _frame )
			end
		end
	end

	function createScoreText()

		display.remove(txt_Score)
		txt_Score = nil

		local score = 0
		txt_Score = display.newText(score,120,75, _font,_fontSizeSmall)
		gforeground3:insert( txt_Score )

		createScoreTimer()
	end

	function createScoreTimer()

		local id = #timerTable+1
		timerTable[id] = timer.performWithDelay(50, updateScore, 0)
		timerTable[id].type = "score"
		timerTable[id].updateRate = 50
		timerTable[id].bonusScore = 0

		for i = 1,#regionTable do
			

			if regionTable[i].environment == configGame.region then
				timerTable[id].timeNeeded = regionTable[i].length
				timerTable[id].coinsMultiplier = i-1
				break
			end
			timerTable[id].bonusScore = timerTable[id].bonusScore + regionTable[i].length * configGame.scoreFactor
			if configGame.bonusScore == nil then
				configGame.bonusScore = timerTable[id].bonusScore
			end
		end
	end

	function updateScore(event)

		local tempTimer = event.source

		local timePassed = event.count*tempTimer.updateRate
		local scorePartial = timePassed*configGame.scoreFactor
		local scoreTotal = math.round( scorePartial + tempTimer.bonusScore )

		txt_Score.text = scoreTotal
		configGame.score = scoreTotal
		configGame.coins = scorePartial*0.05*tempTimer.coinsMultiplier

		if timePassed >= tempTimer.timeNeeded then
			
			--Cancel and remove
			local index = table.indexOf( timerTable, tempTimer )
			table.remove( timerTable, index)
			timer.cancel(tempTimer)
			tempTimer = nil

			configGame.coinsBonus = configGame.coinsBonus + configGame.coins
			configGame.coins = 0

			nextRegion()
			createScoreTimer()
		end
	end

	function pauseResumeScore( action )
		
		if action == "pause" then

			for i = 1,#timerTable do
				if timerTable[i].type == "score" then
					timer.pause( timerTable[i] )
					break
				end
			end

		elseif action == "resume" then

			for i = 1,#timerTable do
				if timerTable[i].type == "score" then
					timer.resume( timerTable[i] )
					break
				end
			end
		end
	end
--

--GAME CONTROLS
	function screenTouched( event )

		if configGame.state == "ready"
		and configGame.region ~= "tutorial"
		and event.phase == "ended" then
			startGame()

		elseif configGame.state == "play" then
			
			--Poke and Poke Tutorial
			local _delta_x = gameBall.x - event.x
			local _delta_y = gameBall.y - event.y
		
			if _delta_x^2 + _delta_y^2 < configGame.pokeRadius then

				if event.phase == "began"
				and gameBall ~= nil then

					if configGame.tutorial == "tut_pokeRight"
					and gameBall.x > event.x then
						pokePlayer(event)
						configGame.tutorial = "tut_pokeLeft"

					elseif configGame.tutorial == "tut_pokeLeft"
					and event.x > gameBall.x then
						pokePlayer(event)
						configGame.tutorial = "tut_pokeFinish"

					elseif configGame.tutorial == "tut_pokeFinish"
					and gameBall.x < event.x then
						pokePlayer(event)

					elseif configGame.tutorial == nil
					or configGame.tutorial == "tut_gate" 
					or configGame.tutorial == "tut_helicopter" then -- When Tutorial is not in progress
						pokePlayer(event)
						--print("poke")

					end
				end
			end
			
			--Drawing
			if event.phase == "began"
			and configGame.state == "play" then
				-- prevents 2 begin event points if the event is cancelled by sliding finger off the screen
				configDraw.state = "inProgress"
				vTable.humanFinger_x = event.x

				vTable.humanDrawCircle = display.newCircle(event.x,event.y, configDraw.w/2)
				vTable.humanDrawCircle:setFillColor(255,255,255)
				physics.addBody( vTable.humanDrawCircle, "kinematic",{friction = 0, bounce = 0,isSensor=true, filter = drawLinesCollisionFilter})
				vTable.humanDrawCircle:setLinearVelocity(0,-configGame.wallSpeed)
			end

					
			-- creates lines for continuous event used in function drawWithoutMoving
			if event.phase == "moved"
			and configGame.state == "play"
			and configDraw.state == "inProgress" then
				vTable.humanFinger_x = event.x
				vTable.humanFinger_y = event.y
			end
			
			
			if configDraw.type == "continuous"
			and event.phase == "moved"
			and configGame.state == "play"
			and configDraw.state == "inProgress"
			and overload == nil
			and vTable.humanDrawCircle ~= nil
			and (math.abs(vTable.humanDrawCircle.x-vTable.humanFinger_x)^2 + 
				math.abs(vTable.humanDrawCircle.y-vTable.humanFinger_y)^2
				) > configDraw.length then
							
				--overload = 1
				createDrawLines(
					vTable.humanDrawCircle,
					vTable.humanDrawCircle.x, vTable.humanDrawCircle.y,
					event.x, event.y)
			
			elseif configDraw.type == "continuous"
			and event.phase == "moved"
			and configGame.state == "play"
			and configDraw.state == "inProgress"
			and overload == nil
			and vTable.humanDrawCircle == nil then
				
				vTable.humanDrawCircle.x = event.x
				vTable.humanDrawCircle.y = event.y
				vTable.humanDrawCircle:setFillColor(255,255,255)
			end
			
			-- create line segment
			if configDraw.type == "segment"
			and event.phase == "ended"
			and configGame.state == "play"
			and configDraw.state == "inProgress" then		
				createDrawLines(
					vTable.humanDrawCircle,
					vTable.humanDrawCircle.x, vTable.humanDrawCircle.y,
					event.x, event.y)
			end
			
			if event.phase == "ended"
			and configDraw.state == "inProgress" then
				configDraw.state = nil
				display.remove(vTable.humanDrawCircle)
				table.remove( vTable, humanDrawCircle)
				vTable.humanDrawCircle = nil

				vTable.humanFinger_x = nil
				vTable.humanFinger_y = nil
			end

		end
	end

	function pokePlayer( draw )

		soundCheck(pokeSound)
		local _f = configGame.wallSpeed / configGame.wallSpeedOrig
		if _f < 1 then
			_f = 1
		end

		local vx, vy = gameBall:getLinearVelocity()

		local _delta_x = gameBall.x - draw.x
		local _delta_y = gameBall.y - draw.y
		local _angle = math.atan2(_delta_y,_delta_x)

		local boost_x = configGame.pokeBoost*math.cos(_angle)*_f
		local boost_y = configGame.pokeBoost*math.sin(_angle)*_f

		local new_vx = boost_x + vx
		local new_yx = boost_y + vy
		gameBall:setLinearVelocity(new_vx,new_yx)
	end

	function createDrawLines( object, pointA_x, pointA_y, pointB_x, pointB_y )

		if (pointA_x-pointB_x)^2 + (pointA_y-pointB_y)^2 > configDraw.length then

			local midPointX = (pointA_x+pointB_x)/2
			local midPointY = (pointA_y+pointB_y)/2

			local length = math.sqrt(
				(pointB_x-pointA_x)^2 + 
				(pointB_y-pointA_y)^2
				)
						
			local _delta_x = pointB_x-pointA_x -- used for calculating _angle
			local _delta_y = pointB_y-pointA_y  -- used for calculating _angle
			local _angle = math.atan2(_delta_y,_delta_x)*degrees_conversion -- radian _angle converted to degrees using 180/pi	
			
			local id = #drawTable+1
			
			drawTable[id] = display.newRoundedRect(999,999,length+configDraw.w,configDraw.w,configDraw.w/2)
			drawTable[id].x = midPointX
			drawTable[id].y = midPointY
			drawTable[id].rotation = _angle
			drawTable[id]:setFillColor(configDraw.red, configDraw.green, configDraw.blue)
			drawTable[id].alpha = 0
			drawTable[id].type = "draw"
			
			local half_Length = length/2
			
			physics.addBody( drawTable[id], "kinematic",
				{shape={-half_Length,-7.5, -half_Length,7.5, -half_Length-3.2541,6.7573, -half_Length-5.8637,4.6762, -half_Length-7.3120,1.6689, 
					-half_Length-7.3120,-1.6689, -half_Length-5.8637,-4.6762, -half_Length-3.2541,-6.7573,},
					friction = 0, bounce = 0, isSensor=true, filter = drawLinesCollisionFilter },
				
				{shape={-half_Length,-7.5, half_Length,-7.5, half_Length,7.5, -half_Length,7.5},
					friction = 0, bounce = 0, isSensor=true, filter = drawLinesCollisionFilter },
				
				{shape={half_Length,-7.5, half_Length+3.2541,-6.7573, half_Length+5.8637,-4.6762, half_Length+7.3120,-1.6689,
					half_Length+7.3120,1.6689, half_Length+5.8637,4.6762, half_Length+3.2541,6.7573, half_Length,7.5, },
					friction = 0, bounce = 0, isSensor=true, filter = drawLinesCollisionFilter }
			)
			
			drawTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
			gsky3:insert( drawTable[id] )

			local checkTable_ID = #checkTable+1
			checkTable[checkTable_ID] = drawTable[id]
			checkTable[checkTable_ID].collision = checkInterference
			checkTable[checkTable_ID]:addEventListener("collision", checkTable[checkTable_ID])
			checkTable[checkTable_ID].check = 0

			

			--Update The location of the draw point
			object.x = pointB_x
			object.y = pointB_y
		end
	end

	function checkInterference(self, event)

		if self.check < 1 then
			slashEnemies(event.other) -- DAMAGE ENEMIES
			
			if event.other.type == "gameBall" then
				
				display.remove(self)

				local tableNumber = table.indexOf( checkTable, self )
				table.remove(checkTable, tableNumber)

				local tableNumber = table.indexOf( drawTable, self )
				table.remove(drawTable, tableNumber)
			end
		end
	end

	function killDrawLine(obj)	

		local id = table.indexOf( drawTable, obj )
		display.remove(obj)
		transition.cancel( obj )
		table.remove(drawTable, id)
	end

	function drawOnPlane()
		--PREVENTS Ball from being drawn on ........ not perfect
		local id

		for i = #checkTable,1,-1 do
			checkTable[i].check = checkTable[i].check + 1
			if checkTable[i].check > 1 then

				id = table.indexOf( drawTable, checkTable[i] )

				if id ~= nil then

					drawTable[id].isSensor = false
					drawTable[id].alpha = 1
					
					drawTable[id].onComplete = killDrawLine
					drawTable[id].transitionHandle = transition.to(drawTable[id], 
						{alpha = 1, xScale=.95, yScale=0.15,time = configDraw.time, onComplete=drawTable[id]})

					drawTable[id].time = configDraw.time
					
					table.remove(checkTable, i)

				elseif id == nil then
					table.remove(checkTable, i)
				end
			end
		end
	end

	function drawWithoutMoving()--onEvery Frame
		if configDraw.type == "continuous"
		and configDraw.state == "inProgress"
		and vTable.humanDrawCircle ~= nil
		and vTable.humanFinger_x ~= nil
		and vTable.humanFinger_y ~= nil
		and (vTable.humanDrawCircle.x-vTable.humanFinger_x)^2
			+ (vTable.humanDrawCircle.y-vTable.humanFinger_y)^2
			> configDraw.length then

			createDrawLines(
				vTable.humanDrawCircle,
				vTable.humanDrawCircle.x, vTable.humanDrawCircle.y,
				vTable.humanFinger_x, vTable.humanFinger_y)
		end
	end
--

--TUTORIAL DRAW
	function createTutorialElements()
		configGame.wallSpeed = 0

		--CREATE FINGER
		local id = #screenElementsTable+1
		screenElementsTable[id] = display.newImage("images/game/finger.png")
		screenElementsTable[id].xScale = 1
		screenElementsTable[id].yScale = 1
		screenElementsTable[id].type = "finger"
		screenElementsTable[id].transitionPoint = 0

		gsky2:insert( screenElementsTable[id] )

		--Create Tutorial Text
		local id = #screenElementsTable+1

		local options = 
			{
				--parent = textGroup,
				text = "",     
				x = _W/2,
				y = 1000,
				width = 900,
				height = 0,     --required for multi-line and alignment
				font = _font,   
				fontSize = _fontSize,
				align = "center"  --new alignment parameter
			}
		screenElementsTable[id] = display.newText( options )
		screenElementsTable[id]:setFillColor(1,1,1)
		screenElementsTable[id].anchorY = 0

		screenElementsTable[id].type = "tutorialText"
		gforeground1:insert( screenElementsTable[id] )

		timerTable[#timerTable+1] = timer.performWithDelay(10,updatePokeTutorial,0)
	end

	function stopWallsForTutorial()
		--STOP WALLS
		queWall:setLinearVelocity(0,0)

		for i = 1,#drawTable do
			drawTable[i]:setLinearVelocity(0,0)
		end

		for i = 1,#wallTable do

			wallTable[i]:setLinearVelocity(0,0)
			if wallTable[i].type == "gate" then
				wallTable[i].leftGate:setLinearVelocity(0,0)
				wallTable[i].rightGate:setLinearVelocity(0,0)
			end
		end

		backgroundTable[1]:setLinearVelocity(0,0)
	end

	function startWalls(option)

		configGame.wallSpeed = configGame.wallSpeedOrig

		if option == "option 1" then
			--Do Nothing Special
		else
			queWall:setLinearVelocity(0,-configGame.wallSpeed)
		end

		if vTable ~= nil then
			if vTable.humanDrawCircle ~= nil then
				vTable.humanDrawCircle:setLinearVelocity(0,-configGame.wallSpeed)
			end
		end

		for i = 1,#drawTable do
			drawTable[i]:setLinearVelocity(0,-configGame.wallSpeed)
		end

		for i = 1,#wallTable do
			wallTable[i]:setLinearVelocity(0,-configGame.wallSpeed)

			if wallTable[i].timerHandle ~= nil then
				timer.resume( wallTable[i].timerHandle )
			end

			if wallTable[i].type == "gate" then
				wallTable[i].leftGate:setLinearVelocity(0,-configGame.wallSpeed)
				wallTable[i].rightGate:setLinearVelocity(0,-configGame.wallSpeed)
			end
		end

		backgroundTable[1]:setLinearVelocity(0,-configGame.wallSpeed)

		--
	end



	function startTutorial()

		if configGame.region == "tutorial" then
			wallNormal(768,300,300,0)

		elseif configGame.region == "City" then
			configGame.tutorial = "City Tutorial"

		elseif configGame.region == "Military Camp" then
			configGame.tutorial = "Military Camp Tutorial"
		end
	end

	function startPokeTutorial(event)

		createTutorialElements()

		updateQueWall(2300)
		queWall:setLinearVelocity(0,0)

		local finger
		local tutorialText

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "finger" then
				finger = screenElementsTable[i]
			end
		end

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "tutorialText" then
				tutorialText = screenElementsTable[i]
			end
		end

		--Update finger Position
		finger.alpha = 1
		finger.x = 768
		finger.y = 500

		--Update tutorialText
		configGame.tutorial = "tut_pokeRight"
		tutorialText.text = "Tap the screen on the left side of the player to push the player to the right."
		tutorialText.x = 768
		tutorialText.y = 1000

		gforeground1:insert( tutorialText )


		--Create Poke Tutorial
		local sheetData = {
			width=400,
			height=400,
			numFrames=7,
			sheetContentWidth=2800,
			sheetContentHeight=400
		}

		local Sheet = graphics.newImageSheet( "images/game/poke.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 7, time=400, loopCount=0}
			}

		local id = #screenElementsTable+1

		screenElementsTable[id] = display.newSprite( Sheet, sequenceData)
		screenElementsTable[id].xScale = 1
		screenElementsTable[id].yScale = 1
		screenElementsTable[id]:setFrame(1)
		screenElementsTable[id]:play()

		screenElementsTable[id].x = 725
		screenElementsTable[id].y = 300
		screenElementsTable[id].alpha = 0.5
		screenElementsTable[id].type = "pokeTutorial"

		gsky2:insert( screenElementsTable[id] )
		finger:toFront()
	end

	function updatePokeTutorial()

		local pokeTutorial
		local tutorialText
		local finger

		for i = 1,#screenElementsTable do

			if screenElementsTable[i].type == "pokeTutorial" then
				pokeTutorial = screenElementsTable[i]
			end

			if screenElementsTable[i].type == "tutorialText" then
				tutorialText = screenElementsTable[i]
			end

			if screenElementsTable[i].type == "finger" then
				finger = screenElementsTable[i]
			end
		end


		if configGame.tutorial == "tut_pokeRight" then
			pokeTutorial.x = gameBall.x - 60
			finger.x = gameBall.x - 30

		elseif configGame.tutorial == "tut_pokeLeft" then
			pokeTutorial.x = gameBall.x + 30 + 30
			finger.x = gameBall.x + 60 + 30
			tutorialText.text = "Good! Now tap the screen on the right side of the player."

		elseif configGame.tutorial == "tut_pokeFinish"
		and gameBall.y <= 300 then
			pokeTutorial.x = gameBall.x + 30 + 30
			finger.x = gameBall.x + 60 + 30
			tutorialText.text = "Great! Continue tapping the screen on the right side of the player."

		elseif configGame.tutorial == "tut_pokeFinish"
		and gameBall.y > 300 then

			configGame.wallSpeed = configGame.wallSpeedOrig
			finishPokeTutorial()
			
			if finger.transitionHandle ~= nil then
				transition.cancel( finger.transitionHandle )
				finger.transitionHandle = nil
			end

			finger.x = 200
			vTable.automatedDrawCircle = display.newCircle( finger.x, finger.y-200, configDraw.w/2 ) --Use Chords if called by drawWithoutMoving()
			vTable.automatedDrawCircle:setFillColor(255,255,255)
			physics.addBody( vTable.automatedDrawCircle, "kinematic",{friction = 0, bounce = 0,isSensor=true, filter = drawLinesCollisionFilter})
			vTable.automatedDrawCircle:setLinearVelocity(0,-configGame.wallSpeed)

			timerTable[#timerTable+1] = timer.performWithDelay(10, createTutorialDrawLines, 0)
			updateTutorialDraw()

			configGame.tutorial = "tut_draw"
		end
	end

	function finishPokeTutorial()

		--Remove Timer
		for i = #timerTable,1,-1 do
			if timerTable[i]._listener == updatePokeTutorial then
				timer.cancel( timerTable[i] )
				table.remove( timerTable, i )
			end
		end

		for i = #screenElementsTable,1,-1 do
			if screenElementsTable[i].type == "tutorialText" then
				screenElementsTable[i].text = ""
			end
		end

		for i = #screenElementsTable,1,-1 do
			if screenElementsTable[i].type == "pokeTutorial" then
				display.remove( screenElementsTable[i] )
				table.remove( screenElementsTable, i )
			end
		end	

		--Start Moving
		startWalls()
	end

	function createTutorialDrawLines()

		local finger

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "finger" then
				finger = screenElementsTable[i]
			end
		end

		local pointA_x = vTable.automatedDrawCircle.x
		local pointA_y = vTable.automatedDrawCircle.y

		local pointB_x = finger.x
		local pointB_y = finger.y - 200

		createDrawLines( 
			vTable.automatedDrawCircle,
			vTable.automatedDrawCircle.x, vTable.automatedDrawCircle.y,
			pointB_x, pointB_y)
	end

	function updateTutorialDraw(self)

		local finger
		local _x
		local _y
		local _time

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "finger" then
				finger = screenElementsTable[i]
			end
		end

		if finger.transitionHandle ~= nil then
			transition.cancel( finger.transitionHandle )
			finger.transitionHandle = nil
		end

		if finger.transitionPoint == 0 then
			_x = 0
			_y = 200
		elseif finger.transitionPoint == 1 then
			_x = 100
			_y = 200
		elseif finger.transitionPoint == 2 then
			_x = 200
			_y = 200
		elseif finger.transitionPoint == 3 then
			_x = 200
			_y = 100
		elseif finger.transitionPoint == 4 then
			_x = 200
			_y = 0

		elseif finger.transitionPoint == 5 then --Start Automated Drawing in new location
			finger.x = finger.x + 200
			vTable.automatedDrawCircle.x = finger.x
			vTable.automatedDrawCircle.y = finger.y - 200
			_x = 0
			_y = 100
		elseif finger.transitionPoint == 6 then
			_x = -50
			_y = 100
		elseif finger.transitionPoint == 7 then
			_x = -100
			_y = 100
		elseif finger.transitionPoint == 8 then
			_x = -100
			_y = 50
		elseif finger.transitionPoint == 9 then
			_x = -400
			_y = 0
		elseif finger.transitionPoint == 10 then --Delay

			for i = #timerTable,1,-1 do
				if timerTable[i]._listener == createTutorialDrawLines then
					timer.cancel( timerTable[i] )
					table.remove( timerTable, i )
				end
			end

			timerTable[#timerTable+1] = timer.performWithDelay(1250,updateTutorialDraw,1)
			finger.transitionPoint  = finger.transitionPoint + 1

			vTable.automatedDrawCircle.isVisible = false

		elseif finger.transitionPoint == 11 then

			for i = #timerTable,1,-1 do
				if timerTable[i]._listener == updateTutorialDraw then
					timer.cancel( timerTable[i] )
					table.remove( timerTable, i )
				end
			end

			vTable.automatedDrawCircle.isVisible = true

			timerTable[#timerTable+1] = timer.performWithDelay(10,createTutorialDrawLines,0)

			finger.x = finger.x - 200
			finger.y = finger.y - 500
			vTable.automatedDrawCircle.x = finger.x
			vTable.automatedDrawCircle.y = finger.y - 200
			_x = 0
			_y = 600
		elseif finger.transitionPoint == 12 then
			_x = 100
			_y = 200
		elseif finger.transitionPoint == 13 then
			_x = 100
			_y = 100
		elseif finger.transitionPoint == 14 then
			_x = 200
			_y = 100
		elseif finger.transitionPoint == 15 then
			_x = 100
			_y = 0
		elseif finger.transitionPoint == 16 then
			_x = 100
			_y = -100
		elseif finger.transitionPoint == 17 then
			_x = 100
			_y = -200
		elseif finger.transitionPoint == 18 then
			_x = 0
			_y = -400
		elseif finger.transitionPoint == 19 then
			_x = -100
			_y = -200
		elseif finger.transitionPoint == 20 then
			_x = -100
			_y = -100
		elseif finger.transitionPoint == 21 then
			_x = -100
			_y = 0

		elseif finger.transitionPoint == 22 then --Remove Junk

			display.remove(vTable.automatedDrawCircle)
			vTable.automatedDrawCircle = nil

			finger.isVisible = false

			for i = #screenElementsTable,1,-1 do
				if screenElementsTable[i].type == "tutorialText" then
					local tutorialText = screenElementsTable[i]
					tutorialText.text = "Your Turn!"
				end
			end

			for i = #timerTable,1,-1 do
				if timerTable[i]._listener == createTutorialDrawLines then
					timer.cancel( timerTable[i] )
					table.remove( timerTable, i )
				end
			end

			timerTable[#timerTable+1] = timer.performWithDelay(1000,tutorialCompleted,1)
		end

		if _x ~= nil then
			_time = math.sqrt( _x^2 + _y^2 ) * 0.75

			finger.transitionHandle = transition.to( finger, { time = _time, x=finger.x + _x, y=finger.y + _y, onComplete = updateTutorialDraw} )
			finger.transitionPoint  = finger.transitionPoint + 1
		end
	end

	function tutorialCompleted()

		queWall:setLinearVelocity(0,-configGame.wallSpeed)

		for i = #timerTable,1,-1 do
			if timerTable[i]._listener == tutorialCompleted then
				timer.cancel( timerTable[i] )
				table.remove( timerTable, i )
			end
		end

		configGame.region = "Bunny Hill"
		createScoreText()
		--nextRegionTimer()
		configGame.tutorial = nil

		for i = #screenElementsTable,1,-1 do
			if screenElementsTable[i].type == "tutorialText"
			or screenElementsTable[i].type == "finger"
			or screenElementsTable[i].type == "pokeTutorial" then
				display.remove( screenElementsTable[i] )
				table.remove(screenElementsTable, i)
			end
		end
	end
--

--TUTORIAL CITY
	function readyTutorialCity( tempGate )

		local id = #timerTable+1
		timerTable[id] = timer.performWithDelay(10, checkToStartTutorialCity, 0)
		timerTable[id].params = {}
		timerTable[id].params.object = tempGate

		tempGate.tutorial = true
		tempGate.leftRope:removeEventListener("collision")
		tempGate.leftRope.tutorial = true
		tempGate.rightRope:removeEventListener("collision")
		tempGate.rightRope.tutorial = true

		configGame.tutorial = "tut_gate"
	end

	function checkToStartTutorialCity(event)

		tempObj = event.source.params.object

		if tempObj.y <= 1000 then
			
			timer.cancel( event.source )
			local index = table.indexOf( timerTable, event.source)
			table.remove( timerTable, index )

			configGame.wallSpeedTemp = configGame.wallSpeed
			configGame.wallSpeed = 0

			--ADJUST BALL SPEED
			local vx
			local vy
			vx, vy = gameBall:getLinearVelocity()
			gameBall:setLinearVelocity(vx, vy+configGame.wallSpeedTemp)

			stopWallsForTutorial()

			createTutorialElements()
			startTutorialCity( tempObj )
		end
	end

	function startTutorialCity(tempGate)

		pauseResumeScore( "pause" )

		local finger
		local tutorialText

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "finger" then
				finger = screenElementsTable[i]
			end
		end

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "tutorialText" then
				tutorialText = screenElementsTable[i]
			end
		end

		finger.transitionPoint = 0
		finger.isVisible = false

		--Update tutorialText
		tutorialText.text = ""
		tutorialText.x = 768
		tutorialText.y = 1400

		gforeground1:insert( tutorialText )
		finger:toFront()

		updateTutorialCity()
	end

	function updateTutorialCity()

		--print("update city tut")
		

		local finger
		local tutorialText

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "finger" then
				finger = screenElementsTable[i]
			end
		end

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "tutorialText" then
				tutorialText = screenElementsTable[i]
			end
		end

		if finger.transitionPoint == 0 then
			tutorialText.text = "Squeeze between the middle houses then slash the ropes to open the gate!"

			for i = 1,#wallTable do
				if wallTable[i].type == "gate"
				and wallTable[i].tutorial == true then
					wallTable[i].leftRope.collision = cutRope
					wallTable[i].leftRope.tutorial = true
					wallTable[i].leftRope:addEventListener("collision",wallTable[i].leftRope)
					wallTable[i].rightRope.collision = cutRope
					wallTable[i].rightRope:addEventListener("collision",wallTable[i].rightRope)
					wallTable[i].rightRope.tutorial = true
				end
			end
		elseif finger.transitionPoint == 1 then

			finishTutorialCity()
		end

		finger.transitionPoint = finger.transitionPoint + 1
	end

	function finishTutorialCity()

		for i = #screenElementsTable,1,-1 do
			if screenElementsTable[i].type == "tutorialText"
			or screenElementsTable[i].type == "finger" then
				display.remove( screenElementsTable[i] )
				table.remove(screenElementsTable, i)
			end
		end

		startWalls()

		timerTable[#timerTable+1] = timer.performWithDelay( 10000, sendEffect, 0 )
		timerTable[#timerTable].type = "sendEffect"

		--Number of Tutorial Completions
		tempValue = dbfunctions.getTableValue("generalSettings", "completedCityTutorial", "value")
		tempValue = tonumber(tempValue)

		dbfunctions.updateTableValue( "generalSettings", "completedCityTutorial", "value", tempValue+1 )

		nextRegionTimer()
		configGame.tutorial = nil

		pauseResumeScore("resume")
	end
--

--TUTORIAL MILITARY CAMP
	function readyTutorialMilitaryCamp( tempGate )

		--print("ready tutorial military camp")

		id = #timerTable+1
		timerTable[id] = timer.performWithDelay(10, checkToStartTutorialMilitaryCamp, 0)
		timerTable[id].params = {}
		timerTable[id].params.object = tempGate

		tempGate.tutorial = true
		tempGate.leftRope:removeEventListener("collision")
		tempGate.leftRope.tutorial = true
		tempGate.rightRope:removeEventListener("collision")
		tempGate.rightRope.tutorial = true
		

		configGame.tutorial = "tut_helicopter"
	end

	function checkToStartTutorialMilitaryCamp(event)

		tempObj = event.source.params.object

		if tempObj.y <= 1000 then
			
			timer.cancel( event.source )
			local index = table.indexOf( timerTable, event.source)
			table.remove( timerTable, index )

			configGame.wallSpeedTemp = configGame.wallSpeed
			configGame.wallSpeed = 0

			--ADJUST BALL SPEED
			local vx
			local vy
			vx, vy = gameBall:getLinearVelocity()
			gameBall:setLinearVelocity(vx, vy+configGame.wallSpeedTemp)

			stopWallsForTutorial()

			createTutorialElements()
			startTutorialMilitaryCamp( tempObj )
		end
	end

	function startTutorialMilitaryCamp(tempGate)

		pauseResumeScore("pause")

		local x = math.random( 300,1236)
		local y = -200
		local rot = 90
		createChopper(x, y, rot)

		local finger
		local tutorialText

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "finger" then
				finger = screenElementsTable[i]
			end
		end

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "tutorialText" then
				tutorialText = screenElementsTable[i]
			end
		end

		finger.transitionPoint = 0
		finger.isVisible = false

		--Update tutorialText
		tutorialText.text = "When the chopper's shields are down slash the chopper to destroy it!"
		tutorialText.x = 768
		tutorialText.y = 1400

		gforeground1:insert( tutorialText )
		finger:toFront()
	end

	function updateTutorialMilitaryCamp()
		

		local finger
		local tutorialText

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "finger" then
				finger = screenElementsTable[i]
			end
		end

		for i = 1,#screenElementsTable do
			if screenElementsTable[i].type == "tutorialText" then
				tutorialText = screenElementsTable[i]
			end
		end

		if finger.transitionPoint == 0 then
			tutorialText.text = "It takes two slashes to destroy the chopper."
		elseif finger.transitionPoint == 1 then
			tutorialText.text = "Good Work! Planes also can be destroyed.  Now slash the ropes to open the gate."

			for i = 1,#wallTable do
				if wallTable[i].type == "gate"
				and wallTable[i].tutorial == true then
					wallTable[i].leftRope.collision = cutRope
					wallTable[i].leftRope:addEventListener("collision",wallTable[i].leftRope)
					wallTable[i].leftRope.tutorial = true
					wallTable[i].rightRope.collision = cutRope
					wallTable[i].rightRope:addEventListener("collision",wallTable[i].rightRope)
					wallTable[i].rightRope.tutorial = true
				end
			end
		elseif finger.transitionPoint == 2 then

			finishTutorialMilitaryCamp()
		end

		finger.transitionPoint = finger.transitionPoint + 1
	end

	function finishTutorialMilitaryCamp()

		for i = #screenElementsTable,1,-1 do
			if screenElementsTable[i].type == "tutorialText"
			or screenElementsTable[i].type == "finger" then
				display.remove( screenElementsTable[i] )
				table.remove(screenElementsTable, i)
			end
		end

		startWalls()

		timerTable[#timerTable+1] = timer.performWithDelay( 10000, sendEffect, 0 )
		timerTable[#timerTable].type = "sendEffect"

		--Number of Tutorial Completions
		tempValue = dbfunctions.getTableValue("generalSettings", "completedMilitaryCampTutorial", "value")
		tempValue = tonumber(tempValue)

		dbfunctions.updateTableValue( "generalSettings", "completedMilitaryCampTutorial", "value", tempValue+1 )

		nextRegionTimer()
		configGame.tutorial = nil
		--Save that tutorial has been completed.
		pauseResumeScore("resume")
	end
--

--REGION MAINMENU
	function createMainMenuTrees( option )

		local numberOfTrees
		local positionTable
		local passed
		local offset_x
		local offset_y
		local side
		local _x
		local gap = 200 -- accounts for tree hieght so they are created off screen

		if option == "autoFillTrees" then
			--print("autoFill trees")
			tempTreeY = -200
			while tempTreeY < _H_Que_Trigger do


				numberOfTrees = math.random(3,4)
				positionTable = {}
				density = math.random(0,100)

				for i = 1,numberOfTrees do

					passed = false

					while passed == false do

						offset_x = math.random(120,500)
						offset_y = math.random(0,300)

						side = math.random(1,2)
						if side == 1 then
							_x = offset_x
						elseif side == 2 then
							_x = 1536-offset_x
						end

						if #positionTable > 0 then

							for i = 1,#positionTable do
								if math.abs( positionTable[i].x - _x ) > 100 then
									passed = true
								else
									passed = false
									break
								end
							end

						else
							passed = true
						end
					end

					coordinates = {}
					coordinates.x = _x
					coordinates.y = tempTreeY + density + offset_y

					id = #positionTable+1
					positionTable[id] = coordinates
				end

				positionTable = common.sortTable(positionTable, "y")

				for i = 1,#positionTable do
					wallTallTree( positionTable[i].x, positionTable[i].y )
				end
				tempTreeY = positionTable[#positionTable].y
				updateQueWall( tempTreeY )
			end

		elseif option == "sendTrees" then
			--print("send trees")

			numberOfTrees = math.random(3,4)
			positionTable = {}

			density = math.random(0,100)

			for i = 1,numberOfTrees do

				passed = false

				while passed == false do

					offset_x = math.random(120,500)
					offset_y = math.random(0,300)

					side = math.random(1,2)
					if side == 1 then
						_x = offset_x
					elseif side == 2 then
						_x = 1536-offset_x
					end

					if #positionTable > 0 then

						for i = 1,#positionTable do
							if math.abs( positionTable[i].x - _x ) > 100 then
								passed = true
							else
								passed = false
								break
							end
						end

					else
						passed = true
					end
				end

				coordinates = {}
				coordinates.x = _x
				coordinates.y = _H_Que_Trigger + density + offset_y

				id = #positionTable+1
				positionTable[id] = coordinates
			end

			positionTable = common.sortTable(positionTable, "y")

			for i = 1,#positionTable do
				wallTallTree( positionTable[i].x, positionTable[i].y )
			end
			
			updateQueWall( positionTable[#positionTable].y )
		end

	end
--

--REGION WILDERNESS
	function wallNormal(x, y, length, rot)

		if rot == "rand" then
			rot = math.random(0,360)
		end
		
		if rot < 0 then
			rot = rot + 360
		end
		--
		local rot2 = (rot*190)/math.pi -- I DON"T THINK THIS DOES ANYTHING

		local log_SheetData

		if length == 150 then
			log_SheetData = {
				width=280,
				height=213,
				numFrames=36,
				sheetContentWidth=1960,
				sheetContentHeight=1278
			}
		elseif length == 250 then
			log_SheetData = {
				width=298,
				height=214,
				numFrames=36,
				sheetContentWidth=1788,
				sheetContentHeight=1284
			}
		elseif length == 300 then
			log_SheetData = {
				width=294,
				height=210,
				numFrames=36,
				sheetContentWidth=1764,
				sheetContentHeight=1260
			}
		end

		local log_sequenceData = {
			{name = "normal", start = 1,count = 36, time =2400}
			}
			
		if length == 150 then
			log_Sheet = graphics.newImageSheet( "images/game/log150_Sprite.png", log_SheetData)
		elseif length == 250 then
			log_Sheet = graphics.newImageSheet( "images/game/log250_Sprite.png", log_SheetData)
		elseif length == 300 then
			log_Sheet = graphics.newImageSheet( "images/game/log300_Sprite.png", log_SheetData)
		end

		id = #wallTable+1
		wallTable[id] = display.newRoundedRect(999, 999, length, 30, 15)
		wallTable[id].isVisible = false
		wallTable[id].x = x
		wallTable[id].y = y
		wallTable[id].type = "normal"
		wallTable[id].hit = 0
		wallTable[id]:rotate(-rot)
		
		wallTable[id].decal = display.newSprite( log_Sheet, log_sequenceData)
		wallTable[id].decal.isVisible = true
		wallTable[id].decal.x = x
		wallTable[id].decal.y = y
		
		
		wallTable[id].decal.timeScale = 1

		if length == 150 then
			wallTable[id].decal.xScale = .6
			wallTable[id].decal.yScale = .8
		elseif length == 250 then
			wallTable[id].decal.xScale = 1
			wallTable[id].decal.yScale = 1.3
		elseif length == 300 then
			wallTable[id].decal.xScale = 1.2
			wallTable[id].decal.yScale = 1.6
		end

		if rot >= -5 and rot < 5 then wallTable[id].decal:setFrame(1)
		elseif rot >= 5 and rot < 15 then wallTable[id].decal:setFrame(2)
		elseif rot >= 15 and rot < 25 then wallTable[id].decal:setFrame(3)
		elseif rot >= 25 and rot < 35 then wallTable[id].decal:setFrame(4)
		elseif rot >= 35 and rot < 45 then wallTable[id].decal:setFrame(5)
		elseif rot >= 45 and rot < 55 then wallTable[id].decal:setFrame(6)
		elseif rot >= 55 and rot < 65 then wallTable[id].decal:setFrame(7)
		elseif rot >= 65 and rot < 75 then wallTable[id].decal:setFrame(8)
		elseif rot >= 75 and rot < 85 then wallTable[id].decal:setFrame(9)
		elseif rot >= 85 and rot < 95 then wallTable[id].decal:setFrame(10)
		elseif rot >= 95 and rot < 105 then wallTable[id].decal:setFrame(11)
		elseif rot >= 105 and rot < 115 then wallTable[id].decal:setFrame(12)
		elseif rot >= 115 and rot < 125 then wallTable[id].decal:setFrame(13)
		elseif rot >= 125 and rot < 135 then wallTable[id].decal:setFrame(14)
		elseif rot >= 135 and rot < 145 then wallTable[id].decal:setFrame(15)
		elseif rot >= 145 and rot < 155 then wallTable[id].decal:setFrame(16)
		elseif rot >= 155 and rot < 165 then wallTable[id].decal:setFrame(17)
		elseif rot >= 165 and rot < 175 then wallTable[id].decal:setFrame(18)
		elseif rot >= 175 and rot < 185 then wallTable[id].decal:setFrame(19)
		elseif rot >= 185 and rot < 195 then wallTable[id].decal:setFrame(20)
		elseif rot >= 195 and rot < 205 then wallTable[id].decal:setFrame(21)
		elseif rot >= 205 and rot < 215 then wallTable[id].decal:setFrame(22)
		elseif rot >= 215 and rot < 225 then wallTable[id].decal:setFrame(23)
		elseif rot >= 225 and rot < 235 then wallTable[id].decal:setFrame(24)
		elseif rot >= 235 and rot < 245 then wallTable[id].decal:setFrame(25)
		elseif rot >= 245 and rot < 255 then wallTable[id].decal:setFrame(26)
		elseif rot >= 255 and rot < 265 then wallTable[id].decal:setFrame(27)
		elseif rot >= 265 and rot < 275 then wallTable[id].decal:setFrame(28)
		elseif rot >= 275 and rot < 285 then wallTable[id].decal:setFrame(29)
		elseif rot >= 285 and rot < 295 then wallTable[id].decal:setFrame(30)
		elseif rot >= 295 and rot < 305 then wallTable[id].decal:setFrame(31)
		elseif rot >= 305 and rot < 315 then wallTable[id].decal:setFrame(32)
		elseif rot >= 315 and rot < 325 then wallTable[id].decal:setFrame(33)
		elseif rot >= 325 and rot < 335 then wallTable[id].decal:setFrame(34)
		elseif rot >= 335 and rot < 345 then wallTable[id].decal:setFrame(35)
		elseif rot >= 345 and rot < 355 then wallTable[id].decal:setFrame(36)
		elseif rot >= 355 and rot < 365 then wallTable[id].decal:setFrame(1) end
		rot = -rot
		--
		

		local half_Length = length/2 --15
		
		
		
		
		tempShape = {-half_Length-15,0, -half_Length,-15, half_Length,-15,
			half_Length+15,0, half_Length,15, -half_Length,15}
		physics.addBody( wallTable[id], "kinematic",
			--{shape={-half_Length,-15, -half_Length,15, -half_Length-7.5,12.9904, -half_Length-12.9904,7.5,
			--half_Length-15,0, -half_Length-12.9904,-7.5, -half_Length-7.5,-12.9904},
			--friction = 0, bounce=0.1, filter = wallCollisionFilter},
			
			--{shape={-half_Length,-15, half_Length,-15, half_Length,15, -half_Length,15},
			--friction = 0, bounce=0.1, filter = wallCollisionFilter},
			{shape = tempShape, friction = 3, bounce=0.1, filter = wallCollisionFilter}
			
			--{shape={half_Length,-15, half_Length+7.5,-12.9904, half_Length+12.9904,-7.5,
			--half_Length+15,0, half_Length+12.9904,7.5, half_Length+7.5,12.9904, half_Length,15},
			--friction = 0, bounce=0.1, filter = wallCollisionFilter}
			
			)
		
		
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		rot = nil
		gground1:insert( wallTable[id] )
		gground1:insert( wallTable[id].decal )

		return wallTable[id]
	end

	function windEffect(event)
		--Affect is applied in equation jetpack
		if gameBall.wind == nil
		and event.other == gameBall
		and configGame.region ~= "tutorial" then 
		
			gameBall.wind = event.target.power/sledWeight
			
		elseif gameBall.wind ~= nil
		and event.other == gameBall then
		
			gameBall.wind = nil
		end
	end

	function wallWind(y, tempPower)

		id = #wallTable + 1
		--
		log_SheetData = {
			width=216,
			height=384,
			numFrames=10,
			sheetContentWidth=2160,
			sheetContentHeight=384
		}

		log_Sheet = graphics.newImageSheet( "images/game/wind_Sprite.png", log_SheetData)

		log_sequenceData = {
			{name = "normal", start = 1, count = 10, time=350, loopCount=0}
			}

			
		wallTable[id] = display.newSprite( log_Sheet, log_sequenceData)
		wallTable[id].timeScale = 1
		if tempPower > 0 then
			wallTable[id].xScale = 7.5
		elseif tempPower < 0 then
			wallTable[id].xScale = -7.5
		end
		wallTable[id].yScale = 5
		wallTable[id]:setFrame(1)
		wallTable[id]:play()
		----

		wallTable[id].x = 768
		wallTable[id].y = y
		wallTable[id].type = "wind"
		wallTable[id].power = tempPower
		
		windCords = {-768,-700, 768,-700, 768,700, -768,700}
		physics.addBody(wallTable[id],"kinematic", {shape=windCords,
			isSensor=true, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity(0,-configGame.wallSpeed)
		
		
		wallTable[id]:addEventListener("collision", windEffect)
		gsky3:insert( wallTable[id] )
	end

	function bounce_windmill(self, event)

		if event.other.type == "gameBall" then
			local vx, vy = gameBall:getLinearVelocity()
			if vx < 0 then xDirection = -1 else xDirection = 1 end
			if vy < 0 then yDirection = -1 else yDirection = 1 end

			local angle = math.abs(math.atan2(-vx,-vy)*(180/math.pi))

			vx = math.abs(vx)
			vy = math.abs(vy)
			
			local newVx = math.abs(800*math.sin(angle/180*math.pi))*xDirection*sledBounce
			local newVy = math.abs(800*math.cos(angle/180*math.pi))*yDirection*sledBounce
				
			gameBall:setLinearVelocity( newVx, newVy )
			event.target.hit = 0

		end
	end

	function windmill(_x, _y, direction, size)

		local blade1 = {-37.4166,-65, -17.5,-60, 2.5,-40, 10,-20, 10,0,}
		local blade2 = {-5,8.6603, 75,-0.0963, 60.7115,14.8446, 33.3910,22.1651, 12.3205,18.6603}
		local blade3 = {-37.5834,64.9037,  -43.2115,45.1554,  -35.8910,17.8349, -27.3205,1.3397, -5,-8.6603}
		local base1 = {-10,-32, 5,-8.6603, 32.7128,7.3397, 5,8.6603, -22.7128,24.6603, -10,0}

		local blade4 = {-10,0, -10,-20, -2.5,-40, 17.5,-60, 37.4166,-65,    }
		local blade5 = {-12.3205,18.6603, -33.3910,22.1651, -60.7115,14.8446, -75,-0.0963, 5,8.6603,  }
		local blade6 = {5,-8.6603, 27.3205,1.3397,  35.8910,17.8349,  43.2115,45.1554,  37.5834,64.9037 }
		local base2 = {10,0, 22.7128,24.6603, -5,8.6603, -32.7128,7.3397, -5,-8.6603, 10,-32, }

		if size == "big" and direction == 1 then
			for i = 1,#blade1 do blade1[i] = blade1[i]*2 end
			for i = 1,#blade2 do blade2[i] = blade2[i]*2 end
			for i = 1,#blade3 do blade3[i] = blade3[i]*2 end
			for i = 1,#base1 do base1[i] = base1[i]*2 end
		elseif size == "big" and direction == -1 then
			for i = 1,#blade4 do blade4[i] = blade4[i]*2 end
			for i = 1,#blade5 do blade5[i] = blade5[i]*2 end
			for i = 1,#blade6 do blade6[i] = blade6[i]*2 end
			for i = 1,#base2 do base2[i] = base2[i]*2 end
		end

		local id = #wallTable+1
			
		wallTable[id] = display.newImage("images/game/blades.png")

		--
		local sheetData = { 
			width=140,
			height=124,
			numFrames=27,
			sheetContentWidth=1960,
			sheetContentHeight=248
		}

		local sheet = graphics.newImageSheet( "images/game/windmill_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 27, time=350}
			}

		wallTable[id].decal = display.newSprite( sheet, sequenceData)
		wallTable[id].decal.timeScale = 1
		wallTable[id].decal:setFrame(1)
		wallTable[id].decal:play()
		
		wallTable[id]:toFront()
		--


		wallTable[id].x = _x
		wallTable[id].y = _y
		wallTable[id].decal.x = _x
		wallTable[id].decal.y = _y
		if direction == 1 then

			if size == "big" then
				wallTable[id].xScale = 2; wallTable[id].yScale = 2
				wallTable[id].decal.xScale = 1; wallTable[id].decal.yScale = 1
			else
				wallTable[id].xScale = 1; wallTable[id].yScale = 1
				wallTable[id].decal.xScale = 0.5; wallTable[id].decal.yScale = 0.5
			end
			tempBlade1= blade1
			tempBlade2 = blade2
			tempBlade3 = blade3
			tempBase = base1
		elseif direction == -1 then
			
			if size == "big" then
				wallTable[id].xScale = -2; wallTable[id].yScale = 2
				wallTable[id].decal.xScale = 1; wallTable[id].decal.yScale = 1
			else
				wallTable[id].xScale = -1; wallTable[id].yScale = 1
				wallTable[id].decal.xScale = 0.5; wallTable[id].decal.yScale = 0.5
			end
			tempBlade1= blade4
			tempBlade2 = blade5
			tempBlade3 = blade6
			tempBase = base2
		end

		physics.addBody(wallTable[id], "kinematic", 
			{shape=tempBlade1, bounce=2, filter = wallCollisionFilter},
			{shape=tempBlade2, bounce=2, filter = wallCollisionFilter},
			{shape=tempBlade3, bounce=2, filter = wallCollisionFilter},
			{shape=tempBase, bounce=2, filter = wallCollisionFilter}
		)

		wallTable[id].angularVelocity = 600*direction
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		wallTable[id].type = "windmill"
		wallTable[id].hit = 0


		

		wallTable[id].collision = bounce_windmill
		wallTable[id]:addEventListener("collision", wallTable[id])

		gground1:insert( wallTable[id].decal )
		gground1:insert( wallTable[id] )
	end

	function wallSnowBall()

		local id = #effectsTable+1
		--
		local sheetData = { 
			width=238,
			height=248,
			numFrames=18,
			sheetContentWidth=1904,
			sheetContentHeight=744
		}

		local sheet = graphics.newImageSheet( "images/game/snowball_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 18, time=600, loopCount=0}
			}

			
		effectsTable[id] = display.newSprite( sheet, sequenceData)
		effectsTable[id].timeScale = 1
		effectsTable[id].xScale = 1
		effectsTable[id].yScale = 1
		effectsTable[id]:setFrame(1)
		effectsTable[id]:play()
		effectsTable[id]:toFront()
		
		------------
		effectsTable[id].x = math.random(200,1336)
		effectsTable[id].y = -200
		effectsTable[id].type = "snowBall"
		
		physics.addBody( effectsTable[id], "kinematic",{radius=115, isSensor=false, filter = wallCollisionFilter})
		
		effectsTable[id].collision = snowBallEffect
		effectsTable[id]:addEventListener( "collision", effectsTable[id] )

		effectsTable[id]:setLinearVelocity(0,600)
		gground3:insert( effectsTable[id] )
	end

	function snowBallEffect( tempObject, event)

		if event.other.type == "gameBall"
		and gameBall.hitSnowBall == nil then
			gameBall.hitSnowBall = tempObject
			gameBall.isSensor = true
			timerTable[#timerTable+1] = timer.performWithDelay(500,endGame,1)
		end
	end
--

--REGION TOWN
	function wallHouse(_x, _y)

		local id = #wallTable+1
		
		wallTable[id] = display.newImage("images/game/cabin_3.png")
		wallTable[id].xScale = 1--0.7
		wallTable[id].yScale = 1--0.6
		wallTable[id].x = _x
		wallTable[id].y = _y
		wallTable[id].type = "house"
		wallTable[id].hit = 0
		
		local houseShape = {-120,-80, -5,-100, 110,-80, 110,110, -120,110, }
		
		physics.addBody( wallTable[id], "kinematic",
			{shape=houseShape, friction = 0, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		--SMOKE
		local sheetData = { 
			width=63,
			height=91,
			numFrames=41,
			sheetContentWidth=2016,
			sheetContentHeight=182
		}

		local sheet = graphics.newImageSheet( "images/game/smoke_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 41, time=2000, loopCount=0}
			}

		wallTable[id].smoke = display.newSprite( sheet, sequenceData)
		wallTable[id].smoke.timeScale = 1
		wallTable[id].smoke.xScale = 1
		wallTable[id].smoke.yScale = 1
		wallTable[id].smoke:setFrame(1)
		tempFrame = math.random(1,41)
		wallTable[id].smoke:setFrame( tempFrame )
		wallTable[id].smoke:play()
		
		wallTable[id].smoke.x = wallTable[id].x-85
		wallTable[id].smoke.y = wallTable[id].y-125
		
		gground2:insert( wallTable[id] )
		gground2:insert( wallTable[id].smoke )
	end

	function wallSpike(x, y)
		local id = #wallTable+1
		wallTable[id] = display.newImage("images/game/fern_Snowy.png")
		wallTable[id].xScale = 1
		wallTable[id].yScale = 1
		wallTable[id].x = x
		wallTable[id].y = y
		wallTable[id].type = "spike"
		wallTable[id].hit = 0
		
		physics.addBody( wallTable[id], "kinematic",{friction = 0, radius=50, isSensor=true, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		function spiked(obj, event)
			if event.other.type == "gameBall" and
				event.target.hit == 0 then
				event.target.hit = event.target.hit + 1
				local vx, vy = gameBall:getLinearVelocity()
				gameBall:setLinearVelocity( (vx*sledWeight)/2.5,(vy*sledWeight)/2.5)
			end
		end
		
		wallTable[id].collision = spiked
		wallTable[id]:addEventListener("collision", wallTable[id])
		
		gground1:insert( wallTable[id] )
	end

	function bounce(obj, event)--------

		
		if event.other.type == "gameBall" then

			soundCheck(energyReleaseSound)

			obj.core:setFillColor(1,.1,1)
			obj.core.transitionHandle = transition.to(obj.core, 
				{xScale=obj.core.xScaleOrig*2, yScale=obj.core.yScaleOrig*2, time = 125, onComplete=shrink})--onComplete=gameControls.killDrawLine})
		

			local vx, vy = gameBall:getLinearVelocity()
			if vx < 0 then
				xDirection = -1 else xDirection = 1
			end
			
			if vy < 0 then
				yDirection = -1
			else yDirection = 1
			end

			local angle = math.abs(math.atan2(-vx,-vy)*(180/math.pi))
			
			vx = math.abs(vx)
			vy = math.abs(vy)
		
			local newVx = math.abs(1200*math.sin(angle/180*math.pi))*xDirection
			local newVy = math.abs(1200*math.cos(angle/180*math.pi))*yDirection

			gameBall:setLinearVelocity( newVx, newVy )
			
		end
	end

	function wallBounce(x, y, _scale)
		local id = #wallTable+1
		
		function reColor(obj)
			obj:setFillColor(1,1,1)
		end
		
		function shrink(obj)
			transition.to(obj,{xScale=obj.xScaleOrig,yScale=obj.yScaleOrig, time = 75, onComplete=reColor})
		end

		if _scale == nil then
			_scale = 1
		end
		

		local sheetData = { 
			width=214,
			height=192,
			numFrames=36,
			sheetContentWidth=1926,
			sheetContentHeight=768
		}

		local sheet = graphics.newImageSheet( "images/game/orb_Back_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1,count = 36, time =1200}
			}
			
		wallTable[id] = display.newSprite( sheet, sequenceData)
		wallTable[id].x = x
		wallTable[id].y = y
		wallTable[id].timeScale = 1
		wallTable[id].xScale = _scale
		wallTable[id].yScale = _scale
		wallTable[id]:play()
		wallTable[id]:toFront()

		
		
		
		wallTable[id].core = display.newImage("images/game/orb_Core.png")
		wallTable[id].core.xScale = _scale
		wallTable[id].core.xScaleOrig = _scale
		wallTable[id].core.yScale = _scale
		wallTable[id].core.yScaleOrig = _scale
		wallTable[id].core.alpha = 0.9
		wallTable[id].core.x = x
		wallTable[id].core.y = y
		wallTable[id].core:toFront()


		local sheetData = { 
			width=214,
			height=192,
			numFrames=36,
			sheetContentWidth=1926,
			sheetContentHeight=768
		}

		local sheet = graphics.newImageSheet( "images/game/orb_Front_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1,count = 36, time =1200}
			}
			
		wallTable[id].front = display.newSprite( sheet, sequenceData)
		wallTable[id].front.x = x
		wallTable[id].front.y = y

		wallTable[id].front.timeScale = 1
		wallTable[id].front.xScale = _scale
		wallTable[id].front.yScale = _scale
		wallTable[id].front:play()
		
		--
		tempFrame = math.random(1,36)
		wallTable[id]:setFrame( tempFrame )
		wallTable[id].front:setFrame( tempFrame )

		
		wallTable[id].type = "bounce"
		wallTable[id].hit = 0

		
		physics.addBody( wallTable[id], "kinematic",
			{friction = 0, radius=85*_scale, bounce = 0.5, filter = wallCollisionFilter })
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed)
		
		wallTable[id].postCollision = bounce
		wallTable[id]:addEventListener("postCollision", wallTable[id])
		
		gground1:insert( wallTable[id] )
		gground1:insert( wallTable[id].core )
		gground1:insert( wallTable[id].front )
	end




	function snowPlowOrder()
		--[[
		last_y = 0
		tempTest = #snowPlowTable
		--if tempTest > 1 then tempTest = 1 end
		for i = 1,tempTest do
			snowPlowTable[i]:toFront()

			for ii = 1,#wallTable do

				if wallTable[ii].y > snowPlowTable[i].y - 100 --atleast
				and wallTable[ii].y < snowPlowTable[i].y --then
				and wallTable[ii].y > last_y then

					wallTable[ii]:toFront()
					
					if wallTable[ii].type == "windmill" then
						wallTable[ii].decal:toFront()
					elseif wallTable[ii].type == "house" then
						wallTable[ii].smoke:toFront()
					elseif wallTable[ii].type == "bounce" then
						wallTable[ii].core:toFront()
						wallTable[ii].front:toFront()
					end
				end
			end
			
			for i2 = 1,#snowPlowTable[i].plow do
				snowPlowTable[i].plow[i2]:toFront()
			end

			--last_y = snowPlowTable[i].mound.y

			snowPlowTable[i].mound:toFront()
			
		end	]]
	end

	function sendPlow(tempObject, y, speed)

		local speed
		local y

		if speed == nil then --USED if called by a timer
			y = tempObject.y --+ 50
			speed = tempObject.speed
		end
			
			
		local id2 = #tempObject.plow + 1
		
		local sheetData = { 
			width=286,
			height=209,
			numFrames=15,
			sheetContentWidth=2002,
			sheetContentHeight=627
		}

		local snowplow_Sheet = graphics.newImageSheet( "images/game/snowPlow_Sprite.png", sheetData)

		local snowplow_sequenceData = {
			{name = "normal", start = 1,count = 15, time =450}
			}
			
		tempObject.plow[id2] = display.newSprite( snowplow_Sheet, snowplow_sequenceData)
		--tempObject.plow[id2].x = 1536 --UPDATED BELOW
		tempObject.plow[id2].y = y
		--tempObject.plow[id2].xScale = 0.8 --UPDATED BELOW
		tempObject.plow[id2].yScale = 1
		
		tempObject.plow[id2]:setSequence("normal")
		tempFrame = math.random(1,15)
		tempObject.plow[id2]:setFrame( tempFrame )
		tempObject.plow[id2]:play()

		gground1:insert( tempObject.plow[id2] )

		if speed < 0 then
			tempObject.plow[id2].x = 1736
			tempObject.plow[id2].xScale = 0.8
		else
			tempObject.plow[id2].x = -200
			tempObject.plow[id2].xScale = -0.8
		end
		
		tempObject.plow[id2].type = "plow"
		tempObject.plow[id2].speed = speed
		tempObject.plow[id2].upperLevel = tempObject
		
		physics.addBody( tempObject.plow[id2], "kinematic",
			{friction = 0, bounce = 0.15+sledBounceAmount, radius=100,
			filter = wallCollisionFilter})
		tempObject.plow[id2]:setLinearVelocity( 200*speed*(configGame.wallSpeed/configGame.wallSpeedOrig), -configGame.wallSpeed )

		snowPlowOrder()
	end

	function wallSnowPlow( _y, _speed, _time, _type)

		--create holes
		wallHole("left", _y+20, 480, _type)
		wallHole("right", _y+20, 480, _type)

		local id = #wallTable+1

		if _type == nil
		or _type == "top" then
			--wallTable[id] = display.newImage("images/game/Road_Back_Sloped.png")
			wallTable[id] = display.newImageRect("images/game/Road_Back_Sloped.png",1536,599)
		else
			--wallTable[id] = display.newImage("images/game/Road_Back_Cliff.png")
			wallTable[id] = display.newImageRect("images/game/Road_Back_Cliff.png",1536,599)
		end

		wallTable[id].x = 768
		wallTable[id].y = _y-50
		
		--wallTable[id].xScale = 1.5
		--wallTable[id].yScale = 1.5
		
		--print(wallTable[id].width)
		
		local _time = _time*(configGame.wallSpeedOrig/configGame.wallSpeed)
		wallTable[id].timer = sendPlow
		wallTable[id].timerHandle = timer.performWithDelay( _time, wallTable[id], 0)
		wallTable[id].plow = {}
		wallTable[id].type = "road"
		wallTable[id].speed = _speed

		physics.addBody( wallTable[id], "kinematic",{isSensor=true, filter = graphicCollisionFilter})
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		gground1:insert( wallTable[id] )

		--CREATE MOUND
		if _type == nil
		or _type == "bottom" then
			wallTable[id].mound = display.newImage("images/game/Road_Front.png")
			wallTable[id].mound.xOffset = 0
			wallTable[id].mound.yOffset = 0--150
			wallTable[id].mound.x = wallTable[id].x + wallTable[id].mound.xOffset
			wallTable[id].mound.y = wallTable[id].y + wallTable[id].mound.yOffset
			
			wallTable[id].mound.xScale = 1.5
			wallTable[id].mound.yScale = 1.5
			
			gground1:insert( wallTable[id].mound )
		end
		

		snowPlowTable[#snowPlowTable+1] = wallTable[id]
		sendPlow(snowPlowTable[#snowPlowTable], _y, _speed, _direction)
	end





	function bridgeFence(self, event)

		--if gameBall.fenceHole == true then
		if gameBall.fenceHole > 0 then
			event.contact.isEnabled = false
		end
	end

	function fenceHole(self, event)

		if event.other.type == "gameBall"
		--and gameBall.fenceHole == nil then
		and event.phase == "began" then

			--gameBall.fenceHole = true
			gameBall.fenceHole = gameBall.fenceHole + 1

			for i = #backgroundTable,1,-1 do
				backgroundTable[i].left.preCollision = bridgeFence
				backgroundTable[i].left:addEventListener("preCollision")

				backgroundTable[i].leftBottom.preCollision = bridgeFence
				backgroundTable[i].leftBottom:addEventListener("preCollision")

				backgroundTable[i].right.preCollision = bridgeFence
				backgroundTable[i].right:addEventListener("preCollision")

				backgroundTable[i].rightBottom.preCollision = bridgeFence
				backgroundTable[i].rightBottom:addEventListener("preCollision")
			end

		--Remove PreCollsion Listener
		elseif event.other.type == "gameBall"
		--and gameBall.fenceHole == true then
		and event.phase == "ended" then

			--gameBall.fenceHole = nil
			gameBall.fenceHole = gameBall.fenceHole - 1

			for i = #backgroundTable,1,-1 do
				backgroundTable[i].left.preCollision = bridgeFence
				backgroundTable[i].left:removeEventListener("preCollision")

				backgroundTable[i].leftBottom.preCollision = bridgeFence
				backgroundTable[i].leftBottom:removeEventListener("preCollision")

				backgroundTable[i].right.preCollision = bridgeFence
				backgroundTable[i].right:removeEventListener("preCollision")

				backgroundTable[i].rightBottom.preCollision = bridgeFence
				backgroundTable[i].rightBottom:removeEventListener("preCollision")
			end
			
		end
	end

	function wallHole(_side, _y, _length, _type)

		local id = #wallTable+1
		wallTable[id] = display.newRect(999,999,200,_length)
		--_side = "left"
		if _side == "left" then
			_x = 50
			wallTable[id].x = _x
		elseif _side == "right" then
			_x = 1486
			wallTable[id].x = _x
		end
		
		wallTable[id].y = _y - 40
		wallTable[id].halfLength = _length/2 + 25
		wallTable[id].type = "fenceHole"
		
		physics.addBody( wallTable[id], "kinematic",
			{isSensor=true, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		wallTable[id].collision = fenceHole
		wallTable[id]:addEventListener("collision")
		wallTable[id]:setFillColor(255,0,0)
		wallTable[id].isVisible = false
		
		if _type == "top"
		or _type == nil then
			--TOP POST
			wallTable[id].post_1 = display.newRect(999,999,100,50)
			wallTable[id].post_1.x = _x
			wallTable[id].post_1.yOffset = - wallTable[id].halfLength
			
			physics.addBody( wallTable[id].post_1, "kinematic",
				{filter = wallCollisionFilter})
			wallTable[id].post_1:setLinearVelocity( 0, -configGame.wallSpeed )

			wallTable[id].post_1.isVisible = false
		end
		
		if _type == "bottom"
		or _type == nil then
			--BOTTOM POST
			wallTable[id].post_2 = display.newRect(999,999,100,50)
			wallTable[id].post_2.x = _x
			wallTable[id].post_2.yOffset = wallTable[id].halfLength
			
			physics.addBody( wallTable[id].post_2, "kinematic",
				{filter = wallCollisionFilter})
			wallTable[id].post_2:setLinearVelocity( 0, -configGame.wallSpeed )

			wallTable[id].post_2.isVisible = false
		end

		--Remove Temp Variables
		_x = nil
	end
--

--REGION SKI PARK
	function wallBarrel(_x, _y)

		local id = #wallTable + 1
		wallTable[id] = display.newImage("images/game/barrel.png")
		wallTable[id].xScale = 0.75
		wallTable[id].yScale = 0.75
		wallTable[id].x = _x
		wallTable[id].y = _y
		
		wallTable[id].type = "barrel"
		
		tempShape = {-60,10, -42.4,-32.4, 0,-50, 42.4,-32.4, 60,10, 42.4,52.4, 0,70, -42.4,52.4}
		
		physics.addBody(wallTable[id], "kinematic",
			{shape = tempShape, friction = 0, isSensor = false, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity(0,-configGame.wallSpeed)
		gground2:insert( wallTable[id] )
	end

	function wallPipe(_x, _y)

		local id = #wallTable + 1
		wallTable[id] = display.newImage("images/game/pipe.png")
		wallTable[id].xScale = 1.5
		wallTable[id].yScale = 1.5
		wallTable[id].x = _x
		wallTable[id].y = _y
		
		wallTable[id].type = "pipe"
		
		physics.addBody(wallTable[id], "kinematic",
			{friction = 0, isSensor = false, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity(0,-configGame.wallSpeed)
		gground1:insert( wallTable[id] )
	end




	function wallSnowMachine(_x,_y,tempPattern)

		local id = #wallTable + 1
		
		--
		local log_SheetData = {
			width=216,
			height=262,
			numFrames=36,
			sheetContentWidth=1944,
			sheetContentHeight=1048
			}

		local log_Sheet = graphics.newImageSheet( "images/game/snowMachine_Sprite.png", log_SheetData)

		local log_sequenceData = {
			{name = "counter", start = 1, count = 36, time=1500,
				loopCount = 0, loopDirection = "bounce"
			},
				
			{name = "clock", time=1500,
				frames= { 36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,
					14,13,12,11,10,9,8,7,6,5,4,3,2,1,},
				loopCount = 0, loopDirection = "forward",
			},
			
			{name = "northEast", time=1600,
				frames= { 34,35,36,1,2,3,4,5,6,7,8,9,10,11,12,13,
								12,11,10,9,8,7,6,5,4,3,2,1,36,35,34},
				loopCount = 0, loopDirection = "forward",
				
			},
				
			{name = "northWest", time=1600,
				frames= { 21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,
								8,9,10,11,12,13,14,15,16,17,18,19,20,},
				loopCount = 0, loopDirection = "bounce"
			},
				
		}

		wallTable[id] = display.newSprite( log_Sheet, log_sequenceData)
		
		if tempPattern == nil then
			wallTable[id]:setSequence( "counter" )
		elseif tempPattern == "counter" then
			wallTable[id]:setSequence( "counter" )
		elseif tempPattern == "clock" then
			wallTable[id]:setSequence( "clock" )
		elseif tempPattern == "northEast" then
			wallTable[id]:setSequence( "northEast" )
		elseif tempPattern == "northWest" then
			wallTable[id]:setSequence( "northWest" )
		end
		
		wallTable[id].timeScale = 1
		wallTable[id].xScale = 1.5
		wallTable[id].yScale = 1.5
		wallTable[id]:play()

		
		
		wallTable[id].x = _x
		wallTable[id].y = _y-50
		wallTable[id].type = "machine"
		wallTable[id].inRange = nil

		wallTable[id].timer = sprayDecal
		wallTable[id].timerHandle = timer.performWithDelay(300,wallTable[id],0)
		
		local baseShape = {140,0+40, 99,99+40, 0,140+40, -99,99+40,
					-140,0+40, -99,-99+40, 0,-140+40, 99,-99+40
					}
		local radTEMP = 700*0.707
		local sprayShape = {0,-700, radTEMP,-radTEMP, 700,0, radTEMP,radTEMP,
					0,700, -radTEMP,radTEMP, -700,0, -radTEMP,-radTEMP,}
		physics.addBody(wallTable[id], "kinematic",
			{shape = baseShape, isSensor = false, filter = wallCollisionFilter},
			{shape = sprayShape, isSensor = true, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		wallTable[id].collision = enteredSprayRange
		wallTable[id]:addEventListener("collision")
		
		--To Front
		gground1:insert( wallTable[id] )
		wallTable[id]:toFront()
	end

	function enteredSprayRange(self, event)

		if event.selfElement == 2 then
			if event.target.inRange == nil then
				event.target.inRange = true
			elseif event.target.inRange == true then
				event.target.inRange = nil
			end
		end
	end

	function sprayDecal(OBJECT)

		local tempID = table.indexOf(wallTable, OBJECT)
		local frame
		local theta
		local thetaRad
		local sign
		local xChange
		local yChange
		local x
		local y
		
		if wallTable[tempID].sequence == "counter" then
			frame = wallTable[tempID].frame
		elseif wallTable[tempID].sequence == "clock" then
			frame = math.abs(wallTable[tempID].frame-36)
		elseif wallTable[tempID].sequence == "northEast" then
			if wallTable[tempID].frame <4 then
				frame = wallTable[tempID].frame + 33
			elseif wallTable[tempID].frame >= 4
			and wallTable[tempID].frame < 16 then
				frame = wallTable[tempID].frame - 3
			elseif wallTable[tempID].frame >= 16
			and wallTable[tempID].frame < 29 then
				frame = 12 + (16 - wallTable[tempID].frame)
			elseif wallTable[tempID].frame > 29 then
				frame = 36 + (29 - wallTable[tempID].frame)
			end

		elseif wallTable[tempID].sequence == "northWest" then
			if wallTable[tempID].frame < 16 then
				frame = 22 - wallTable[tempID].frame
			elseif wallTable[tempID].frame >= 16 then
				frame = wallTable[tempID].frame - 8
			end

		end

		if frame ~= nil then
		
			theta = 360*((frame-1)/36)

			if theta > 90 and theta < 270 then
				sign = -1
			else
				sign = 1
			end
		
			thetaRad = math.pi*(theta/180)

			xChange = 450*math.cos(thetaRad)
			yChange = 450*math.sin(thetaRad)
			
			x = wallTable[tempID].x + xChange
			y = wallTable[tempID].y - yChange -25
			
			
			-------------------
			
			local log_SheetData = {
				width=384,
				height=384,
				numFrames=9,
				sheetContentWidth=3456,
				sheetContentHeight=384
				}

			local log_Sheet = graphics.newImageSheet( "images/game/snowSpray_Sprite.png", log_SheetData)

			local log_sequenceData = {
				{name = "normal", start = 1, count = 9, time=300, loopCount = 1}
				}

			local id = #effectsTable + 1
			
			effectsTable[id] = display.newSprite( log_Sheet, log_sequenceData)
			effectsTable[id].timeScale = 1
			effectsTable[id].xScale = 2
			effectsTable[id].yScale = 2
			effectsTable[id]:setFrame(1)
			effectsTable[id]:play()
			
			
			effectsTable[id].x = x
			effectsTable[id].y = y
			effectsTable[id].rotation = 360-theta
			
			
			physics.addBody(effectsTable[id], "kinematic",
				{radius = 140, isSensor = true, filter = wallCollisionFilter})
			effectsTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )

			effectsTable[id]:addEventListener( "sprite", removeSpray )
			
			if frame <= 18 then
				gground1:insert( effectsTable[id] )
				OBJECT:toFront()
			else
				gground2:insert( effectsTable[id] )
			end
		end
	end

	function removeSpray( event )
		if event.phase == "ended" then
			event.target:removeEventListener("sprite",removeSpray)
			
			display.remove(event.target)
			
			local id = table.indexOf(effectsTable, event.target)
			table.remove(effectsTable, id)
			event.target = nil
		 end
	end

	function sprayEffectOrig()

		for i = 1,#wallTable do
			if wallTable[i].type == "machine" and wallTable[i].inRange == true then
				object = wallTable[i]
				--
				if wallTable[i].sequence == "counter" then
					frame = wallTable[i].frame
				elseif wallTable[i].sequence == "clock" then
					frame = math.abs(wallTable[i].frame-36)
				elseif wallTable[i].sequence == "northEast" then
					if wallTable[i].frame < 4 then
						frame = wallTable[i].frame + 33
					elseif wallTable[i].frame >= 4 and wallTable[i].frame < 16 then
						frame = wallTable[i].frame - 3
					elseif wallTable[i].frame >= 16 and wallTable[i].frame < 29 then
						frame = 12 + (16 - wallTable[i].frame)
					elseif wallTable[i].frame > 29 then
						frame = 36 + (29 - wallTable[i].frame)
					end
				elseif wallTable[i].sequence == "northWest" then
					if wallTable[i].frame < 16 then
						frame = 22 - wallTable[i].frame
					elseif wallTable[i].frame >= 16 then
						frame = wallTable[i].frame - 8
					end
				end
				
				machine_cur_angle = 360-360*((frame-1)/36)

				x = gameBall.x - wallTable[i].x
				y = gameBall.y - wallTable[i].y
				angle = math.atan2(y,x)
				angle = angle*degrees_conversion
				if angle > 360 then angle = angle - 360 end
				if angle > 360 then angle = angle - 360 end
				if angle < 0 then angle = angle + 360 end
				
				
				
				difference = angle - machine_cur_angle
				
				
				
				if math.abs(difference) < 30 then
					actualSprayEffect()
				end
			end
		end
	end

	function actualSprayEffect(_thetaRad, tempObject)

		local signX
		local signY
		
		if gameBall.x < tempObject.x then
			signX = -1
		else
			signX = 1
		end

		if gameBall.y < tempObject.y then
			signY = -1
		else
			signY = 1
		end

		local forceX = math.abs( .015*math.cos(_thetaRad) )*signX*sledWeightAmount
		local forceY = math.abs( .015*math.sin(_thetaRad) )*signY*sledWeightAmount
		gameBall:applyLinearImpulse( forceX, forceY, gameBall.x, gameBall.y )
	end

	function sprayEffect(tempObject)

		--Find THETA
		local frame
		
		if tempObject.sequence == "counter" then
			frame = tempObject.frame
		elseif tempObject.sequence == "clock" then
			frame = math.abs(tempObject.frame-36)
		elseif tempObject.sequence == "northEast" then

			if tempObject.frame < 4 then
				frame = tempObject.frame + 33
			elseif tempObject.frame >= 4

			and tempObject.frame < 16 then
				frame = tempObject.frame - 3

			elseif tempObject.frame >= 16
			and tempObject.frame <= 29 then
				frame = 12 + (16 - tempObject.frame)

			elseif tempObject.frame > 29 then
				frame = 36 + (29 - tempObject.frame)
			end

		elseif tempObject.sequence == "northWest" then
			if tempObject.frame < 16 then
				frame = 22 - tempObject.frame
			elseif tempObject.frame >= 16 then
				frame = tempObject.frame - 8
			end

		end

		_theta = 360*((frame-1)/36)
		_thetaRad = _theta/degrees_conversion

		--Find ANGLE
		--_angle = common.getAngle(gameBall.x, gameBall.y, tempObject.x, tempObject.y)
		
		xChange = math.abs( gameBall.x - tempObject.x )
		yChange = math.abs( gameBall.y - tempObject.y )
		distance = math.sqrt( xChange^2 + yChange^2 )
		_angle = math.atan2(yChange,xChange)

		if gameBall.x > tempObject.x
		and gameBall.y < tempObject.y then
			--DO NOTHING
		elseif gameBall.x < tempObject.x
		and gameBall.y < tempObject.y then

			_angle = math.pi - math.abs( _angle )

		elseif gameBall.x < tempObject.x
		and gameBall.y > tempObject.y then

			_angle = math.pi + math.abs( _angle )

		elseif gameBall.x > tempObject.x
		and gameBall.y > tempObject.y then

			_angle = 2*math.pi - math.abs( _angle )
		end
		
		_angle_Deg = _angle*degrees_conversion

		--Find THETA
		
		
		difference = _angle_Deg - _theta

		--FOR GAME BALL CLOSE RANGE
		if distance > 400
		and math.abs(difference) < 30 then
			
			actualSprayEffect( _thetaRad, tempObject)

		--FOR GAME BALL LONG RANGE
		elseif distance <= 400 then

			--Find ANGLE NORMAL
			_Normal_Angle = _thetaRad + math.pi/2

			--Find PointC_x
			NewX = math.abs( yChange/math.tan( _thetaRad ) )
			if _theta > 90
			and _theta < 270 then
				signX = -1
			else
				signX = 1
			end
			NewX = NewX*signX

			--Find Change x
			xChange = 150*math.cos(_Normal_Angle)
			

			--Find pointA_x and pointB_x
			pointA_x = tempObject.x + NewX - xChange
			pointB_x = tempObject.x + NewX + xChange

			if _theta >= 360 then
				_theta = _theta - 360
			end

			if _theta == 0
			and math.abs( tempObject.y - gameBall.y ) < 150
			and gameBall.x > tempObject.x then

				actualSprayEffect( _thetaRad, tempObject)

			elseif _theta > 0
			and _theta < 180
			and gameBall.x > pointB_x
			and gameBall.x < pointA_x 
			and gameBall.y < tempObject.y then
				actualSprayEffect( _thetaRad, tempObject)

			elseif _theta == 180
			and math.abs( tempObject.y - gameBall.y ) < 150
			and gameBall.x < tempObject.x then

				actualSprayEffect( _thetaRad, tempObject)

			elseif _theta > 180
			and _theta < 360
			and gameBall.x < pointB_x
			and gameBall.x > pointA_x
			and gameBall.y > tempObject.y then

				actualSprayEffect( _thetaRad, tempObject)

			end

		end
	end





	function gameBallAvoidDrawLine(self, event)
		
		if event.contact ~= nil then
			--event.contact.isEnabled = false
		end
	end

	function gameBallLand(tempObject)

		local index = table.indexOf( transitionTable, tempObject.transitionHandle )
		table.remove( transitionTable, index )

		gameBall.image.transitionHandle = nil
		gameBall.jumpAirbourne = nil
		if gameBall.jumpContactTop == true then
			gameBall.jumpCleared = true
		end
		gameBall.preCollision = gameBallAvoidDrawLine
		gameBall:removeEventListener("preCollision")
	end

	function gameBallFalling( tempObject, event )

		local index = table.indexOf( transitionTable, tempObject.transitionHandle )
		table.remove( transitionTable, index )

		local params = tempObject.tempParams
		local tempTimeInAir = params.tempTimeInAir
		local tempHeightInAir= params.tempHeightInAir

		local tempImage = gameBall.image
		tempImage.transitionHandle = nil
		tempImage.transitionHandle = transition.to( tempImage,
			{xScale = tempImage.xScale/tempHeightInAir, yScale = tempImage.yScale/tempHeightInAir,
			time = tempTimeInAir, transition=easing.linear, onComplete=gameBallLand})
		transitionTable[#transitionTable+1] = tempImage.transitionHandle
	end



	function wallJump(_y, _position)

		local tempShapeTop = {-768,125, 768,125, 768,190, -768,190}
		local tempShapeBottomRemove = {-768,190, 768,190, 768,200, -768,200}

		local tempShape_Lip = {-155,-100, 155,-100, 155,-50, -155,-50}
		local tempShape_Left = {-165,-180, -155,-180, -155,-50, -165,-50}
		local tempShape_Right = {155,-180, 165,-180, 165,-50, 155,-50}

		local _offset = 360
		local sign = 1

		if _position == nil then
			_position = "left"
		end

		if _position == "left" then

			for i = 1,#tempShape_Lip do
				if i%2 == 1 then
					sign = -1
					tempShape_Lip[i] = tempShape_Lip[i]-_offset
					tempShape_Left[i] = tempShape_Left[i]-_offset
					tempShape_Right[i] = tempShape_Right[i]-_offset
				end
			end

			_image = "images/game/jumpLeftCracked.png"


		elseif _position == nil
		or _position == "middle" then

			_offset = 0

			_image = "images/game/jumpMiddleCracked.png"
			_position = "middle"

		elseif _position == "right" then

			for i = 1,#tempShape_Lip do
				if i%2 == 1 then
					sign = 1
					tempShape_Lip[i] = tempShape_Lip[i]+_offset
					tempShape_Left[i] = tempShape_Left[i]+_offset
					tempShape_Right[i] = tempShape_Right[i]+_offset
				end
			end

			_image = "images/game/jumpRightCracked.png"

		end

		local id = #wallTable + 1
		--wallTable[id] = display.newImage( _image )
		wallTable[id] = display.newImageRect( _image, 1536, 540 )
		wallTable[id].xScale = 1--1536/2048
		wallTable[id].yScale = 1--1536/2048
		wallTable[id].x = 768
		wallTable[id].y = _y
		
		wallTable[id].type = "jump"
		wallTable[id].position = _position
		wallTable[id].offset_x = _offset*sign
		
		physics.addBody(wallTable[id], "kinematic",
			{shape = tempShape_Lip, friction = 0, isSensor = false, filter = wallCollisionFilter},
			{shape = tempShape_Left, friction = 0, isSensor = false, filter = wallCollisionFilter},
			{shape = tempShape_Right, friction = 0, isSensor = false, filter = wallCollisionFilter}
			)
		wallTable[id]:setLinearVelocity(0,-configGame.wallSpeed)

		wallTable[id].preCollision = jumpEffect
		wallTable[id]:addEventListener("preCollision")




		--Decal
		--wallTable[id].mound = display.newImage("images/game/jumpMound.png")
		wallTable[id].mound = display.newImageRect("images/game/jumpMound.png", 1536, 540)
		wallTable[id].mound.xScale = 1--1536/2048
		wallTable[id].mound.yScale = 1--1536/2048
		wallTable[id].mound.x = 768
		wallTable[id].mound.y = _y

		physics.addBody(wallTable[id].mound, "kinematic",
			{shape = tempShapeTop, friction = 0, isSensor = true, filter = wallCollisionFilter},
			{shape = tempShapeBottomRemove, friction = 0, isSensor = true, filter = wallCollisionFilter}
			)
		wallTable[id].mound:setLinearVelocity(0,-configGame.wallSpeed)

		wallTable[id].mound.collision = jumpEffectMound
		wallTable[id].mound:addEventListener("collision")

		wallTable[id].mound.upperLevel = wallTable[id]

		

		gground1:insert( wallTable[id] )
		gground2:insert( wallTable[id].mound )

		--mask = graphics.newMask( "images/game/fenceMask.jpg" )
		
		wallTable[id]:setMask(_fenceMask)
		wallTable[id].mound:setMask(_fenceMask)
		
		local tempBackgroundTable = {}
		
		for i2 = 1,#backgroundTable do
			tempBackgroundTable[i2] = {}
			tempBackgroundTable[i2].spot = i2
			tempBackgroundTable[i2].y = backgroundTable[i2].y
		end

		tempBackgroundTable = common.sortTable(tempBackgroundTable, "y")
		
		--for i = 1,#tempBackgroundTable do
		--	print(tempBackgroundTable[i].y)
		--end

		local difference = 0
				
		for i = 1,#tempBackgroundTable do

			local key = tempBackgroundTable[i].spot
			
			if backgroundTable[key].left.y > wallTable[id].y then
				difference = backgroundTable[key].left.y - wallTable[id].y
				break
			elseif backgroundTable[key].leftBottom.y > wallTable[id].y then
				difference = backgroundTable[key].leftBottom.y - wallTable[id].y
				break
			end
		end
				
		value = (difference-512)
		--print("====",value)
		
		wallTable[id].maskY = value
		wallTable[id].mound.maskY = value
		
		--[[wallTable[i].maskY = wallTable[i].y - value
		wallTable[i].mound.maskY = wallTable[i].y - value

		if wallTable[i].decal ~= nil then
			wallTable[i].decal.y = wallTable[i].y
			wallTable[i].decal.maskY = wallTable[i].y - value
		end]]
				
		
		
		--[[
		tempBackgroundTable = {}
				for i2 = 1,#backgroundTable do
					tempBackgroundTable[i2] = {}
					tempBackgroundTable[i2].spot = i2
					tempBackgroundTable[i2].y = backgroundTable[i2].y
				end

				tempBackgroundTable = common.sortTable(tempBackgroundTable, "y")

				local difference = 0
				
				for i2 = 1,#tempBackgroundTable do

					local id = tempBackgroundTable[i2].spot
					
					if backgroundTable[id].left.y > wallTable[i].y then
						difference = backgroundTable[id].left.y - wallTable[i].y
						break
					elseif backgroundTable[id].leftBottom.y > wallTable[i].y then
						difference = backgroundTable[id].leftBottom.y - wallTable[i].y
						break
					end
				end
				
				value = (512+difference)
				print(value)

				wallTable[i].maskY = wallTable[i].y - value
				wallTable[i].mound.maskY = wallTable[i].y - value
				

				if wallTable[i].decal ~= nil then
					wallTable[i].decal.y = wallTable[i].y
					wallTable[i].decal.maskY = wallTable[i].y - value
				end
				]]
	end

	function jumpEffect(self, event)

		if event.other.type == "gameBall"
		and event.selfElement == 1
		and event.other.y < event.target.y - 50 then
		
			event.contact.isEnabled = false
			
			if event.other.jumpAirbourne == nil then

				local vx
				local vy
				vx, vy = event.other:getLinearVelocity()
				local velocity = math.sqrt( vx^2 + vy^2 )

				soundCheck(swooshSound)
				
				local minVelocity = 300
				local tempTimeInAir = 300*(velocity/minVelocity)
				local tempHeightInAir = 2*(velocity/minVelocity)
				if tempHeightInAir < 1.25 then
					--local fakeVelocity = (1.25/2)*minVelocity
					tempTimeInAir = 150--300*(velocity/fakeVelocity)
					tempHeightInAir = 1.25--2*(velocity/fakeVelocity)
				elseif tempHeightInAir > 2.5 then
					tempTimeInAir = 300*1.25
					tempHeightInAir = 2*1.25
				end

				tempTimeInAir = tempTimeInAir*(configGame.wallSpeedOrig/configGame.wallSpeed)
			
				local tempImage = event.other.image

				tempImage.onComplete = gameBallFalling
				tempImage.transitionHandle = transition.to( tempImage,
					{xScale = tempImage.xScale*tempHeightInAir, yScale = tempImage.yScale*tempHeightInAir,
					time = tempTimeInAir, transition=easing.linear,
					onComplete=tempImage } )
				transitionTable[#transitionTable+1] = tempImage.transitionHandle

				tempImage.tempParams = {}
				tempImage.tempParams.tempTimeInAir = tempTimeInAir
				tempImage.tempParams.tempHeightInAir = tempHeightInAir
					
				event.other.jumpAirbourne = true
				
				event.other.preCollision = gameBallAvoidDrawLine
				event.other:addEventListener("preCollision")	
			end
			
			
			
		elseif event.other.type == "gameBall"
		and event.selfElement == 2
		and gameBall.x >= event.target.x+event.target.offset_x-(155+configGame.gameBall_radius) then

			event.contact.isEnabled = false
			
		elseif event.other.type == "gameBall"
		and event.selfElement == 3
		and gameBall.x <= event.target.x+event.target.offset_x+(155+configGame.gameBall_radius)  then
			
			event.contact.isEnabled = false
		end
	end

	function jumpEffectMound(self, event)

		if event.selfElement == 1 then

			if event.phase == "began" then
				gameBall.jumpContactTop = true
			elseif event.phase == "ended" then
				gameBall.jumpContactTop = nil
				gameBall.jumpCleared = nil
			end

			
		elseif event.selfElement == 2 then

			if gameBall.jumpAirbourne == nil
			and gameBall.jumpContactTop == true
			and gameBall.jumpCleared == nil
			and event.phase == "began"
			and event.target.upperLevel.decal == nil then
				endGame()
			end
		end
	end

	function coverJump(tempObject)

		if tempObject.position == "left" then
			_image = "images/game/jumpLeftCovered.png"

		elseif tempObject.position == "middle" then
			_image = "images/game/jumpMiddleCovered.png"

		elseif tempObject.position == "right" then
			_image = "images/game/jumpRightCovered.png"
		end

		--tempObject.decal = display.newImage( _image )
		tempObject.decal = display.newImageRect( _image, 1536, 540 )
		tempObject.decal.x = tempObject.x
		tempObject.decal.y = tempObject.y
		tempObject.decal.xScale = tempObject.xScale
		tempObject.decal.yScale = tempObject.yScale
		tempObject.decal.alpha = 0

		tempObject.decal.transitionHandle = transition.to(tempObject.decal,
			{alpha=1, time = 500} )

		gground1:insert( tempObject.decal )
		local mask = graphics.newMask( "images/game/fenceMask.jpg" )
		tempObject.decal:setMask(_fenceMask)

		tempObject.mound.isVisible = false
	end
--

--REGION CITY
	function wallGate(_x,_y)
		
		
		--Main Gate
		local id = #wallTable + 1
		
		
		local sheetData = { 
			width=379,
			height=150,
			numFrames=20,
			sheetContentWidth=1895,
			sheetContentHeight=600
		}


		local _xOffset_main = -2
		local _yOffset_main = 14
		

		local sheet = graphics.newImageSheet( "images/game/gateMain_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 20, time=750, loopCount = 1}
			}

		wallTable[id] = display.newSprite( sheet, sequenceData)
		wallTable[id].timeScale = 1
		wallTable[id].xScale = 2
		wallTable[id].yScale = 2
		wallTable[id]:setFrame(1)
		wallTable[id]:play()
		wallTable[id]:pause()
		
		wallTable[id].x = _x
		wallTable[id].y = _y
		wallTable[id].type = "gate"
		
		local shapeLeftWall = {-375,-50, -150,-30, -150,30, -375,30}
		local shapeRightWall = {150,-30, 375,-50, 375,30, 150,30}
		
		physics.addBody(wallTable[id], "kinematic",
			{shape = shapeLeftWall, friction = 2, isSensor = false, filter = wallCollisionFilter},
			{shape = shapeRightWall, friction = 2, isSensor = false, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		
		--FLAG DECAL
		local sheetData = { 
			width=206,
			height=16,
			numFrames=20,
			sheetContentWidth=1854,
			sheetContentHeight=48
		}


		local _offsetX = -13
		local _offsetY = -58

		local sheet = graphics.newImageSheet( "images/game/gateFlags_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 20, time=750, loopCount = 0}
			}

		wallTable[id].flags = display.newSprite( sheet, sequenceData)
		wallTable[id].flags.timeScale = 1
		wallTable[id].flags.xScale = 2
		wallTable[id].flags.yScale = 3
		wallTable[id].flags:setFrame(1)
		wallTable[id].flags:play()
		
		wallTable[id].flags.xOffset = (_offsetX - _xOffset_main )*2
		wallTable[id].flags.yOffset = (_offsetY - _yOffset_main )*2
		wallTable[id].flags.x = _x + wallTable[id].flags.xOffset
		wallTable[id].flags.y = _y + wallTable[id].flags.yOffset
		
		--LEFT ROPE DECAL
		local sheetData = { 
			width=72,
			height=57,
			numFrames=14,
			sheetContentWidth=1008,
			sheetContentHeight=57
		}


		local _offsetX = -109
		local _offsetY = -56

		local sheet = graphics.newImageSheet( "images/game/gateRopeLeft_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 14, time=750, loopCount = 1}
			}

		wallTable[id].leftRope = display.newSprite( sheet, sequenceData)
		wallTable[id].leftRope.timeScale = 1
		wallTable[id].leftRope.xScale = 2
		wallTable[id].leftRope.yScale = 2
		wallTable[id].leftRope:setFrame(1)
		wallTable[id].leftRope:play()
		wallTable[id].leftRope:pause()
		
		wallTable[id].leftRope.xOffset = (_offsetX - _xOffset_main )*2
		wallTable[id].leftRope.yOffset = (_offsetY - _yOffset_main )*2
		wallTable[id].leftRope.x = _x + wallTable[id].leftRope.xOffset
		wallTable[id].leftRope.y = _y + wallTable[id].leftRope.yOffset
		
		local cutLeftRope = {-50,-30, -30,-30, 150,100, 130,100}
		physics.addBody(wallTable[id].leftRope, "dynamic",
			{shape = cutLeftRope, friction = 2, isSensor = true, filter = interactiveWallCollisionFilter})
		--wallTable[id].leftRope:setLinearVelocity( 0, -configGame.wallSpeed )
		wallTable[id].leftRope.gravityScale = 0
		
		wallTable[id].leftRope.collision = cutRope
		wallTable[id].leftRope:addEventListener("collision",wallTable[id].leftRope)
		
		----Left Physics Body----
		wallTable[id].leftGate = display.newRect(_W/2,_H/2,100,10)
		wallTable[id].leftGate.isVisible = false
		local leftGateShape = {0,-30, 150,-30, 150,15, 0,15} 
		physics.addBody(wallTable[id].leftGate, "kinematic",
			{shape = leftGateShape, friction = 2, isSensor = false, filter = wallCollisionFilter})
		wallTable[id].leftGate:setLinearVelocity( 0, -configGame.wallSpeed )
		
		wallTable[id].leftGate.x = _x - 150
		wallTable[id].leftGate.y = _y + 25
		
		--RIGHT ROPE DECAL
		local sheetData = { 
			width=78,
			height=71,
			numFrames=16,
			sheetContentWidth=1248,
			sheetContentHeight=71
		}


		local _offsetX = 106
		local _offsetY = -62

		local sheet = graphics.newImageSheet( "images/game/gateRopeRight_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 16, time=750, loopCount = 1}
			}

		wallTable[id].rightRope = display.newSprite( sheet, sequenceData)
		wallTable[id].rightRope.timeScale = 1
		wallTable[id].rightRope.xScale = 2
		wallTable[id].rightRope.yScale = 2
		wallTable[id].rightRope:setFrame(1)
		wallTable[id].rightRope:play()
		wallTable[id].rightRope:pause()
		
		wallTable[id].rightRope.xOffset = (_offsetX - _xOffset_main )*2
		wallTable[id].rightRope.yOffset = (_offsetY - _yOffset_main )*2
		wallTable[id].rightRope.x = _x + wallTable[id].rightRope.xOffset
		wallTable[id].rightRope.y = _y + wallTable[id].rightRope.yOffset
		
		local cutRightRope = {60,-10, 40,-10, -140,110, -120,110}
		physics.addBody(wallTable[id].rightRope, "dynamic",
			{shape = cutRightRope, friction = 2, isSensor = true, filter = interactiveWallCollisionFilter})
		--wallTable[id].rightRope:setLinearVelocity( 0, -configGame.wallSpeed )
		wallTable[id].rightRope.gravityScale = 0
		
		wallTable[id].rightRope.collision = cutRope
		wallTable[id].rightRope:addEventListener("collision",wallTable[id].rightRope)
		
		----Right Physics Body----
		wallTable[id].rightGate = display.newRect(_W/2,_H/2,100,10)
		wallTable[id].rightGate.isVisible = false
		local gateRightShape = {-150,-30, 0,-30, 0,15, -150,15}
		physics.addBody(wallTable[id].rightGate, "kinematic",
			{shape = gateRightShape, friction = 2, isSensor = false, filter = wallCollisionFilter})
		wallTable[id].rightGate:setLinearVelocity( 0, -configGame.wallSpeed )
		
		wallTable[id].rightGate.x = _x + 150
		wallTable[id].rightGate.y = _y + 25
		
		
		--REORDER
		gground2:insert( wallTable[id].rightRope )
		gground2:insert( wallTable[id].leftRope )
		gground2:insert( wallTable[id] )
		gground2:insert( wallTable[id].flags )

		return wallTable[id]
	end

	function cutRope(self, event)

		--CHANGE JUST USE A COLLISION FILTER
		if event.other.type == "draw" and event.phase == "began"
		and event.target.cut == nil then

			soundCheck(cutRopeSound, 0.5)
			event.target:play()
			event.target.cut = true
		
			--Find Index of wallTable
			for i = 1,#wallTable do
				if wallTable[i].leftRope == event.target
				or wallTable[i].rightRope == event.target then

					if wallTable[i].leftRope.cut == true
					and wallTable[i].rightRope.cut == true then

						if configGame.tutorial == "tut_gate"
						and event.target.tutorial == true then
							updateTutorialCity()
						end

						if configGame.tutorial == "tut_helicopter"
						and event.target.tutorial == true then
							updateTutorialMilitaryCamp()
						end

						wallTable[i]:play()
						wallTable[i].leftGate.angularVelocity=100
						wallTable[i].rightGate.angularVelocity=-100
						
						wallTable[i]:addEventListener("sprite",stopGates)
						configGame.openGatesFaster = true
					end

				end
			end
		end
	end

	function openGatesFaster()

		for i = 1,#wallTable do
			if wallTable[i].type == "gate" then
				if wallTable[i].leftGate.angularVelocity ~= 0 then
					wallTable[i].leftGate.angularVelocity = wallTable[i].leftGate.angularVelocity+3
					wallTable[i].rightGate.angularVelocity = wallTable[i].rightGate.angularVelocity-3
				end
			end
		end
	end

	function stopGates(event)

		if event.phase == "ended" then
			event.target.leftGate.angularVelocity = 0
			event.target.leftGate.rotation = 105
			
			event.target.rightGate.angularVelocity = 0
			event.target.rightGate.rotation = -105
			
			configGame.openGatesFaster = nil
		end
	end
--

--REGION FOREST
	function wallTallTree(x,y)

		local id = #wallTable + 1

		local sheetData = { 
			width=190,
			height=269,
			numFrames=46,
			sheetContentWidth=1900,
			sheetContentHeight=1345
		}

		local sheet = graphics.newImageSheet( "images/game/tallPine_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 46, time=2000, loopCount=1},
			{name = "light", start = 37, count = 9, time=800, loopCount=1}
			}

			
		wallTable[id] = display.newSprite( sheet, sequenceData)
		wallTable[id].timeScale = 1
		wallTable[id].xScale = 2
		wallTable[id].yScale = 2
		wallTable[id]:setFrame(1)
		--wallTable[id]:play()
		wallTable[id].type = "tallTree"
		
		wallTable[id].x = x
		wallTable[id].y = y
		
		shapeBase = {0,200, 22,215, 30,240, 23,260, 0,270, -23,260, -30,240, -22,215}
		shapeTree = {-150,150, 0,-300, 150,150}
		physics.addBody(wallTable[id], "kinematic",
			{shape = shapeBase, isSensor = false, filter = wallCollisionFilter},
			{shape = shapeTree, isSensor = true, filter = wallCollisionFilter}
			)
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		wallTable[id].collision = shakeTree
		wallTable[id]:addEventListener("collision")
		gground2:insert( wallTable[id] )

		return wallTable[id]
	end

	function shakeTree(self, event)
		
		if event.phase == "began" then
			if event.selfElement == 1 then

				soundCheck(treeShakeSound)

				event.target:setSequence( "normal" )
				event.target:setFrame(1)
				event.target:play()
			elseif event.selfElement == 2 then

				soundCheck(treeShakeSound,0.1)

				event.target:setSequence( "light" )
				event.target:setFrame(1)
				event.target:play()	
			end
		end
	end




	function wallPond(_x,_y, tempSize)

		local id = #wallTable + 1

		local sheetData = { 
			width=286,
			height=192,
			numFrames=54,
			sheetContentWidth=2002,
			sheetContentHeight=1536
		}

		local sheet = graphics.newImageSheet( "images/game/ice_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 54, time=2000, loopCount=1},
			{name = "ripple", start = 41, count = 13, time=(2500/54)*13}
			}

		wallTable[id] = display.newSprite( sheet, sequenceData)
		wallTable[id].timeScale = 1
		wallTable[id].xScale = tempSize*2
		wallTable[id].yScale = tempSize*2
		wallTable[id]:setFrame(1)
		
		wallTable[id].x = _x
		wallTable[id].y = _y
		wallTable[id].type = "pond"
		--Gets Created Later
		--wallTable[id].timer = crackIce_Expand
		wallTable[id].timerHandle = nil

		wallTable[id].decal = nil -- called at end of game, prevents player from falling through

		local shapePond = {-125,-100, 125,-125, 200,-50, 100,105, -25,110, -125,60, -175,-25}
		local edge1 = {125,-125, -125,-100, 0,-125}
		local edge2 = {200,-50, 125,-125, 175,-100}
		local edge3 = {100,105, 200,-50, 150,50}
		local edge4 = {-25,110, 100,105, 50,120}
		local edge5 = {-125,60, -25,110,-75,95}
		local edge6 = {-175,-25, -125,60, -160, 30}
		local edge7 = {-125,-100, -175,-25, -160,-70 }

		for i = 1,#shapePond do
			shapePond[i] = shapePond[i]*(2)
		end

		for i = 1,#edge1 do edge1[i] = edge1[i]*(2) end
		for i = 1,#edge2 do edge2[i] = edge2[i]*(2) end
		for i = 1,#edge3 do edge3[i] = edge3[i]*(2) end
		for i = 1,#edge4 do edge4[i] = edge4[i]*(2) end
		for i = 1,#edge5 do edge5[i] = edge5[i]*(2) end
		for i = 1,#edge6 do edge6[i] = edge6[i]*(2) end
		for i = 1,#edge7 do edge7[i] = edge7[i]*(2) end
		physics.addBody(wallTable[id], "kinematic",
		{shape = shapePond, isSensor = true, filter = wallCollisionFilter},
		{shape = edge1, isSensor = false, filter = wallCollisionFilter},
		{shape = edge2, isSensor = false, filter = wallCollisionFilter},
		{shape = edge3, isSensor = false, filter = wallCollisionFilter},
		{shape = edge4, isSensor = false, filter = wallCollisionFilter},
		{shape = edge5, isSensor = false, filter = wallCollisionFilter},
		{shape = edge6, isSensor = false, filter = wallCollisionFilter},
		{shape = edge7, isSensor = false, filter = wallCollisionFilter})
		
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		
		
		wallTable[id].preCollision = avoidCollisionIce
		wallTable[id]:addEventListener("preCollision")
		
		wallTable[id].collision = crackIce_Begin
		wallTable[id]:addEventListener("collision")
		
		gbackground1:insert( wallTable[id] )
	end

	function mySpriteListener( event )

		if event.phase == "ended" then
			event.target:removeEventListener("sprite",mySpriteListener)
			event.target:setSequence( "ripple" )
			event.target:play()
		end
	end

	function crackIce_Begin(self, event)

		if configGame.state == "play" 
		and event.target.decal == nil
		and configGame.region ~= "tutorial" then

			if event.phase == "began"
			and event.selfElement ~= 1 
			and event.target.inside == nil then
				event.target.outside = true

			elseif event.phase == "began"
			and event.selfElement == 1 then
				event.target.inside = true
			end


			if event.phase == "began"
			and event.selfElement == 1 then
				
				if event.target.frame < 4 
				and event.phase == "began" then

					soundCheck(iceCrackSound_100,0.2)
					event.target:setFrame(event.target.frame+1)
					event.target.timer = crackIce_Expand
					event.target.timerHandle = timer.performWithDelay(350, event.target, 1)
				elseif event.target.frame == 4 then
					
					--breakIce(event.other)
					breakIce(event.target)
				end
			end


			if event.phase == "ended"
			and event.selfElement ~= 1 then
				event.target.outside = nil

			elseif event.phase == "ended"
			and event.selfElement == 1 then
				event.target.inside = nil
			end

			event.target:addEventListener( "sprite", mySpriteListener )
		end
	end

	function crackIce_Expand(tempObject)

		if configGame.state == "play" 
		and tempObject.decal == nil 
		and configGame.region ~= "tutorial" then
			if tempObject.frame < 4
			and tempObject.inside == true then

				soundCheck(iceCrackSound_100,0.2)

				tempObject:setFrame(tempObject.frame+1)
				tempObject.timer = crackIce_Expand
				tempObject.timerHandle = timer.performWithDelay(350, tempObject, 1)
			elseif tempObject.frame == 4
			and tempObject.inside == true then
				
				breakIce(tempObject)
			end
		end
	end

	function breakIce(tempObject)

		soundCheck(iceCrackSound_100,0.2)
		tempObject:setFrame(tempObject.frame+1)
		tempObject:play()
		timer.performWithDelay(400,
			function()
				soundCheck(splashSound,0.5)
			end
		)
		local id = #timerTable+1
		timerTable[id] = timer.performWithDelay(500, escapeIceCheck, 1)
		timerTable[id].params = {}
		timerTable[id].params.object = tempObject
	end

	function avoidCollisionIce(self, event)

		--print("AVOID ICE")

		if configGame.state == "play"
		and event.target.decal == nil then

			if event.target.sequence == "ripple" 
			or event.target.sequence == "normal"
			and event.target.frame > 8 then

				if event.target.inside == true
				and event.target.outside == nil then
					event.contact.isEnabled = true
				else
					event.contact.isEnabled = false
				end

			else
				event.contact.isEnabled = false
			end

		else
			event.contact.isEnabled = false
		end
	end

	function escapeIceCheck(event)

		tempObject = event.source.params.object
		--Remove Timer
		index = table.indexOf( timerTable, event.source )
		timer.cancel( timerTable[index] )
		table.remove( timerTable, index )

		if tempObject.inside == true 
		and configGame.state == "play"
		and tempObject.decal == nil then
			Runtime:addEventListener("enterFrame", maskAnimation)
		else
			local id = #timerTable+1
			timerTable[id] = timer.performWithDelay(500, escapeIceCheck, 1)
			timerTable[id].params = {}
			timerTable[id].params.object = tempObject
		end
	end

	function maskAnimation()

		if gameBall.image.maskScaleY ~= 0 then
			TEMPyScale = gameBall.image.maskScaleY - 0.1
			if TEMPyScale <= 0 then
				TEMPyScale = 0.0001
				Runtime:removeEventListener("enterFrame",maskAnimation)
				timerTable[#timerTable+1] = timer.performWithDelay(1,endGame,1)
			end
			TEMPy = gameBall.image.maskY - (540*0.05)
		end

		if TEMPyScale ~= nil then
			gameBall.image.maskScaleY = TEMPyScale
			gameBall.hat.maskScaleY = TEMPyScale
			gameBall.head.maskScaleY = TEMPyScale
			gameBall.pants.maskScaleY = TEMPyScale
			gameBall.sled.maskScaleY = TEMPyScale

			gameBall.image.maskY = TEMPy
			gameBall.hat.maskY = TEMPy
			gameBall.head.maskY = TEMPy
			gameBall.pants.maskY = TEMPy
			gameBall.sled.maskY = TEMPy
		else
			gameBall.image.maskScaleY = 1
			gameBall.hat.maskScaleY = 1
			gameBall.head.maskScaleY = 1
			gameBall.pants.maskScaleY = 1
			gameBall.sled.maskScaleY = 1
		end
	end


	function restorePond(tempObject)

		local sheetData = { 
			width=286,
			height=192,
			numFrames=54,
			sheetContentWidth=2002,
			sheetContentHeight=1536
		}

		local sheet = graphics.newImageSheet( "images/game/ice_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 54, time=2000, loopCount=1},
			{name = "ripple", start = 41, count = 13, time=(2500/54)*13}
			}

		tempObject.decal = display.newSprite( sheet, sequenceData)
		tempObject.decal.x = tempObject.x
		tempObject.decal.y = tempObject.y
		tempObject.decal.xScale = tempObject.xScale
		tempObject.decal.yScale = tempObject.yScale
		tempObject.decal.alpha = 0

		tempObject.decal.transitionHandle = transition.to(tempObject.decal,
			{alpha=1, time = 500, onComplete=restorePondComplete} )

		tempObject.decal.upperLevel = tempObject

		gbackground1:insert( tempObject.decal )


		local index = table.indexOf( wallTable, tempObject )

		for i = index+1,#wallTable do
			wallTable[i]:toFront()
		end
	end

	function restorePondComplete(tempDecal)

		tempObject = tempDecal.upperLevel
		local _x = tempObject.x
		local _y = tempObject.y
		local tempSize = tempObject.xScale/2

		tempObject:setFrame(1)
		tempObject:setSequence( "normal" )

		display.remove(tempDecal)
		tempObject.decal = nil --remove the deacal allows ice to crack
	end
--

--REGION WASTELAND
	function wallBoulder(_x, _y, tempSize)

		if tempSize == nil then
			tempSize = 1
		end
		
		id = #wallTable + 1
		wallTable[id] = display.newImage("images/game/boulder.png")
		wallTable[id].xScale = tempSize
		wallTable[id].yScale = tempSize
		wallTable[id].x = _x
		wallTable[id].y = _y
		
		wallTable[id].type = "boulder"
		
		tempShape = {-80,35, -49.5,-39.5, 0,-39.5, 49.5,-39.5, 90,10, 49.5,59.5, 0,70, -60,70}
		if tempSize ~= 1 then
			for i = 1,#tempShape do
				tempShape[i] = tempShape[i]*tempSize
			end
		end
		
		physics.addBody(wallTable[id], "kinematic",
			{shape = tempShape, friction = 0, isSensor = false, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity(0,-configGame.wallSpeed)
		gground2:insert( wallTable[id] )
	end
--

--REGION MILITARY CAMP
	function wallBarbedWire(_x, _y, tempRot, tempSize)

		if tempSize == nil then
			tempSize = 0.5
		end
		
		id = #wallTable + 1
		wallTable[id] = display.newImage("images/game/barbedWire.png")
		wallTable[id].xScale = 1*tempSize
		wallTable[id].yScale = 1*tempSize
		wallTable[id].x = _x
		wallTable[id].y = _y
		wallTable[id].rotation = tempRot
		
		tempShape = {-340,75, 340,75, 340,-75, -340,-75}
		
		for i = 1,#tempShape do
			tempShape[i] = tempShape[i]*0.5*tempSize
		end
		
		physics.addBody(wallTable[id], "kinematic",
			{friction = 5, shape = tempShape, isSensor = false, filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity(0,-configGame.wallSpeed)
		gground1:insert( wallTable[id] )
	end

	--==| Landmine |==--
	function explosion_SpriteListener(event)

		--only removes the explosion sprite
		if event.phase == "ended" then
			recycle( event.target, wallTable )
		end
	end

	function explosionEffect(event, _x, _y)
		--Remove Timer
		index = table.indexOf( timerTable, event.source )
		timer.cancel( timerTable[index] )
		table.remove( timerTable, index )

		if gameBall ~= nil then
				if gameBall.x ~= nil then

				--Explosion Effect
				dist_x = gameBall.x - _x
				dist_y = gameBall.y - _y
				distance = math.sqrt( dist_x^2 + dist_y^2 )
				

				
				if distance <= 350 then
					tempPower = 18
					forceX = ( dist_x / distance ) * tempPower
					forceY = ( dist_y / distance ) * tempPower
					gameBall:applyForce( forceX, forceY, gameBall.x, gameBall.y )
				elseif distance > 350
				and distance < 700 then
					tempPower = 8
					forceX = ( dist_x / distance ) * tempPower
					forceY = ( dist_y / distance ) * tempPower
					gameBall:applyForce( forceX, forceY, gameBall.x, gameBall.y )
				end
			end
		end
	end

	function wallExplosion(event)

		soundCheck(explosionSound)

		--event could be event or timer
		if event.source == nil then
			tempObject = event
		else
			tempObject = event.source.params.object
		end

		local _x = tempObject.x
		local _y = tempObject.y
		
		local id = #wallTable+1
		--
		local sheetData = { 
			width=368,
			height=374,
			numFrames=22,
			sheetContentWidth=1840,
			sheetContentHeight=1870
		}

		local sheet = graphics.newImageSheet( "images/game/explosion_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 22, time=600, loopCount=1}
			}

			
		wallTable[id] = display.newSprite( sheet, sequenceData)
		wallTable[id].timeScale = 1
		wallTable[id].xScale = 2
		wallTable[id].yScale = 2
		wallTable[id]:setFrame(1)
		wallTable[id]:play()
		wallTable[id].x = _x
		wallTable[id].y = _y

		wallTable[id].type = "explosion"
		
		wallTable[id]:addEventListener("sprite", explosion_SpriteListener)
		
		physics.addBody( wallTable[id], "dynamic",
			{radius=300, isSensor=true, filter = interactiveWallCollisionFilter})
		wallTable[id].gravityScale = 0
		wallTable[id]:setLinearVelocity(0,-configGame.wallSpeed)


		--Remove Radius Physics Body
		wallTable[id].removeRadius = display.newCircle(_x,_y,150)
		wallTable[id].removeRadius.alpha = 0
		physics.addBody( wallTable[id].removeRadius, "dynamic",
			{radius=150, isSensor=true, filter = interactiveWallCollisionFilter})
		wallTable[id].removeRadius.gravityScale = 0

		wallTable[id].removeRadius.collision = shockwaveEffect
		wallTable[id].removeRadius:addEventListener("collision", wallTable[id].removeRadius)

		gsky3:insert( wallTable[id] )
	end

	function activateLandmine(tempObject)
		if configGame.state == "play" then
			if tempObject.state == "inactive" 
			and tempObject.y < tempObject.trigger*_H_Real then

				tempObject.state = "active"
				timer.cancel( tempObject.timerHandle )
				tempObject.timer = activateLandmine
				tempObject.timerHandle = timer.performWithDelay(1500, tempObject, 1)

				tempObject:setSequence("slow")
				tempObject:play()

			elseif tempObject.state == "active" then

				tempObject.state = "triggered"
				tempObject.timer = activateLandmine
				tempObject.timerHandle = timer.performWithDelay(250, tempObject, 1)

				tempObject:setSequence("fast")
				tempObject:play()

			elseif tempObject.state == "triggered" then

				wallExplosion(tempObject)

				tempObject:setFrame( 1 )
				tempObject:pause()

				closureExplosion = function(event) return explosionEffect(event, tempObject.x, tempObject.y) end
				timerTable[#timerTable+1] = timer.performWithDelay(100,closureExplosion,1)

			end
		end
	end

	function wallLandmine(_x, _y, tempTime)

		local id = #wallTable+1
		--
		local sheetData = {
			width=384,
			height=281,
			numFrames=6,
			sheetContentWidth=2304,
			sheetContentHeight=281
		}

		local sheet = graphics.newImageSheet( "images/game/landmine_Sprite.png", sheetData)

		local sequenceData = {
			{name = "slow", start = 1, count = 6, time=500, loopCount=0, loopDirection="bounce"},
			{name = "fast", start = 1, count = 6, time=100, loopCount=0, loopDirection="bounce"}
			}


		wallTable[id] = display.newSprite( sheet, sequenceData)
		wallTable[id].timeScale = 1
		wallTable[id].xScale = 0.5
		wallTable[id].yScale = 0.5
		wallTable[id]:setSequence("slow")
		wallTable[id]:setFrame(1)
		--wallTable[id]:play()
		
		wallTable[id].x = _x
		wallTable[id].y = _y
		
		wallTable[id].type = "landmine"
		wallTable[id].state = "inactive"
		wallTable[id].timer = activateLandmine
		wallTable[id].timerHandle = timer.performWithDelay(100, wallTable[id], 0)
		wallTable[id].trigger = (math.random(0,100)/100)*0.6 + 0.3

		physics.addBody( wallTable[id], "kinematic",
			{radius=85, isSensor=true, filter = interactiveWallCollisionFilter})
		wallTable[id]:setLinearVelocity(0, -configGame.wallSpeed) 
		wallTable[id].gravityScale = 0
		
		gground1:insert( wallTable[id] )
	end

	--==| Shields |==--

	function lowerOrRaiseShields(tempObject)
		
		if tempObject.shield == "up" then -- LOWER SHIELDS
			tempObject.shield = "down"
			tempObject.shieldImage.isVisible = false
			
			local tempTime = math.random(1750,2250)
			--closureShield = function() return lowerOrRaiseShields(tempObject) end
			--tempObject.timer = timer.performWithDelay(tempTime,closureShield,1)
			tempObject.timer = lowerOrRaiseShields
			tempObject.timerHandle = timer.performWithDelay(tempTime,tempObject,1)
		elseif tempObject.shield == "down" then
			tempObject.shield = "up"
			tempObject.shieldImage.isVisible = true
			
			local tempTime = math.random(2500,5000)
			--closureShield = function() return lowerOrRaiseShields(tempObject) end
			--tempObject.timer = timer.performWithDelay(tempTime,closureShield,1)
			tempObject.timer = lowerOrRaiseShields
			tempObject.timerHandle = timer.performWithDelay(tempTime,tempObject,1)
		end
	end

	function createShield(tempObject)
		--tempObject.shieldImage = display.newCircle(tempObject.x, tempObject.y, 25)
		local sheetData = { 
			width=392,
			height=391,
			numFrames=17,
			sheetContentWidth=1960,
			sheetContentHeight=1564
		}

		local sheet = graphics.newImageSheet( "images/game/shield_Sprite.png", sheetData)

		local sequenceData = {
			{name = "slow", start = 1, count = 17, time=1000, loopCount=0, loopDirection="forward"}
			}

			
		tempObject.shieldImage = display.newSprite( sheet, sequenceData)
		tempObject.shieldImage.timeScale = 1

		if tempObject.type == "chopper" then
			tempObject.shieldImage.xScale = 1
			tempObject.shieldImage.yScale = 1
		else
			tempObject.shieldImage.xScale = 0.75
			tempObject.shieldImage.yScale = 0.75
		end

		tempObject.shieldImage:setSequence("slow")
		tempObject.shieldImage:setFrame(1)
		tempObject.shieldImage:play()

		tempObject.shield = "up"
		
		local tempTime = math.random(2500,5000)
		--closureShield = function() return lowerOrRaiseShields(tempObject) end
		--tempObject.timer = timer.performWithDelay(tempTime,closureShield,1)
		tempObject.timer = lowerOrRaiseShields
		tempObject.timerHandle = timer.performWithDelay( tempTime,tempObject,1 )
	end

	function slashEnemies(tempObject)
		if tempObject.shield == "down" then

			if configGame.tutorial == "tut_helicopter" then
				updateTutorialMilitaryCamp()
			end
			
			tempObject.health = tempObject.health - 1
			
			lowerOrRaiseShields(tempObject)
			timer.cancel(tempObject.timerHandle)
			
			if tempObject.health <= 0 then
				tempObject.alpha = 0
				if tempObject.type == "fighter" then
					position = table.indexOf(fighterTable, tempObject)
					tempTable = fighterTable
				elseif tempObject.type == "chopper" then
					position = table.indexOf(chopperTable, tempObject)
					tempTable = chopperTable
				end
				wallExplosionTimer = timer.performWithDelay(1,wallExplosion,1)
				wallExplosionTimer.params = {}
				wallExplosionTimer.params.object = tempObject

				recycle(tempObject.shieldImage, tempObject)

				tempDelayFunctionTimer = timer.performWithDelay(250,delayFunction,1)
				tempDelayFunctionTimer.params = {}
				tempDelayFunctionTimer.params.tempFunction = "recycle"
				tempDelayFunctionTimer.params.tempObject = tempObject
				tempDelayFunctionTimer.params.tempTable = tempTable
				tempDelayFunctionTimer.params.position = position
			else
				createChopperSmoke(tempObject)
			end
		end
	end

	function positionShield(tempObject)
		tempObject.shieldImage.x = tempObject.x
		tempObject.shieldImage.y = tempObject.y
	end

	function createChopperSmoke(tempObject)
		--
		local sheetData = { 
			width=288,
			height=296,
			numFrames=41,
			sheetContentWidth=2016,
			sheetContentHeight=1776
		}

		local sheet = graphics.newImageSheet( "images/game/chopperSmoke_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 41, time=800, loopCount=0}
			}
			
		tempObject.smoke = display.newSprite( sheet, sequenceData)
		tempObject.smoke.timeScale = 1
		tempObject.smoke.xScale = 1.1
		tempObject.smoke.yScale = 1.1
		tempObject.smoke:setFrame(1)
		tempObject.smoke:play()
		
		
		tempObject.smoke.x = tempObject.x
		tempObject.smoke.y = tempObject.y
		tempObject.smoke:rotate(tempObject.rotation-180)
		tempObject.smoke.angle = tempObject.rotation

		tempObject.smoke.alpha = 0
		transition.to(tempObject.smoke, {alpha=1, time = 750})

		tempObject.smoke.type = "smoke"	

		gsky1:insert( tempObject.smoke )
	end


	--==| Create Enemies |==--

	function createFighter(x, y, rot)



		-------------
		local id = #fighterTable+1
		--
		local sheetData = {
			width=487,
			height=576,
			numFrames=11,
			sheetContentWidth=5357,
			sheetContentHeight=576
		}

		local sheet = graphics.newImageSheet( "images/game/plane_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 11, time=250, loopCount=0}
			}

			
		fighterTable[id] = display.newSprite( sheet, sequenceData)
		fighterTable[id].timeScale = 1
		fighterTable[id].xScale = 0.5
		fighterTable[id].yScale = 0.5
		fighterTable[id]:setFrame(1)
		fighterTable[id]:play()
		
		
		fighterTable[id].x = x
		fighterTable[id].y = y
		fighterTable[id]:rotate(rot-90)
		fighterTable[id].angle = rot
		fighterTable[id].type = "fighter"
		
		
		fighterTable[id].health = 2
		fighterTable[id].shield = nil
		fighterTable[id].shieldImage = nil
		fighterTable[id].timerHandle = nil
		fighterTable[id].damage = 2
		fighterTable[id].animate = nil
		fighterTable[id].agility = math.random(1.45,1.55)+0.05--1.5
		fighterTable[id].velocity = math.random(285,315)+100--300
		
		
		physics.addBody( fighterTable[id], "dynamic",
			{radius=80, isSensor=true, filter = interactiveWallCollisionFilter})
		--fighterTable[id]:setLinearVelocity(50,50) CONTROLLED BY ANGLE, VELOCITY, AGILITY
		fighterTable[id].gravityScale = 0
		
		createShield( fighterTable[id] )
		gsky2:insert( fighterTable[id] )

		createIndicator( fighterTable[id] )
	end

	function createChopper(x, y, rot, target)

		local id = #chopperTable+1
		--
		local sheetData = { 
			width=502,
			height=358,
			numFrames=15,
			sheetContentWidth=2008,
			sheetContentHeight=1432
		}

		local sheet = graphics.newImageSheet( "images/game/chopper_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 15, time=200, loopCount=0}
			}
			
		chopperTable[id] = display.newSprite( sheet, sequenceData)
		chopperTable[id].timeScale = 1
		chopperTable[id].xScale = 0.9
		chopperTable[id].yScale = 0.9
		chopperTable[id]:setFrame(1)
		chopperTable[id]:play()
		
		
		chopperTable[id].x = x
		chopperTable[id].y = y
		chopperTable[id]:rotate(rot-180)
		chopperTable[id].angle = rot

		chopperTable[id].target = target
		--chopperTable[id].special = "prepareGame" for the chopper that prepares the game

		chopperTable[id].type = "chopper"
		chopperTable[id].health = 2
		chopperTable[id].shield = nil
		chopperTable[id].shieldImage = nil
		chopperTable[id].loaded = true
		chopperTable[id].timerHandle = nil -- SHEILDS
		chopperTable[id].damage = 2
		chopperTable[id].animate = "chopper"
		chopperTable[id].attack = true
		chopperTable[id].agility = 3
		chopperTable[id].velocity = 300
		chopperTable[id].acceleration = 3
		chopperTable[id].vx = chopperTable[id].velocity*math.cos(rot/degrees_conversion)
		chopperTable[id].vy = chopperTable[id].velocity*math.sin(rot/degrees_conversion)
		
		
		physics.addBody( chopperTable[id], "dynamic",
			{radius=150, isSensor=true, filter = interactiveWallCollisionFilter})
		--CONTROLLED BY ANGLE, VELOCITY, AGILITY
		chopperTable[id]:setLinearVelocity(chopperTable[id].vx, chopperTable[id].vy) 
		chopperTable[id].gravityScale = 0
		
		createShield( chopperTable[id] )
		gsky2:insert( chopperTable[id] )

		createIndicator( chopperTable[id] )

		return chopperTable[id]
	end

	function createMissle(x, y, rot, _animate, tempTarget, _velocity)

		local index = table.indexOf( wallTable, tempTarget)

		if tempTarget == nil then
			tempTarget = gameBall
		end

		local id = #missleTable+1

		missleTable[id] = display.newImage("images/game/missle.png")
		missleTable[id].xScale = 0.225
		missleTable[id].yScale = 0.125
		missleTable[id].x = x
		missleTable[id].y = y
		missleTable[id]:rotate(rot-90)
		
		missleTable[id].type = "missle"
		missleTable[id].angle = rot

		if _animate == nil
		or _animate == "heatSeeker" then
			missleTable[id].animate = "heatSeeker"
		elseif _animate == "no" then
			missleTable[id].animate = nil
		end
		
		if _velocity == nil then
			missleTable[id].velocityOrig = configGame.missleVelocitySlow
			missleTable[id].velocity = configGame.missleVelocitySlow
			missleTable[id].agility = 1.5
		elseif _velocity == "fast" then
			missleTable[id].velocityOrig = configGame.missleVelocityFast
			missleTable[id].velocity = configGame.missleVelocityFast
			missleTable[id].agility = 1.5*2
		end

		local vx = -missleTable[id].velocity*math.sin(rot)
		local vy = missleTable[id].velocity*math.cos(rot)
		missleTable[id].target = tempTarget
		missleTable[id].targetDistance = 99999
		
		physics.addBody( missleTable[id], "kinematic",
			{friction = 0, radius=75, isSensor=true, filter = wallCollisionFilter})
		missleTable[id]:setLinearVelocity(vx,vy)

		missleTable[id].timer = missleSlowDown
		missleTable[id].timerHandle= timer.performWithDelay(3000, missleTable[id], 1)

		if tempTarget == gameBall then
			missleTable[id].collision =  missleExplosion
			missleTable[id]:addEventListener( "collision", missleTable[id] )
		end

		gsky1:insert( missleTable[id] )
	end

	function wallHumvee(x, y)

		id = #effectsTable+1
		--
		effectsTable[id] = display.newRect(999,999,50,50)
		effectsTable[id].x = x
		effectsTable[id].y = y
		effectsTable[id].isVisible = false
		
		effectsTable[id].type = "humvee"
		effectsTable[id].velocity = 500
		effectsTable[id].agility = 3
		effectsTable[id].angle = 90
		
		shape = {75,-125, 75,125, -75,125, -75,-125}
		physics.addBody( effectsTable[id], "kinematic",
			{shape=shape, isSensor=false, filter = wallCollisionFilter})
		--effectsTable[id]:setLinearVelocity(0,400) CONTROLLED BY ANGLE, VELOCITY, AGILITY
		
		log_SheetData = {
			width=384,
			height=332,
			numFrames=36,
			sheetContentWidth=13824,
			sheetContentHeight=332
		}

		log_Sheet = graphics.newImageSheet( "images/game/humveeBody_Sprite.png", log_SheetData)

		log_sequenceData = {
			{name = "normal", start = 1, count = 36, time=1000, loopCount=0}
			}

			
		effectsTable[id].body = display.newSprite( log_Sheet, log_sequenceData)
		effectsTable[id].body.timeScale = 1
		effectsTable[id].body.xScale = 1
		effectsTable[id].body.yScale = 1
		effectsTable[id].body:setFrame(1)
		--effectsTable[id]:play()
		
		
		effectsTable[id].body.x = x
		effectsTable[id].body.y = y
		
		------------Wheels
		log_SheetData = {
			width=384,
			height=332,
			numFrames=36,
			sheetContentWidth=13824,
			sheetContentHeight=332
		}

		sheet_straight = graphics.newImageSheet( "images/game/humveeStraight_Sprite.png", log_SheetData)
		sheet_clock = graphics.newImageSheet( "images/game/humveeClock_Sprite.png", log_SheetData)
		sheet_counter = graphics.newImageSheet( "images/game/humveeCounter_Sprite.png", log_SheetData)

		log_sequenceData = {
			{name = "straight", sheet = sheet_straight, start = 1, count = 36, time=1000, loopCount=0},
			{name = "clock", sheet = sheet_clock, start = 1, count = 36, time=1000, loopCount=0},
			{name = "counter", sheet = sheet_counter, start = 1, count = 36, time=1000, loopCount=0}
			}
		
		effectsTable[id].wheels = display.newSprite( sheet_straight, log_sequenceData)
		effectsTable[id].wheels.timeScale = 1
		effectsTable[id].wheels.xScale = 1
		effectsTable[id].wheels.yScale = 1
		effectsTable[id].wheels:setFrame(1)
		--effectsTable[id].wheels:play()
		
		effectsTable[id].wheels:setSequence( "straight" )
		--effectsTable[id].wheels:setFrame(5)
		
		effectsTable[id].wheels.x = effectsTable[id].x
		effectsTable[id].wheels.y = effectsTable[id].y
		
		effectsTable[id]:toFront()
	end






	--==| MISSLE |==--
	function missleSlowDown(tempObject)

		if tempObject.velocity > 200 then
			tempObject.velocity = tempObject.velocity - (tempObject.velocityOrig/20)

			tempObject.timer = missleSlowDown
			tempObject.timerHandle = timer.performWithDelay(250, tempObject, 1)
		end
	end

	function shockwave_SpriteListener(event)
		if event.target.frame >= 6
		and event.target.size == "small" then
			--REMOVE SMALL Physics Body
			physics.removeBody(event.target)
				
			--ADD LARGE Physics Body
			event.target.size = "large"
			
			physics.addBody( event.target, "dynamic",
				{radius=300, isSensor=true, filter = interactiveWallCollisionFilter})
			event.target.gravityScale = 0
			event.target:setLinearVelocity(0,-configGame.wallSpeed)
			event.target.collision = shockwaveEffect
			event.target:addEventListener("collision", event.target)
				
		end
		
		if event.phase == "ended" then
			recycle(event.target, wallTable)
		end
	end

	function shockwaveEffect(self, event)

		if event.other.type == "draw" then

			id = nil
			id = table.indexOf( drawTable, event.other )
			if id ~= nil then
				killDrawLine( event.other)
			end
		end
	end

	function wallShockwave(tempObject)

		local _x = tempObject.x
		local _y = tempObject.y
		
		local id = #wallTable+1
		--
		local sheetData = { 
			width=374,
			height=328,
			numFrames=18,
			sheetContentWidth=1870,
			sheetContentHeight=1312
		}

		--Sheet = graphics.newImageSheet( "images/game/explosionDirt_Sprite.png", sheetData)
		local sheet = graphics.newImageSheet( "images/game/shockwave_Sprite.png", sheetData)

		local sequenceData = {
			{name = "normal", start = 1, count = 18, time=600, loopCount=1}
			}

			
		wallTable[id] = display.newSprite( sheet, sequenceData)
		wallTable[id].timeScale = 1
		wallTable[id].xScale = 1.5
		wallTable[id].yScale = 1.5
		wallTable[id]:setFrame(1)
		wallTable[id]:play()
		
		wallTable[id].x = _x
		wallTable[id].y = _y
		
		wallTable[id].type = "shockwave"
		wallTable[id].size = "small"
		
		
		wallTable[id]:addEventListener( "sprite", shockwave_SpriteListener )
		
		physics.addBody( wallTable[id], "dynamic",
			{radius=150, isSensor=true, filter = interactiveWallCollisionFilter})
		wallTable[id].gravityScale = 0
		wallTable[id]:setLinearVelocity(0,-configGame.wallSpeed)
		wallTable[id].collision = shockwaveEffect
		wallTable[id]:addEventListener("collision", wallTable[id])

		gsky3:insert( wallTable[id] )

		soundCheck(shockwaveExplosionSound)
	end

	function missleExplosion(self, event)

		if event.other.type == "gameBall" then
		
			if event.other.timerHandle ~= nil then
				timer.cancel(event.other.timerHandle)
			end

			event.other.timer = wallShockwave
			event.other.timerHandle = timer.performWithDelay(1, event.other, 1)
			
			--REMOVE OLD MISSLE
			display.remove(event.target)
			id = table.indexOf( missleTable, self )
			table.remove(missleTable, id)	
		end
	end

	function removeMisslesOffScreen() --Removes Off Screen Missles
		for i = #missleTable,1,-1 do
			if missleTable[i].x < 0 or missleTable[i].x > 1536
			or missleTable[i].y < 0 or missleTable[i].y > 2048 then
			
			display.remove(missleTable[i])
			table.remove(missleTable, i)

			end
		end
	end


	--==| ANIMATE and APPROACH |==--
	function animate(tempObject) -- for enemies

		tempTarget = tempObject.target

		if tempTarget == nil then
			tempTarget = gameBall
		end

		--
		
		plane_cur_angle = tempObject.angle
		plane_cur_angle = common.positiveAngle(plane_cur_angle)

		if tempTarget ~= nil then
			if tempTarget.x ~= nil then
				_x = tempTarget.x - tempObject.x
				_y = tempTarget.y - tempObject.y

				angle = math.atan2(_y,_x)
				angle = angle*degrees_conversion
				if angle > 360 then
					angle = angle - 360
				end
				if angle > 360 then
					angle = angle - 360
				end
				if angle < 0 then
					angle = angle + 360
				end
				difference = angle - plane_cur_angle
				

				--DETERMINES WHETHER OBJECTS(ENEMIES) WILL FOLLOW GAMEBALL
				if tempObject.animate == "heatSeeker" and -15 < difference and difference < 15
				or tempObject.animate ~= "heatSeeker" then
				
					new_angle = math.atan2(_y,_x)*degrees_conversion
					if new_angle < 0 then
						new_angle = new_angle + 360 
					end
					if new_angle < plane_cur_angle then
						new_angle = new_angle + 360
					end

					rot = 0
					clockwise_angle = new_angle - plane_cur_angle
					counter_angle = plane_cur_angle - new_angle

					if counter_angle < 0 then
						counter_angle = counter_angle + 360
					end

					
					--rotate CLOCKWISE
					if clockwise_angle <= counter_angle and clockwise_angle <= tempObject.agility then
						rot = clockwise_angle
					--limit rotation clockwise
					elseif clockwise_angle <= counter_angle and clockwise_angle >= tempObject.agility then
						rot = tempObject.agility 
					--COUNTER CLOCKWISE
					elseif counter_angle < clockwise_angle and counter_angle < tempObject.agility then
						rot = counter_angle * -1
					--limit rotation counter clockwise
					elseif counter_angle < clockwise_angle and counter_angle > tempObject.agility then
						rot = tempObject.agility * -1
					end

					tempObject:rotate(rot)
					plane_cur_angle = plane_cur_angle + rot

					if plane_cur_angle > 360 then
						plane_cur_angle = plane_cur_angle - 360
					end
					if plane_cur_angle > 360 then
						plane_cur_angle = plane_cur_angle - 360
					end
					if plane_cur_angle < 0 then
						plane_cur_angle = plane_cur_angle + 360
					end
					
				
					tempObject.angle = plane_cur_angle
				end
			end
		end
	end

	function animationHumvee(tempObject)
		
		----------
		--if tempObject.animate ~= "heatSeeker" then plane_cur_angle = tempObject.angle end
		plane_cur_angle = tempObject.angle

		x = gameBall.x - tempObject.x
		y = gameBall.y - tempObject.y
		--if tempObject.animate == "heatSeeker" then
		angle = math.atan2(y,x)
		angle = angle*degrees_conversion
		if angle > 360 then angle = angle - 360 end
		if angle > 360 then angle = angle - 360 end
		if angle < 0 then angle = angle + 360 end
		difference = angle - plane_cur_angle
		--end

		--DETERMINES WHETHER OBJECTS(ENEMIES) WILL FOLLOW GAMEBALL


			--ANIMATION ROTATION

			
			
				new_angle = math.atan2(y,x)*degrees_conversion
				if new_angle < 0 then new_angle = new_angle + 360 end
				if new_angle < plane_cur_angle then new_angle = new_angle + 360 end

				rot = 0
				clockwise_angle = new_angle - plane_cur_angle
				counter_angle = plane_cur_angle - new_angle

				if counter_angle < 0 then counter_angle = counter_angle + 360 end

				
				--rotate CLOCKWISE
				if clockwise_angle <= counter_angle and
					clockwise_angle <= tempObject.agility then
						rot = clockwise_angle
						tempObject.wheels:setSequence("straight")
				--limit rotation clockwise
				elseif clockwise_angle <= counter_angle and
					clockwise_angle >= tempObject.agility then
						rot = tempObject.agility
						tempObject.wheels:setSequence("clock")
				--COUNTER CLOCKWISE
				elseif counter_angle < clockwise_angle and
					counter_angle < tempObject.agility then
						rot = counter_angle * -1
						tempObject.wheels:setSequence("straight")
				--limit rotation counter clockwise
				elseif counter_angle < clockwise_angle and
					counter_angle > tempObject.agility then
						rot = tempObject.agility * -1
						tempObject.wheels:setSequence("counter")
				end

				plane_cur_angle = plane_cur_angle + rot

				if plane_cur_angle > 360 then plane_cur_angle = plane_cur_angle - 360 end
				if plane_cur_angle > 360 then plane_cur_angle = plane_cur_angle - 360 end
				if plane_cur_angle < 0 then plane_cur_angle = plane_cur_angle + 360 end
				
			
		tempObject.angle = plane_cur_angle
		theta = tempObject.angle
		
		tempObject.rotation = theta-90

		----------
		
		
		for i = 1, #effectsTable do

		--[[
			vx, vy = tempObject:getLinearVelocity()
			theta = math.atan(vy/vx)
			theta = theta*degrees_conversion
			if vx < 0 then
				theta = theta + 180
			end
			tempObject.angle = theta
		]]
			
			falseFrame = math.round(tempObject.angle/10)
			
			if falseFrame <= 10 then
				frame = 10 - falseFrame
				if frame == 0 then frame = 1 end
				tempObject.body:setFrame(frame)
			elseif falseFrame > 10 then
				frame = 47 - falseFrame
				if frame == 0 then frame = 1 end
				tempObject.body:setFrame(frame)
			end
			
		tempObject.body.x = tempObject.x
		tempObject.body.y = tempObject.y
		tempObject.wheels.x = tempObject.x
		tempObject.wheels.y = tempObject.y
		
		tempObject.wheels:setFrame(frame)
			
		end
	end

	function approachFighter(tempObject)

		local _angle = tempObject.angle/degrees_conversion
		local _vx = tempObject.velocity*math.cos(_angle) 
		local _vy = tempObject.velocity*math.sin(_angle) - configGame.wallSpeed*0.5
		tempObject:setLinearVelocity(_vx,_vy)
	end

	function approachChopper(tempObject)

		vx, vy = tempObject:getLinearVelocity()

		if tempObject.target ~= nil then
			_x = tempObject.target.x - tempObject.x
			_y = tempObject.target.y - tempObject.y
		else
			_x = gameBall.x - tempObject.x
			_y = gameBall.y - tempObject.y
		end
		
		if math.sqrt(_x^2+_y^2) > 900 then -- MOVE CLOSER
			_theta = math.atan2(_y,_x)
		elseif math.sqrt(_x^2+_y^2) < 700 then -- MOVE BACKWARD
			_theta = math.atan2(_y,_x)+math.pi
		end

		if _theta ~= nil then
			
			max_vx = tempObject.velocity*math.cos(_theta)
			max_vy = tempObject.velocity*math.sin(_theta)
			
			max_ax = tempObject.acceleration*math.cos(_theta)
			max_ay = tempObject.acceleration*math.sin(_theta)
			
			--NEW
			--XXXXXXXXXXXXXXXX
			difference_x = math.abs(max_vx) - math.abs(vx)
			
			--Get Direction to Accelerate
			if max_ax < 0 then
				tempSign = -1
			elseif max_ax >= 0 then
				tempSign = 1
			end
			
			--Slow Down If Need
			if vx >= 0 and max_ax >= 0 and vx > max_vx then
				tempSign = -1
			elseif vx < 0 and max_ax < 0 and vx < max_vx then
				tempSign = 1
			end
			
			--Get Speed
			if math.abs(difference_x) > math.abs(max_ax) then
				change_vx = math.abs(max_ax)*tempSign
			elseif difference_x <= tempObject.agility then
				change_vx = math.abs(difference_x)*tempSign
			end
			
			--Keep On Screen
			if tempObject.attack == true then
				if tempObject.x < 300 and vx < 50 then
					tempSign = 1
					change_vx = math.abs(tempObject.agility*2)*tempSign
				elseif tempObject.x >1236 and vy > 50 then
					tempSign = -1
					change_vx = math.abs(tempObject.agility*2)*tempSign
				end
			end
			
			new_vx = vx + change_vx
			
			--YYYYYYYYYYY
			difference_y = math.abs(max_vy) - math.abs(vy)
			
			--Get Direction to Accelerate
			if max_ay < 0 then
				tempSign = -1
			elseif max_ay >= 0 then
				tempSign = 1
			end
			
			--Slow Down If Need
			if vy >= 0 and max_ay >= 0 and vy > max_vy then
				tempSign = -1
			elseif vy < 0 and max_ay < 0 and vy < max_vy then
				tempSign = 1
			end
			
			--Get Speed
			if math.abs(difference_y) > math.abs(max_ay) then
				change_vy = math.abs(max_ay)*tempSign
			elseif difference_y <= tempObject.agility then
				change_vy = math.abs(difference_y)*tempSign
			end
				
			--Keep On Screen
			if tempObject.attack == true then
				if tempObject.y < 300 and vy < 50 then
					tempSign = 1
					change_vy = math.abs(tempObject.agility*2)*tempSign

				elseif tempObject.y >1748 and vy > 50 then
					tempSign = -1
					change_vy = math.abs(tempObject.agility*2)*tempSign
				end
			end

			new_vy = vy + change_vy
			

			tempObject:setLinearVelocity( new_vx, new_vy)
		end
	end



	--==| Indicate Off Screen |==--
	function createIndicator(tempObject)
		
		--Create indicator arrow
		tempObject.indicator = display.newImage("images/game/warningArrow.png")
		tempObject.indicator.xScale = 0.75
		tempObject.indicator.yScale = 0.75
		tempObject.indicator.alpha = 0.7
		tempObject.indicator.alphaValue = "decrease"
		tempObject.indicator.isVisible = false
	end

	function updateIndicator(tempObject)

		tempArrow = tempObject.indicator

		if tempObject.special ~= "prepareGame" then
			if tempObject.x < 0
			or tempObject.x > 1536
			or tempObject.y < 0
			or tempObject.y > 2048 then

				tempArrow.isVisible = true
			
				-- POSITION CREATED ARROW or UPDATE POSITION OF ARROW
				if tempObject.x < 0 and tempObject.y < 0 then --CORNER TOP LEFT
					_x = 100
					_y = 100
					_rot = 225
				elseif tempObject.x > 1536 and tempObject.y < 0 then --CORNER TOP RIGHT
					_x = 1436
					_y = 100
					_rot = 325
				elseif tempObject.x > 1536 and tempObject.y > 2048 then --CORNER BOTTOM RIGHT
					_x = 1436
					_y = 1948
					_rot = 45
				elseif tempObject.x < 0 and tempObject.y > 2048 then --CORNER BOTTOM LEFT
					_x = 100
					_y = 1948
					_rot = 135
				elseif tempObject.x < 0 then
					_x = 100
					_y = tempObject.y
					_rot = 180
				elseif tempObject.x > 1536 then
					_x = 1436
					_y = tempObject.y
					_rot = 0
				elseif tempObject.y < 0 then
					_x = tempObject.x
					_y = 100
					_rot = 270
				elseif tempObject.y > 2048 then
					_x = tempObject.x
					_y = 1948
					_rot = 90
				end
				
				
				if _x < 100 then
					_x = 100
				elseif _x > 1436 then
					_x = 1436
				end
				if _y < 100 then
					_y = 100
				elseif _y > 1948 then
					_y = 1948
				end
				
				tempArrow.x = _x
				tempArrow.y = _y
				tempArrow.rotation = _rot - 90
				
				if tempArrow.alphaValue == "increase" then
					tempArrow.alpha = tempArrow.alpha + 0.025
				elseif tempArrow.alphaValue == "decrease" then
					tempArrow.alpha = tempArrow.alpha - 0.025
				end
				
				if tempArrow.alpha <= 0.3 then
					tempArrow.alphaValue = "increase"
				elseif tempArrow.alpha >= 0.7 then
					tempArrow.alphaValue = "decrease"
				end
				
				tempArrow.rotation = _rot - 90
			else
				tempArrow.isVisible = false
			end
		end
	end

	function reloadChopper(event)

		tempObject = event.source.params.object
		tempObject.loaded = true

		local index = table.indexOf( timerTable, event.source )
		timer.cancel( event.source )
		table.remove( timerTable, index )
		tempObject.timerHandle2 = nil
	end

	function fireAndReload(tempObject) --Only Fires at Gameball

		if configGame.state == "play" then
			for i = 1,#chopperTable do
				if chopperTable[i].loaded == true
				and chopperTable[i].x > 50
				and chopperTable[i].x < 1486
				and chopperTable[i].y > 50
				and chopperTable[i].y < 1998 then

					tempObject = chopperTable[i]

					tempTarget = gameBall

					_x = tempTarget.x - tempObject.x
					_y = tempTarget.y - tempObject.y
					_angle = math.atan2(_y,_x)
					_angle_Deg = _angle*degrees_conversion
					if _angle_Deg > 360 then
						_angle_Deg = _angle_Deg - 360
					end
					if _angle_Deg > 360 then
						_angle_Deg = _angle_Deg - 360
					end
					if _angle_Deg < 0 then
						_angle_Deg = _angle_Deg + 360
					end
					difference = _angle_Deg - tempObject.angle
					
					if math.abs(difference) < 15 then

						createMissle(tempObject.x, tempObject.y, tempObject.angle, "heatSeeker", tempTarget)
						tempObject.loaded = nil

						tempObject.timerHandle2 = timer.performWithDelay( 3000, reloadChopper, 1 )
						tempObject.timerHandle2.params = {}
						tempObject.timerHandle2.params.object = tempObject

						timerTable[#timerTable+1] = tempObject.timerHandle2
					end
				end
			end
		end
	end

	function removeBullet()
		id = table.indexOf( bulletHitTable, 1 )
		display.remove(bulletHitTable[1])
		table.remove(bulletHitTable,1)
	end

	function removeBullet2()
		id = table.indexOf( bulletTable2, 1 )
		display.remove(bulletTable2[1])
		table.remove(bulletTable2,1)
	end

	function hitMarker(tempTable) --SHOWS WHERE PLANE IS BEING HIT, Not Being Used

		for i = 1,#tempTable do
		object = tempTable[i]

		plane_cur_angle = object.angle

		x = gameBall.x - object.x
		y = gameBall.y - object.y
		angle = math.atan2(y,x)
		angle = angle*degrees_conversion
		if angle > 360 then angle = angle - 360 end
		if angle > 360 then angle = angle - 360 end
		if angle < 0 then angle = angle + 360 end

		difference = angle - plane_cur_angle
		distance = math.sqrt(x^2 + y^2)
		
			if object.reload == nil and math.abs(difference) < 5 and
				distance < 750 then
				if gameBall.color ~= nil then
					timer.cancel(gameBall.color)
				end
				gameBall:setFillColor(255,150,150)
				gameBall.color = timer.performWithDelay(50, gameBallColor, 1)
				
				angle = (angle-180)/degrees_conversion
				_x = gameBall.radius*math.cos(angle) + gameBall.x
				_y = gameBall.radius*math.sin(angle) + gameBall.y
				bulletHitTable[#bulletHitTable + 1] = display.newCircle(_x,_y,20)

				bulletHitTable[#bulletHitTable].timer = removeBullet
				bulletHitTable[#bulletHitTable].timerHandle = timer.performWithDelay(50, bulletHitTable[#bulletHitTable], 1)
			end
		end
	end




	function targetAngles(primary, secondary) -- NOT BEING USED

		x = secondary.x - primary.x
		y = secondary.y - primary.y
		distance = math.sqrt(x^2 + y^2)
		
		if primary.target == nil and distance > 100
		or distance > 150 and distance < primary.targetDistance then
			
			angle = math.atan2(y,x)
			angle = angle*degrees_conversion
			if angle > 360 then angle = angle - 360 end
			if angle < 0 then angle = angle + 360 end
			--POINT 1
			angle_centerTo_point_1 = (angle - 90)/degrees_conversion
			point_1x = secondary.x + math.cos(angle_centerTo_point_1)*50
			point_1y = secondary.y + math.sin(angle_centerTo_point_1)*50
			x = point_1x - primary.x
			y = point_1y - primary.y
			angle_point_1 = math.atan2(y,x)
			angle_point_1 = angle_point_1*degrees_conversion
			if angle_point_1 > 360 then angle_point_1 = angle_point_1 - 360 end
			if angle_point_1 < 0 then angle_point_1 = angle_point_1 + 360 end
			
			difference_point_1 = math.abs(primary.angle - angle_point_1)
			
			--POINT 2
			angle_centerTo_point_2 = (angle + 90)/degrees_conversion
			point_2x = secondary.x + math.cos(angle_centerTo_point_2)*50
			point_2y = secondary.y + math.sin(angle_centerTo_point_2)*50
			x = point_2x - primary.x
			y = point_2y - primary.y
			angle_point_2 = math.atan2(y,x)
			angle_point_2 = angle_point_2*degrees_conversion
			if angle_point_2 > 360 then angle_point_2 = angle_point_2 - 360 end
			if angle_point_2 < 0 then angle_point_2 = angle_point_2 + 360 end
			
			if angle_point_1 > angle_point_2 then angle_point_2 = angle_point_2 + 360 end
			
			difference_point_2 = math.abs(primary.angle - angle_point_2)
			
			for i = 1,#obstacleTable do --------------------
				if obstacleTable[i].distanceFromGameBall < distance and
					obstacleTable[i].min_angle < angle_point_1 and
					angle_point_2 < obstacleTable[i].max_angle then
					break
				end
				
				if i == #obstacleTable then
					if angle_point_1 < primary.angle and primary.angle < angle_point_2 then
						primary.target = secondary
						primary.targetDistance = distance
						x = primary.target.x - primary.x
						y = primary.target.y - primary.y
						primary.targetAngle = math.atan2(y,x)
						
					elseif difference_point_1 < difference_point_2 and
						difference_point_1 < 5 then
						primary.target = secondary
						primary.targetDistance = distance
						x = primary.target.x - primary.x
						y = primary.target.y - primary.y
						primary.targetAngle = math.atan2(y,x)
						
					elseif difference_point_2 < difference_point_1 and
						difference_point_2 < 5 then
						primary.target = secondary
						primary.targetDistance = distance
						x = primary.target.x - primary.x
						y = primary.target.y - primary.y
						primary.targetAngle = math.atan2(y,x)
						
					end
				end
			end
		end
	end

	function fireBullet(primary, secondary)

		if primary.x > 0 and primary.x < 1536 and primary.y > 0 and primary.y < 2048
			and secondary ~= nil and primary.reload2 == nil then

				
			--CALCULATE ANGLES AND DIRECTION
			_x = secondary.x - primary.x
			_y = secondary.y - primary.y
			_dist = math.sqrt(_x^2 + _y^2)
			_theta = math.atan(_y/_x)
			_theta_Deg = _theta*degrees_conversion
			
			signX = 1
			signY = 1
			if _x < 0 then
				signX = -1
			end
			
			if _y < 0 then
				signY = -1
			end
			
			if signX < 0 and signY > 0 then
				_theta_Deg = _theta_Deg + 180
			elseif signX < 0 and signY < 0 then
				_theta_Deg = _theta_Deg + 180
			elseif signX > 0 and signY < 0 then
				_theta_Deg = _theta_Deg + 360
			end
			

			--FIRE BULLET and apply BULLET FORCE if in site
			if math.abs(_theta_Deg - primary.angle) < 30 then
				forceX = signX*math.abs( 2*math.cos(_theta) )
				forceY = signY*math.abs( 2*math.sin(_theta) )
				
				secondary:applyForce( forceX, forceY, secondary.x, secondary.y )
					
				--Display Bullet
				id = #bulletTable2 + 1
				--bulletTable2[id] = display.newRect(999,999,50,5)
				bulletTable2[id] = display.newImage("images/game/Bullet_Blue.png")
				bulletTable2[id].x = primary.x
				bulletTable2[id].y = primary.y
				bulletTable2[id]:rotate(_theta_Deg-90)
				
				--bulletTable2[id]:setFillColor(255,255,150)
				
				bulletTable2[id].timer = removeBullet2
				bulletTable2[id].timerHandle = timer.performWithDelay(_dist/8, bulletTable2[id], 1)
				
				transition.to(bulletTable2[id], {x = secondary.x, y = secondary.y, time = _dist/8})
				gsky1:insert(bulletTable2[id])

				soundCheck(gunFireSound,.05)
			end
		end	
	end

	function firePrimaryDetermineSecondary(primary)

		--FOR FIGHTERS AND CHOPPERS
		if primary == fighterTable then

			for i = 1,#fighterTable do
				primary = fighterTable[i]
				
				--locateWalls(primary)--FUNC
				
				fighterTable[i].target = nil
				fighterTable[i].targetDistance = nil
				
				secondary = gameBall
				--targetAngles(primary, secondary)--FUNC
				fireBullet(primary, secondary)--FUNC
			end
		end
	end
--

--POWER UPS
	function powerUp(obj, event)
		if event.other.type == "gameBall" then
			id = table.indexOf(wallTable, event.target)
			display.remove(wallTable[id])
			table.remove(wallTable,id)
		end
	end

	function wallPowerUp(x, y)
		local id = #wallTable+1
		wallTable[id] = display.newCircle(999,999,50)
		wallTable[id].x = x
		wallTable[id].y = y
		wallTable[id].type = "powerUp"
		wallTable[id].hit = 0
		wallTable[id]:setFillColor(0,0,255)
		
		physics.addBody( wallTable[id], "kinematic",{friction = 0, radius=50, isSensor=true,
			filter = wallCollisionFilter})
		wallTable[id]:setLinearVelocity( 0, -configGame.wallSpeed )
		
		
		
		--wallTable[id].collision = powerUp
		--wallTable[id]:addEventListener("collision", wallTable[id])
		gground1:insert( wallTable[id] )
	end
--

--WALLS CONTROLLING

	function sendEffect()

		--print("SEND EFFECT")

		if configGame.region == "Wilderness" then
			wallSnowBall()
		elseif configGame.region == "Military Camp"
		and configGame.tutorial == nil then

			option = math.random(1,2)
			if option == 1 then
				x = math.random( 300,1236)
				y = -200
				rot = 90
				createFighter(x, y, rot)
			elseif option == 2 then
				x = math.random( 300,1236)
				y = -200
				rot = 90
				createChopper(x, y, rot)
			end
		end
	end

	function createQueWall()
		queWall = display.newRect(25,25,25,25)
		queWall.x = _W/2
		queWall.y = 600
		queWall.isVisible = false
		physics.addBody( queWall, "kinematic",
			{isSensor=true, filter = graphicCollisionFilter})
		queWall:setLinearVelocity( 0, -configGame.wallSpeed )
	end

	function updateQueWall(_y)

		queWall.y = _y
	end



	--==| REGIONS |==--

	function nextRegion(event)

		--CHANGE REGION
		for i = #regionTable,1,-1 do
			if configGame.region == regionTable[i].environment then

				--Create Timer
				if configGame.region == "tutorial"
				and event == "passed" then
					--Do Nothing
					configGame.region = regionTable[i+1].environment
					CURRENT_STAGE = configGame.region
					CURRENT_STAGE_VALUE = i+1
					nextRegionTimer()

				elseif configGame.region == "Ski Park" then
					--print("next City Tutorial")
					configGame.region = regionTable[i+1].environment
					CURRENT_STAGE = configGame.region
					CURRENT_STAGE_VALUE = i+1

					tempValue = dbfunctions.getTableValue("generalSettings", "completedCityTutorial", "value")
					tempValue = tonumber(tempValue)
					--print(tempValue)
					if tempValue < 1 then
						configGame.tutorial = "City Tutorial"
					else
						configGame.region = "City"
					end

				elseif configGame.region == "City" then
					--print("next MILITARY Camp Tutorial")
					configGame.region = regionTable[i+1].environment
					CURRENT_STAGE = configGame.region
					CURRENT_STAGE_VALUE = i+1

					tempValue = dbfunctions.getTableValue("generalSettings", "completedMilitaryCampTutorial", "value")
					tempValue = tonumber(tempValue)
					--print(tempValue)
					if tempValue < 1 then
						configGame.tutorial = "Military Camp Tutorial"
					else
						configGame.region = "Military Camp"
					end

				elseif configGame.region == "RANDOM" then
					--print("--NEXT REGION RANDOM")
					configGame.region = regionTable[i+1].environment
					CURRENT_STAGE = configGame.region
					CURRENT_STAGE_VALUE = i+1

				elseif configGame.region ~= "tutorial" then
					configGame.region = regionTable[i+1].environment
					CURRENT_STAGE = configGame.region
					CURRENT_STAGE_VALUE = i+1
					nextRegionTimer()
				end
			end

			changeWallSpeed( configGame.wallSpeedOrig )
			--print("NEXT SET ...")
		end

		--SEND EFFECTS

		for i = #timerTable,1,-1 do
			if timerTable[i].type == "sendEffect" then
				timer.cancel( timerTable[i] )
				table.remove( timerTable, i )
			end
		end

		if configGame.region == "Wilderness"
		or configGame.region == "Military Camp" then
			timerTable[#timerTable+1] = timer.performWithDelay( 5000, sendEffect, 0 )
		end

		--UPDATE FURTHEST STAGE IF NEEDED

		local current_i
		local furthest_i

		for i = #regionTable,1,-1 do
			if regionTable[i].environment == configGame.region then
				current_i = i
			end

			if regionTable[i].environment == FURTHEST_STAGE then
				furthest_i = i
			end
		end

		if current_i > furthest_i then
			FURTHEST_STAGE = configGame.region
			dbfunctions.updateTableValue("generalSettings", "furthestStage", "value", configGame.region)
			local id = #screenElementsTable+1
			local options = 
				{
					--parent = textGroup,
					text = "Checkpoint Reached",     
					x = _W/2,
					y = _H_Real/2,
					width = 900,
					height = 0,     --required for multi-line and alignment
					font = _font,   
					fontSize = _fontSize,
					align = "center"  --new alignment parameter
				}
			screenElementsTable[id] = display.newText( options )
			screenElementsTable[id].type = "Checkpoint"
			transition.to(screenElementsTable[id], {time=1250, alpha=0} )
		end
	end

	function nextRegionTimer(event)

		--[[
		
		print("--Go To Next Region")
		--Remove Timer
		if event ~= nil then
			index = table.indexOf( timerTable, event.source )
			timer.cancel( timerTable[index] )
			table.remove( timerTable, index )
		end

		--Create New Timer
		for i = #regionTable,1,-1 do
			if configGame.region == regionTable[i].environment then

				--Create Timer
				if configGame.region == "tutorial" then
					--Do Nothing
				elseif configGame.region == "Military Camp" then
					print("--NEXT REGION RANDOM")
				else
					timerTable[#timerTable+1] = timer.performWithDelay(regionTable[i].length, nextRegion, 1)
				end
			end
		end
		]]
	end
	

	function reorderWalls()

		if gameBall ~= nil then
			gameBall.pants:toFront()
			gameBall.image:toFront()
			gameBall.head:toFront()
			gameBall.hat:toFront()
			gameBall.sled:toFront()
		end

		for i = 1,#wallTable do

			--POSITION

			if wallTable[i].type == "windmill" then
				wallTable[i].decal.y = wallTable[i].y + 10
			elseif wallTable[i].type == "fenceHole" then

				if wallTable[i].post_1 ~= nil then
					wallTable[i].post_1.y = wallTable[i].y + wallTable[i].post_1.yOffset
				end

				if wallTable[i].post_2 ~= nil then
					wallTable[i].post_2.y = wallTable[i].y + wallTable[i].post_2.yOffset
				end
			elseif wallTable[i].type == "gate" then
				wallTable[i].flags.y = wallTable[i].y + wallTable[i].flags.yOffset
				wallTable[i].leftRope.y = wallTable[i].y + wallTable[i].leftRope.yOffset
				--wallTable[i].leftGate.y = wallTable[i].y
				wallTable[i].rightRope.y = wallTable[i].y + wallTable[i].rightRope.yOffset
				--wallTable[i].rightGate.y = wallTable[i].y
			elseif wallTable[i].type == "house" then
				wallTable[i].smoke.y = wallTable[i].y-125
			elseif wallTable[i].type == "bounce" then
				wallTable[i].core.y = wallTable[i].y
				wallTable[i].front.y = wallTable[i].y
			elseif wallTable[i].type == "road" then
				if wallTable[i].mound ~= nil then
					wallTable[i].mound.x = wallTable[i].x + wallTable[i].mound.xOffset
					wallTable[i].mound.y = wallTable[i].y + wallTable[i].mound.yOffset
				end
			elseif wallTable[i].type == "normal" then
				wallTable[i].decal.y = wallTable[i].y
			elseif wallTable[i].type == "jump" then
				wallTable[i].mound.y = wallTable[i].y
				if wallTable[i].decal ~= nil then
					wallTable[i].decal.y = wallTable[i].y
					wallTable[i].decal.maskY = wallTable[i].maskY
				end

				
				--[[
				tempBackgroundTable = {}
				for i2 = 1,#backgroundTable do
					tempBackgroundTable[i2] = {}
					tempBackgroundTable[i2].spot = i2
					tempBackgroundTable[i2].y = backgroundTable[i2].y
				end

				tempBackgroundTable = common.sortTable(tempBackgroundTable, "y")

				local difference = 0
				
				for i2 = 1,#tempBackgroundTable do

					local id = tempBackgroundTable[i2].spot
					
					if backgroundTable[id].left.y > wallTable[i].y then
						difference = backgroundTable[id].left.y - wallTable[i].y
						break
					elseif backgroundTable[id].leftBottom.y > wallTable[i].y then
						difference = backgroundTable[id].leftBottom.y - wallTable[i].y
						break
					end
				end
				
				value = (512+difference)
				print(value)

				wallTable[i].maskY = wallTable[i].y - value
				wallTable[i].mound.maskY = wallTable[i].y - value
				

				if wallTable[i].decal ~= nil then
					wallTable[i].decal.y = wallTable[i].y
					wallTable[i].decal.maskY = wallTable[i].y - value
				end
				]]
			elseif wallTable[i].type == "pond"
			and wallTable[i].decal ~= nil then
				wallTable[i].decal.x = wallTable[i].x
				wallTable[i].decal.y = wallTable[i].y
			elseif wallTable[i].type == "explosion" then
				wallTable[i].removeRadius.x = wallTable[i].x
				wallTable[i].removeRadius.y = wallTable[i].y
			end

			--FRONT and Reorder
			if wallTable[i].type ~= "pond"
			and wallTable[i].type ~= "jump" then
				wallTable[i]:toFront()
			end

			if wallTable[i].type == "windmill" then
				wallTable[i].decal:toFront()
				wallTable[i]:toFront()
			elseif
				wallTable[i].type == "bounce" then
				wallTable[i].core:toFront()
				wallTable[i].front:toFront()
			elseif wallTable[i].type == "barrel" then
				if gameBall ~= nil then
					if wallTable[i].y <= gameBall.y then
						gameBall.pants:toFront()
						gameBall.image:toFront()
						gameBall.head:toFront()
						gameBall.hat:toFront()
						gameBall.sled:toFront()
					end
				end
			elseif wallTable[i].type == "tallTree" then
				if gameBall ~= nil then
					if wallTable[i].y + 240 <= gameBall.y then
						gameBall.pants:toFront()
						gameBall.image:toFront()
						gameBall.head:toFront()
						gameBall.hat:toFront()
						gameBall.sled:toFront()
					end
				end
			elseif wallTable[i].type == "boulder" then
				if gameBall ~= nil then
					if wallTable[i].y + 40 <= gameBall.y then
						gameBall.pants:toFront()
						gameBall.image:toFront()
						gameBall.head:toFront()
						gameBall.hat:toFront()
						gameBall.sled:toFront()
					end
				end
			elseif wallTable[i].type == "road" then
				for ii = 1,#wallTable[i].plow do
					wallTable[i].plow[ii]:toFront()
				end
				if wallTable[i].mound ~= nil then
					wallTable[i].mound:toFront()
				end
			elseif wallTable[i].type == "house" then
				wallTable[i].smoke:toFront()
			elseif wallTable[i].type == "jump" then
				if gameBall ~= nil then
					if gameBall.jumpAirbourne == nil
					and gameBall.jumpCleared == nil
					and wallTable[i].decal == nil then
						wallTable[i].mound:toFront()
					end
				end
			end
			
		end
	end

	--ENVIRONMENT CHANGE TIMER
	function changeEnvironment()

		Environment_Set_Start = 10
		Environment_Set_End = 14
	end

	function changeWallSpeed(newVelocity)
		
		configGame.wallSpeed = newVelocity

		local _f = (configGame.wallSpeed/configGame.wallSpeedOrig)
		configGame.gravityBase = configGame.gravityBaseOrig*_f
		--increased wall speed has already been accounted for in JetPack
		--configGame.gravityPlane = configGame.gravityPlaneOrig*_f
		configGame.gravityBoostSmall = configGame.gravityBoostSmallOrig*_f
		configGame.gravityBoostLarge = configGame.gravityBoostLargeOrig*_f

		local walls = {drawTable, portalTable, bridgeTable}
		for i = 1,#walls do
			for ii = 1,#walls[i] do
				walls[i][ii]:setLinearVelocity(0,-configGame.wallSpeed)
			end
		end

		for i = 1,#wallTable do
			wallTable[i]:setLinearVelocity(0,-configGame.wallSpeed)
			if wallTable[i].type == "gate" then
				wallTable[i].leftGate:setLinearVelocity(0,-configGame.wallSpeed)
				wallTable[i].rightGate:setLinearVelocity(0,-configGame.wallSpeed)
			elseif wallTable[i].type == "road" then
				for i2 = 1,#wallTable[i].plow do 
					local vx = wallTable[i].plow[i2].speed*200*_f
					wallTable[i].plow[i2]:setLinearVelocity(vx,-configGame.wallSpeed)
				end
			end
		end
		
		--FOR BACKGROUND
		backgroundTable[1]:setLinearVelocity(0,-configGame.wallSpeed)
		
		queWall:setLinearVelocity(0,-configGame.wallSpeed)
	end

	function increaseWallSpeed()

		if CURRENT_STAGE_VALUE ~= 1 then
	
			local vx
			local vy
			local newVelocity
			vx,vy = queWall:getLinearVelocity()
			
			if configGame.wallSpeed < configGame.wallSpeedMax
			and vy ~= 0 then

				length = regionTable[CURRENT_STAGE_VALUE].length

				local acceleration = (50*(configGame.wallSpeedMax - configGame.wallSpeedOrig))/length
				newVelocity = configGame.wallSpeed + acceleration
				changeWallSpeed(newVelocity)
			end
		end
	end

	function wallSets()

		--==| RANDOM |==--
			--configGame.region = "Random"
			local tempRegion

			if configGame.region == "Random" then
				tempVariable = math.random(1,3)
				if tempVariable == 1 then
					tempRegion = "City"
				elseif tempVariable == 2 then
					tempRegion = "Forest"
				elseif tempVariable == 3 then
					tempRegion = "Military Camp"
				end
			end

		--==| mainMenu |==--
			if configGame.state == "mainMenu"
			or configGame.state == "ready" then

				if nextSet == 1 then

					createMainMenuTrees( "sendTrees")
				end

		--==| Tutorial |==--
			elseif configGame.region == "tutorial" then

		--==| Bunny Hill |==--
			elseif configGame.region == "Bunny Hill" then

				--nextSet = 3

				if nextSet == 1 then
					--print("option 1")
					option = math.random(1,2)
					if option == 1 then
						wallBarrel(768, _H_Que_Trigger+150)

						wallNormal(235,_H_Que_Trigger+450,250,-10)
						wallNormal(1306,_H_Que_Trigger+250,250,0)

						updateQueWall(_H_Que_Trigger+950)
					elseif option == 2 then
						wallBarrel(768, _H_Que_Trigger+150)

						wallNormal(1306,_H_Que_Trigger+450,250,10)
						wallNormal(235,_H_Que_Trigger+250,250,0)

						updateQueWall(_H_Que_Trigger+950)
					end

				elseif nextSet == 2 then
					--print("option 2")
					option = math.random(1,2)
					if option == 1 then
						wallNormal(468,_H_Que_Trigger+150,250,-10)
						wallNormal(1068,_H_Que_Trigger+250,250,10)

						updateQueWall(_H_Que_Trigger+950)
					elseif option == 2 then
						wallNormal(1068,_H_Que_Trigger+150,250,10)
						wallNormal(468,_H_Que_Trigger+250,250,-10)

						updateQueWall(_H_Que_Trigger+950)
					end
				elseif nextSet == 3 then
					--print("option 3")
					option = math.random(1,2)
					if option == 1 then
						wallNormal(468,_H_Que_Trigger+150,250,10)
						wallNormal(1068,_H_Que_Trigger+250,250,-10)

						updateQueWall(_H_Que_Trigger+950)
					elseif option == 2 then
						wallNormal(1068,_H_Que_Trigger+150,250,-10)
						wallNormal(468,_H_Que_Trigger+250,250,10)

						updateQueWall(_H_Que_Trigger+950)
					end
				end

		--==| Back Country |==--
			elseif configGame.region == "Back Country" then
				--nextSet = 3--math.random(1,3)
				if nextSet == 1 then
					option = math.random(1,2)
					if option == 1 then
						wallNormal(225, _H_Que_Trigger+150, 250, 10)
						wallNormal(475, _H_Que_Trigger+350, 250, "rand")

						wallNormal(1150, _H_Que_Trigger+150, 250, "rand")
						wallNormal(1311, _H_Que_Trigger+350, 250, -10)

						wallSpike(275,_H_Que_Trigger+500)
						wallSpike(750,_H_Que_Trigger+850)
						wallSpike(1000,_H_Que_Trigger+900)

						wallNormal(500, _H_Que_Trigger+1050, 250, "rand")
						wallNormal(1200, _H_Que_Trigger+1100, 250, "rand")
						
						updateQueWall(_H_Que_Trigger+1550)
					elseif option == 2 then
						wallNormal(1311, _H_Que_Trigger+150, 250, -10)
						wallNormal(1061, _H_Que_Trigger+350, 250, "rand")

						wallNormal(386, _H_Que_Trigger+150, 250, "rand")
						wallNormal(225, _H_Que_Trigger+350, 250, 10)

						wallSpike(1261,_H_Que_Trigger+500)
						wallSpike(786,_H_Que_Trigger+850)
						wallSpike(536,_H_Que_Trigger+900)
						
						wallNormal(1036, _H_Que_Trigger+1050, 250, "rand")
						wallNormal(336, _H_Que_Trigger+1100, 250, "rand")
						
						updateQueWall(_H_Que_Trigger+1550)
					end
						
				elseif nextSet == 2 then
					option = math.random(1,2)
					if option == 1 then
						wallNormal(225, _H_Que_Trigger+150, 250, -10)
						wallNormal(600, _H_Que_Trigger+300, 150, "rand")
						wallSpike(700, _H_Que_Trigger+150)
						wallSpike(200, _H_Que_Trigger+350)
						wallSpike(500, _H_Que_Trigger+450)

						wallNormal(1311, _H_Que_Trigger+650, 250, -10)
						wallNormal(700, _H_Que_Trigger+1050, 300, "rand")
						wallNormal(1200, _H_Que_Trigger+950, 250, "rand")
						windmill(1000,_H_Que_Trigger+1150,1)
						
						updateQueWall(_H_Que_Trigger+1650)
					elseif option == 2 then
						wallNormal(1311, _H_Que_Trigger+150, 250, 10)
						wallNormal(936, _H_Que_Trigger+300, 150, "rand")
						wallSpike(836, _H_Que_Trigger+150)
						wallSpike(1336, _H_Que_Trigger+350)
						wallSpike(1036, _H_Que_Trigger+450)

						wallNormal(225, _H_Que_Trigger+650, 250, 10)
						wallNormal(836, _H_Que_Trigger+1050, 300, "rand")
						wallNormal(336, _H_Que_Trigger+950, 250, "rand")
						windmill(536,_H_Que_Trigger+1150,-1)
						
						updateQueWall(_H_Que_Trigger+1650)
					end

				elseif nextSet == 3 then
					option = math.random(1,2)
					if option == 1 then
						wallNormal(225, _H_Que_Trigger+150, 250, -10)
						wallNormal(1311, _H_Que_Trigger+150, 250, 10)

						wallSpike(600, _H_Que_Trigger+350)
						wallSpike(1050, _H_Que_Trigger+500)
						wallTallTree(1350, _H_Que_Trigger+450)
						wallSpike(1250, _H_Que_Trigger+750)
						wallTallTree(250, _H_Que_Trigger+650)

						wallNormal(700, _H_Que_Trigger+650, 250, -10)
						wallNormal(900, _H_Que_Trigger+750, 250, 20)
						wallNormal(650, _H_Que_Trigger+900, 300, 0)
						
						
						updateQueWall(_H_Que_Trigger+1450)
					elseif option == 2 then
						wallNormal(225, _H_Que_Trigger+150, 250, -10)
						wallNormal(1311, _H_Que_Trigger+150, 250, 10)

						wallSpike(936, _H_Que_Trigger+350)
						wallSpike(486, _H_Que_Trigger+500)
						wallTallTree(186, _H_Que_Trigger+450)
						wallSpike(286, _H_Que_Trigger+750)
						wallTallTree(1286, _H_Que_Trigger+650)

						wallNormal(836, _H_Que_Trigger+650, 250, 10)
						wallNormal(636, _H_Que_Trigger+750, 250, -20)
						wallNormal(886, _H_Que_Trigger+900, 300, 0)
						
						
						updateQueWall(_H_Que_Trigger+1450)
					end
				end

		--==| Wilderness |==--
			elseif configGame.region == "Wilderness" then
				nextSet = math.random(1,3)
				
				if nextSet == 1 then
					option =math.random(1,2)
					if option == 1 then
						wallNormal(300, _H_Que_Trigger+150, 150, -20)
						wallNormal(225, _H_Que_Trigger+350, 250, 0)
						wallNormal(500, _H_Que_Trigger+250, 250, 10)
						wallSpike(600, _H_Que_Trigger+350)

						wallNormal(800, _H_Que_Trigger+450, 250, "rand")
						wallNormal(900, _H_Que_Trigger+700, 300, "rand")
						wallSpike(600, _H_Que_Trigger+950)
						
						wallNormal(1311, _H_Que_Trigger+1150, 250, 10)
						wallNormal(1200, _H_Que_Trigger+1350, 150, "rand")
						wallNormal(1000, _H_Que_Trigger+1250, 250, 30)
						wallNormal(800, _H_Que_Trigger+1150, 250, 50)
						
						updateQueWall(_H_Que_Trigger+1650)
					elseif option == 2 then
						wallNormal(1236, _H_Que_Trigger+150, 150, 20)
						wallNormal(1311, _H_Que_Trigger+350, 250, 0)
						wallNormal(1036, _H_Que_Trigger+250, 250, -10)
						wallSpike(936, _H_Que_Trigger+350)

						wallNormal(736, _H_Que_Trigger+450, 250, "rand")
						wallNormal(636, _H_Que_Trigger+700, 300, "rand")
						wallSpike(936, _H_Que_Trigger+950)
						
						wallNormal(225, _H_Que_Trigger+1150, 250, -10)
						wallNormal(336, _H_Que_Trigger+1350, 150, "rand")
						wallNormal(536, _H_Que_Trigger+1250, 250, -30)
						wallNormal(736, _H_Que_Trigger+1150, 250, -50)
						
						updateQueWall(_H_Que_Trigger+1650)
					end
						
				elseif nextSet == 2 then
					option = math.random(1,2)
					if option == 1 then
						wallWind(_H_Que_Trigger+950,30)
						--wallHole("right",_H_Que_Trigger+1450,600)
						
						wallNormal(1200,_H_Que_Trigger+250,250,-20)
						wallNormal(1311, _H_Que_Trigger+350, 250, 10)
						wallNormal(1000,_H_Que_Trigger+400,250,"rand")

						wallNormal(250,_H_Que_Trigger+550,250,-20)
						wallNormal(400,_H_Que_Trigger+650,250,30)
						wallSpike(600,_H_Que_Trigger+750)
						wallNormal(200,_H_Que_Trigger+850,250,"rand")

						wallNormal(700,_H_Que_Trigger+1050,250,"rand")
						wallNormal(1150,_H_Que_Trigger+1050,150,-10)
						wallNormal(700,_H_Que_Trigger+1350,250,"rand")
						wallSpike(800, _H_Que_Trigger+1550)
						
						updateQueWall(_H_Que_Trigger+1950)
					elseif option == 2 then
						wallWind(_H_Que_Trigger+950,-30)
						--wallHole("left",_H_Que_Trigger+1450,600)
						
						wallNormal(336,_H_Que_Trigger+250,250,20)
						wallNormal(225, _H_Que_Trigger+350, 250, -10)
						wallNormal(536,_H_Que_Trigger+400,250,"rand")

						wallNormal(1286,_H_Que_Trigger+550,250,20)
						wallNormal(1136,_H_Que_Trigger+650,250,-30)
						wallSpike(936,_H_Que_Trigger+750)
						wallNormal(1336,_H_Que_Trigger+850,250,"rand")

						wallNormal(836,_H_Que_Trigger+1050,250,"rand")
						wallNormal(386,_H_Que_Trigger+1050,150,10)
						wallNormal(836,_H_Que_Trigger+1350,250,"rand")
						wallSpike(736, _H_Que_Trigger+1550)
						
						updateQueWall(_H_Que_Trigger+1950)
					end
						
				elseif nextSet == 3 then
					option = math.random(1,2)
					if option == 1 then
						wallWind(_H_Que_Trigger+950,30)
						--wallHole("right",_H_Que_Trigger+1050,600)
						
						windmill(1250,_H_Que_Trigger+350,1,"big")
						wallNormal(950,_H_Que_Trigger+350,150,"rand")
						wallSpike(700,_H_Que_Trigger+450)
						windmill(250,_H_Que_Trigger+550,1,"big")
						wallNormal(1100,_H_Que_Trigger+600,250,"rand")
						wallNormal(225,_H_Que_Trigger+750,250,-30)
					
						wallSpike(1200, _H_Que_Trigger+1050)
						windmill(550,_H_Que_Trigger+1150,1,"big")
						wallSpike(850, _H_Que_Trigger+1550)
						windmill(1300,_H_Que_Trigger+1550,1,"big")
						
						updateQueWall(_H_Que_Trigger+2250)
					elseif option == 2 then
						wallWind(_H_Que_Trigger+950,-30)
						--wallHole("left",_H_Que_Trigger+1050,600)
						
						windmill(286,_H_Que_Trigger+350,-1,"big")
						wallNormal(586,_H_Que_Trigger+350,150,"rand")
						wallSpike(836,_H_Que_Trigger+450)
						windmill(1286,_H_Que_Trigger+550,-1,"big")
						wallNormal(436,_H_Que_Trigger+600,250,"rand")
						wallNormal(1311,_H_Que_Trigger+750,250,30)
						
						wallSpike(336, _H_Que_Trigger+1050)
						windmill(986,_H_Que_Trigger+1150,-1,"big")
						wallSpike(686, _H_Que_Trigger+1550)
						windmill(236,_H_Que_Trigger+1550,-1,"big")
						
						updateQueWall(_H_Que_Trigger+2250)
					end
					
				end

		--==| Town |==--
			elseif configGame.region == "Town" then

				nextSet = math.random(1,5)
			
				if nextSet == 1 then
					option = math.random(1,2)
					if option == 1 then

						wallSpike(636,_H_Que_Trigger+150)

						wallHouse(1326,_H_Que_Trigger+350)
						wallHouse(1061,_H_Que_Trigger+350)
						wallHouse(796,_H_Que_Trigger+350)
						
						wallSpike(450,_H_Que_Trigger+600)

						wallHouse(225,_H_Que_Trigger+1150)
						wallHouse(490,_H_Que_Trigger+1150)
						wallHouse(755,_H_Que_Trigger+1150)
						
						updateQueWall(_H_Que_Trigger+1650)
					elseif option == 2 then
						wallSpike(936,_H_Que_Trigger+150)

						wallHouse(225,_H_Que_Trigger+350)
						wallHouse(490,_H_Que_Trigger+350)
						wallHouse(755,_H_Que_Trigger+350)
						
						wallSpike(1086,_H_Que_Trigger+600)

						wallHouse(1326,_H_Que_Trigger+1150)
						wallHouse(1061,_H_Que_Trigger+1150)
						wallHouse(796,_H_Que_Trigger+1150)
						
						updateQueWall(_H_Que_Trigger+1650)
					end
					
				elseif nextSet == 2 then
					option = 1
					if option == 1 then
						wallHouse(450,_H_Que_Trigger+150)
						wallHouse(1086,_H_Que_Trigger+150)
						wallHouse(225,_H_Que_Trigger+550)
						wallHouse(1326,_H_Que_Trigger+550)
						wallBounce(768,_H_Que_Trigger+750)
						wallHouse(225,_H_Que_Trigger+950)
						wallHouse(1326,_H_Que_Trigger+950)
						wallHouse(450,_H_Que_Trigger+1350)
						wallHouse(1086,_H_Que_Trigger+1350)
					
						updateQueWall(_H_Que_Trigger+1850)
					end
					
				elseif nextSet == 3 then
					option = math.random(1,2)
					if option == 1 then
						wallHouse(225,_H_Que_Trigger+150)
						wallHouse(490,_H_Que_Trigger+150)
						wallSnowPlow(_H_Que_Trigger+550,-1,3000)
						wallHouse(736,_H_Que_Trigger+850)
						wallHouse(1001,_H_Que_Trigger+850)
						
						updateQueWall(_H_Que_Trigger+1350)
					elseif option == 2 then
						wallHouse(1326,_H_Que_Trigger+150)
						wallHouse(1061,_H_Que_Trigger+150)
						wallSnowPlow(_H_Que_Trigger+550,1,3000)
						wallHouse(736,_H_Que_Trigger+850)
						wallHouse(471,_H_Que_Trigger+850)
						
						updateQueWall(_H_Que_Trigger+1350)
					end
					
				elseif nextSet == 4 then
					option = math.random(1,2)
					if option == 1 then
						wallHouse(1326,_H_Que_Trigger+150)
						wallSnowPlow(_H_Que_Trigger+500,-1,4000,"top")
						wallSnowPlow(_H_Que_Trigger+800,-3,2500,"none")
						wallSnowPlow(_H_Que_Trigger+1100,1.5,4000,"bottom")
						wallHouse(225,_H_Que_Trigger+1350)
						
						updateQueWall(_H_Que_Trigger+1850)
					elseif option == 2 then
						wallHouse(225,_H_Que_Trigger+150)
						wallSnowPlow(_H_Que_Trigger+500,1,4000,"top")
						wallSnowPlow(_H_Que_Trigger+800,3,2500,"none")
						wallSnowPlow(_H_Que_Trigger+1100,-1.5,4000,"bottom")
						wallHouse(1326,_H_Que_Trigger+1350)
						
						updateQueWall(_H_Que_Trigger+1750)
					end
					
				elseif nextSet == 5 then
					option = math.random(1,2)
					if option == 1 then
						wallHouse(630,_H_Que_Trigger+150)
						wallHouse(906,_H_Que_Trigger+150)
						wallSnowPlow(_H_Que_Trigger+550,2,2500,"top")
						wallSnowPlow(_H_Que_Trigger+850,-2,2500,"bottom")
						
						updateQueWall(_H_Que_Trigger+1450)
					elseif option == 2 then
						wallHouse(630,_H_Que_Trigger+150)
						wallHouse(906,_H_Que_Trigger+150)
						wallSnowPlow(_H_Que_Trigger+550,-2,2500,"top")
						wallSnowPlow(_H_Que_Trigger+850,2,2500,"bottom")
						
						updateQueWall(_H_Que_Trigger+1450)
					end
				end

		--==| Forest |==--
			elseif configGame.region == "Forest" 
			or tempRegion == "Forest" then
				
				nextSet =  math.random(1,5)
				
				if nextSet == 1 then
					option = math.random(1,2)
					if option == 1 then
						wallNormal(1311,_H_Que_Trigger+350,250,-10)
						wallTallTree(384,_H_Que_Trigger+350)
						wallTallTree(584,_H_Que_Trigger+350)
						wallTallTree(284,_H_Que_Trigger+550)
						wallTallTree(484,_H_Que_Trigger+550)
						windmill(950, _H_Que_Trigger+850, -1)
						windmill(225, _H_Que_Trigger+1000, 1, "big")
						
						wallTallTree(1100,_H_Que_Trigger+750)
						wallTallTree(800,_H_Que_Trigger+950)
						wallTallTree(650,_H_Que_Trigger+1050)
						wallTallTree(1200,_H_Que_Trigger+1150)
						wallNormal(600,_H_Que_Trigger+1350,300,10)
						
						updateQueWall(_H_Que_Trigger+1450)
					elseif option == 2 then
						wallNormal(225,_H_Que_Trigger+350,250,10)
						wallTallTree(1152,_H_Que_Trigger+350)
						wallTallTree(952,_H_Que_Trigger+350)
						wallTallTree(1252,_H_Que_Trigger+550)
						wallTallTree(1052,_H_Que_Trigger+550)
						windmill(586, _H_Que_Trigger+850, 1)
						windmill(1311, _H_Que_Trigger+1000, -1, "big")
						
						wallTallTree(436,_H_Que_Trigger+750)
						wallTallTree(736,_H_Que_Trigger+950)
						wallTallTree(886,_H_Que_Trigger+1050)
						wallTallTree(336,_H_Que_Trigger+1150)
						wallNormal(936,_H_Que_Trigger+1350,300,-10)
						
						updateQueWall(_H_Que_Trigger+1450)
					end
					
				elseif nextSet == 2 then
					option = math.random(1,2)
					if option == 1 then

						wallTallTree(150,_H_Que_Trigger+300)
						wallNormal(1311,_H_Que_Trigger+500,300,-10)
						wallTallTree(1375,_H_Que_Trigger+650)
						wallPond(384,_H_Que_Trigger+900, 2)
						wallNormal(225,_H_Que_Trigger+400,250,-10)
						
						wallTallTree(1150,_H_Que_Trigger+900)
						wallTallTree(800,_H_Que_Trigger+900)
						wallTallTree(400,_H_Que_Trigger+1100)
						wallNormal(600,_H_Que_Trigger+1200,150,30)
						wallPond(884,_H_Que_Trigger+1500,2)
						
						updateQueWall(_H_Que_Trigger+1650)
					elseif option == 2 then

						wallTallTree(1386,_H_Que_Trigger+300)
						wallNormal(225,_H_Que_Trigger+500,300,10)
						wallTallTree(161,_H_Que_Trigger+650)
						wallPond(1152,_H_Que_Trigger+900, 2)
						wallNormal(1311,_H_Que_Trigger+400,250,10)
						
						wallTallTree(386,_H_Que_Trigger+900)
						wallTallTree(736,_H_Que_Trigger+900)
						wallTallTree(1136,_H_Que_Trigger+1100)
						wallNormal(936,_H_Que_Trigger+1200,150,-30)
						wallPond(652,_H_Que_Trigger+1500,2)
						
						updateQueWall(_H_Que_Trigger+1650)
					end
				
				elseif nextSet == 3 then
					option = math.random(1,2)
					if option == 1 then
						wallNormal(750,_H_Que_Trigger+450,300,-10)
						wallNormal(175,_H_Que_Trigger+650,150,20)
						wallNormal(1200,_H_Que_Trigger+650,300,10)
						wallTallTree(1400,_H_Que_Trigger+300)
						wallTallTree(625,_H_Que_Trigger+350)
						wallTallTree(1024,_H_Que_Trigger+750)						
						
						wallNormal(500,_H_Que_Trigger+950,150,-45)
						wallTallTree(318,_H_Que_Trigger+800)
						wallNormal(500,_H_Que_Trigger+1150,300,0)
						wallTallTree(700,_H_Que_Trigger+1050)
						wallTallTree(1325,_H_Que_Trigger+1150)
						wallTallTree(250,_H_Que_Trigger+1250)
						
						wallTallTree(1100,_H_Que_Trigger+1350)
						wallNormal(1250,_H_Que_Trigger+1000,300,70)
						wallNormal(1100,_H_Que_Trigger+1350,300,30)
						wallNormal(850,_H_Que_Trigger+1550,300,0)
						wallTallTree(600,_H_Que_Trigger+1550)
						
						updateQueWall(_H_Que_Trigger+1750)
					elseif option == 2 then
						wallNormal(786,_H_Que_Trigger+450,300,10)
						wallNormal(1361,_H_Que_Trigger+650,150,-20)
						wallNormal(336,_H_Que_Trigger+650,300,-10)
						wallTallTree(136,_H_Que_Trigger+300)
						wallTallTree(911,_H_Que_Trigger+350)
						wallTallTree(512,_H_Que_Trigger+750)
												
						wallNormal(1036,_H_Que_Trigger+950,150,45)
						wallTallTree(1218,_H_Que_Trigger+800)
						wallNormal(1036,_H_Que_Trigger+1150,300,0)
						wallTallTree(836,_H_Que_Trigger+1050)
						wallTallTree(211,_H_Que_Trigger+1150)
						wallTallTree(1286,_H_Que_Trigger+1250)
						
						wallTallTree(436,_H_Que_Trigger+1350)
						wallNormal(286,_H_Que_Trigger+1000,300,-70)
						wallNormal(436,_H_Que_Trigger+1350,300,-30)
						wallNormal(686,_H_Que_Trigger+1550,300,0)
						wallTallTree(936,_H_Que_Trigger+1550)
						
						updateQueWall(_H_Que_Trigger+1750)
					end

				elseif nextSet == 4 then
					option = 1
					if option == 1 then

						wallNormal(500,_H_Que_Trigger+150,150,20)
						wallNormal(700,_H_Que_Trigger+250,300,-10)
						wallNormal(1336,_H_Que_Trigger+250,250,-20)
						wallNormal(200,_H_Que_Trigger+350,250,20)

						windmill(1186,_H_Que_Trigger+400,-1)
						wallTallTree(1350,_H_Que_Trigger+500)
						windmill(300,_H_Que_Trigger+600,1)
						
						wallPond(700,_H_Que_Trigger+600,2)
						wallWind(_H_Que_Trigger+600,-15)

						windmill(500,_H_Que_Trigger+900,1)
						wallTallTree(768,_H_Que_Trigger+625)
						windmill(1086,_H_Que_Trigger+750,-1)

						wallTallTree(200,_H_Que_Trigger+900)
						wallTallTree(300,_H_Que_Trigger+1000)
						wallTallTree(1200,_H_Que_Trigger+1050)
						wallPond(800,_H_Que_Trigger+1200,2)

						windmill(768,_H_Que_Trigger+1550,-1,"big")

						updateQueWall(_H_Que_Trigger+1700)
					end

				elseif nextSet == 5 then
					option = math.random(1,2)
					if option == 1 then

						wallNormal(1000,_H_Que_Trigger+150,300,-20)
						wallNormal(686,_H_Que_Trigger+350,300,20)
						wallNormal(1286,_H_Que_Trigger+350,300,20)
						windmill(1100,_H_Que_Trigger+450,-1,"big")
						wallTallTree(200,_H_Que_Trigger+250)

						wallTallTree(950,_H_Que_Trigger+450)
						wallNormal(1025,_H_Que_Trigger+950,150,50)
						wallTallTree(1100,_H_Que_Trigger+750)

						wallPond(500,_H_Que_Trigger+750,2)
						wallNormal(225,_H_Que_Trigger+950,300,-10)

						windmill(325,_H_Que_Trigger+1075,-1,"big")
						wallNormal(575,_H_Que_Trigger+1050,300,-10)
						windmill(850,_H_Que_Trigger+1050,1,"big")

						updateQueWall(_H_Que_Trigger+1450)
					elseif option == 2 then

						wallNormal(536,_H_Que_Trigger+150,300,20)
						wallNormal(850,_H_Que_Trigger+350,300,-20)
						wallNormal(250,_H_Que_Trigger+350,300,-20)
						windmill(436,_H_Que_Trigger+450,1,"big")
						wallTallTree(1336,_H_Que_Trigger+250)

						wallTallTree(636,_H_Que_Trigger+450)
						wallNormal(511,_H_Que_Trigger+950,150,-50)
						wallTallTree(436,_H_Que_Trigger+750)

						wallPond(1036,_H_Que_Trigger+750,2)
						wallNormal(1311,_H_Que_Trigger+950,300,10)

						windmill(1211,_H_Que_Trigger+1075,1,"big")
						wallNormal(961,_H_Que_Trigger+1050,300,10)
						windmill(686,_H_Que_Trigger+1050,-1,"big")

						updateQueWall(_H_Que_Trigger+1450)
					end
					
				end

		--==| Ski Park |==--
			elseif configGame.region == "Ski Park" then
				--print("SKI PARK WALL SET")
				nextSet = math.random(1,6)
				if nextSet == 1 then
					option = math.random(1,2)
					if option == 1 then
						
						wallBarrel(1100,_H_Que_Trigger+150)
						wallBarrel(500,_H_Que_Trigger+350)
						wallBarrel(800,_H_Que_Trigger+550)
						
						wallTallTree(1300,_H_Que_Trigger+550)
						wallTallTree(350,_H_Que_Trigger+750)

						wallJump(_H_Que_Trigger+1000, "middle")
						
						updateQueWall(_H_Que_Trigger+2000)--1450)
					elseif option == 2 then
						wallBarrel(436,_H_Que_Trigger+150)
						wallBarrel(1036,_H_Que_Trigger+350)
						wallBarrel(736,_H_Que_Trigger+550)
						
						wallTallTree(236,_H_Que_Trigger+550)
						wallTallTree(1186,_H_Que_Trigger+750)

						wallJump(_H_Que_Trigger+1000, "middle")
						
						updateQueWall(_H_Que_Trigger+1450)
					end
					
				elseif nextSet == 2 then
					option = math.random(1,2)
					if option == 1 then
						
						wallNormal(250,_H_Que_Trigger+150,300,-10)
						wallNormal(550,_H_Que_Trigger+220,300,0)
						wallNormal(850,_H_Que_Trigger+330,300,-30)
						wallJump(_H_Que_Trigger+850)

						wallTallTree(1386,_H_Que_Trigger+800)
						wallTallTree(900,_H_Que_Trigger+1000)
						
						updateQueWall(_H_Que_Trigger+1500)
					elseif option == 2 then
						
						wallNormal(1286,_H_Que_Trigger+150,300,10)
						wallNormal(986,_H_Que_Trigger+200,300,0)
						wallNormal(686,_H_Que_Trigger+330,300,30)
						wallJump(_H_Que_Trigger+850, "right")

						wallTallTree(250,_H_Que_Trigger+800)
						wallTallTree(636,_H_Que_Trigger+1000)
						
						updateQueWall(_H_Que_Trigger+1500)
					end
				elseif nextSet == 3 then
					option = math.random(1,2)
					if option == 1 then
					
						wallNormal(250,_H_Que_Trigger+50,300,-40)
						wallBarrel(868,_H_Que_Trigger+150)
						wallNormal(700,_H_Que_Trigger+150,300,10)
						wallNormal(400,_H_Que_Trigger+150,300,0,0)
						wallTallTree(200,_H_Que_Trigger+250)
						
						wallNormal(1286,_H_Que_Trigger+450,300,40)
						wallTallTree(1336,_H_Que_Trigger+450)
						wallBarrel(686,_H_Que_Trigger+550)
						wallNormal(836,_H_Que_Trigger+550,300,-10)
						wallNormal(1136,_H_Que_Trigger+570,300,0,0)
						
						wallNormal(250,_H_Que_Trigger+850,300,-40)
						wallBarrel(868,_H_Que_Trigger+950)
						wallNormal(700,_H_Que_Trigger+950,300,10)
						wallNormal(400,_H_Que_Trigger+970,300,0,0)
						wallTallTree(350,_H_Que_Trigger+1050)

							
						updateQueWall(_H_Que_Trigger+1450)
					elseif option == 2 then
						
						wallNormal(1286,_H_Que_Trigger+50,300,40)
						wallBarrel(668,_H_Que_Trigger+150)
						wallNormal(836,_H_Que_Trigger+150,300,-10)
						wallNormal(1136,_H_Que_Trigger+150,300,0,0)
						wallTallTree(1336,_H_Que_Trigger+250)
						
						wallNormal(250,_H_Que_Trigger+450,300,-40)
						wallTallTree(200,_H_Que_Trigger+450)
						wallBarrel(868,_H_Que_Trigger+550)
						wallNormal(700,_H_Que_Trigger+550,300,10)
						wallNormal(400,_H_Que_Trigger+570,300,0,0)
						
						wallNormal(1286,_H_Que_Trigger+850,300,40)
						wallBarrel(668,_H_Que_Trigger+950)
						wallNormal(836,_H_Que_Trigger+950,300,-10)
						wallNormal(1136,_H_Que_Trigger+970,300,0,0)
						
						wallTallTree(1136,_H_Que_Trigger+1050)
						
						updateQueWall(_H_Que_Trigger+1450)
					end
				elseif nextSet == 4 then
					option = math.random(1,2)
					if option == 1 then

						wallNormal( 1270,_H_Que_Trigger+150,300,0)
						wallNormal( 935,_H_Que_Trigger+200,300,10)
						wallBarrel( 350,_H_Que_Trigger+250)
						wallNormal( 650,_H_Que_Trigger+350,300,45)
						wallNormal( 550,_H_Que_Trigger+550,150,90)

						wallNormal( 800,_H_Que_Trigger+750,150,90)
						wallBarrel( 1300,_H_Que_Trigger+800)
						wallNormal( 725,_H_Que_Trigger+900,300,50)
						wallNormal( 250,_H_Que_Trigger+950,250,-10)
						wallBarrel( 1000,_H_Que_Trigger+1000)
						wallSnowMachine( 500,_H_Que_Trigger+1100,"northEast")

						wallTallTree(200,_H_Que_Trigger+1200)

						updateQueWall(_H_Que_Trigger+1650)
					elseif option == 2 then

						wallNormal( 266,_H_Que_Trigger+150,300,0)
						wallNormal( 601,_H_Que_Trigger+200,300,-10)
						wallBarrel( 1186,_H_Que_Trigger+250 )
						wallNormal( 886,_H_Que_Trigger+350,300,-45)
						wallNormal( 986+20,_H_Que_Trigger+540,150,-90)

						wallNormal( 736,_H_Que_Trigger+750,150,90)
						wallBarrel( 236,_H_Que_Trigger+800 )
						wallNormal( 811,_H_Que_Trigger+900,300,-50)
						wallNormal( 1286,_H_Que_Trigger+950,250,10)
						wallBarrel( 536,_H_Que_Trigger+1000 )
						wallSnowMachine( 1036,_H_Que_Trigger+1100,"northWest")

						wallTallTree(1336,_H_Que_Trigger+1200)

						updateQueWall(_H_Que_Trigger+1650)
					end
				elseif nextSet == 5 then
					option = math.random(1,2)
					if option == 1 then

						
						wallNormal(240, _H_Que_Trigger+50 , 250, -10)
						wallNormal(450, _H_Que_Trigger+150, 300, -30)
						wallNormal(700, _H_Que_Trigger+350, 300, -50)
						wallTallTree(250, _H_Que_Trigger+350)
						wallSnowMachine(768, _H_Que_Trigger+650, "northEast")

						wallBarrel(1186, _H_Que_Trigger+975)
						wallNormal(768, _H_Que_Trigger+1075, 250, -45)
						wallBarrel(350, _H_Que_Trigger+1175)

						wallNormal(1296, _H_Que_Trigger+1250 , 250, 10)
						wallNormal(1086, _H_Que_Trigger+1350, 300, 30)
						wallSnowMachine(800, _H_Que_Trigger+1500, "northWest")
						wallTallTree(1286, _H_Que_Trigger+1550)

						updateQueWall(_H_Que_Trigger+1950)
					elseif option == 2 then

						wallNormal(1296, _H_Que_Trigger+50 , 250, 10)
						wallNormal(1086, _H_Que_Trigger+150, 300, 30)
						wallNormal(836, _H_Que_Trigger+350, 300, 50)
						wallTallTree(1286, _H_Que_Trigger+350)
						wallSnowMachine(768, _H_Que_Trigger+650, "northWest")

						wallBarrel(350, _H_Que_Trigger+975)
						wallNormal(768, _H_Que_Trigger+1075, 250, 45)
						wallBarrel(1186, _H_Que_Trigger+1175)

						wallNormal(240, _H_Que_Trigger+1250 , 250, -10)
						wallNormal(450, _H_Que_Trigger+1350, 300, -30)
						wallSnowMachine(736, _H_Que_Trigger+1500, "northEast")
						wallTallTree(250, _H_Que_Trigger+1550)

						updateQueWall(_H_Que_Trigger+1950)
					end
				elseif nextSet == 6 then
					option = math.random(1,2)
					if option == 1 then
						wallBarrel( 600,_H_Que_Trigger+150)
						wallNormal( 1286,_H_Que_Trigger+350,250,30)
						wallBarrel( 1150,_H_Que_Trigger+450)
						wallNormal( 250,_H_Que_Trigger+450,250,-10 )
						wallSnowMachine( 300,_H_Que_Trigger+650, "northEast")


						wallNormal( 768,_H_Que_Trigger+650,150,-50 )
						wallTallTree(200,_H_Que_Trigger+750)
						wallTallTree(1336,_H_Que_Trigger+750)
						wallNormal( 800,_H_Que_Trigger+800,250,0 )

						wallNormal( 900,_H_Que_Trigger+1100,150,90)
						wallNormal( 900,_H_Que_Trigger+1200,300,0)

						wallNormal( 400,_H_Que_Trigger+1350,250,-60)
						wallBarrel( 500,_H_Que_Trigger+1450)

						wallSnowMachine( 1286,_H_Que_Trigger+1550, "northWest")

						updateQueWall(_H_Que_Trigger+2050)
					elseif option == 2 then
						wallBarrel( 936,_H_Que_Trigger+150)
						wallNormal( 250,_H_Que_Trigger+350,250,-30)
						wallBarrel( 386,_H_Que_Trigger+450)
						wallNormal( 1286,_H_Que_Trigger+450,250,10 )
						wallSnowMachine( 1236,_H_Que_Trigger+650, "northWest")

						wallNormal( 768,_H_Que_Trigger+650,150,50 )
						wallTallTree(200,_H_Que_Trigger+750)
						wallTallTree(1336,_H_Que_Trigger+750)
						wallNormal( 736,_H_Que_Trigger+800,250,0 )

						wallNormal( 636,_H_Que_Trigger+1100,150,90)
						wallNormal( 636,_H_Que_Trigger+1200,300,0)

						wallNormal( 1136,_H_Que_Trigger+1350,250,60)
						wallBarrel( 1036,_H_Que_Trigger+1450)

						wallSnowMachine( 250,_H_Que_Trigger+1550, "northEast")

						updateQueWall(_H_Que_Trigger+2050)
					end
				end
		
		--==| City Tutorial |==--
			elseif configGame.tutorial == "City Tutorial" then

				wallNormal(125,_H_Que_Trigger+100,300,-30)
				wallNormal(1536-125,_H_Que_Trigger+100,300,30)

				wallHouse(768-265/2-265-5,_H_Que_Trigger+250)
				wallHouse(768+265/2+265+5,_H_Que_Trigger+250)

				wallHouse(768-265/2-5,_H_Que_Trigger+300)
				wallHouse(768+265/2+5,_H_Que_Trigger+300)
				

				wallNormal(93,350+_H_Que_Trigger,300,-50)
				wallNormal(1443,350+_H_Que_Trigger,300,50)

				wallNormal(268,550+_H_Que_Trigger,300,-40)
				wallNormal(1268,550+_H_Que_Trigger,300,40)
				
				local tempGate = wallGate(768,675+_H_Que_Trigger)

				updateQueWall(_H_Que_Trigger+1400)

				readyTutorialCity( tempGate )

		--==| City |==--
			elseif configGame.region == "City" 
			or tempRegion == "City" then
				nextSet = math.random(1,5)
				if nextSet == 1 then
					option = math.random(1,2)
					if option == 1 then
						wallHouse(1326,_H_Que_Trigger+150)
						wallHouse(1061,_H_Que_Trigger+150)
						wallHouse(225,_H_Que_Trigger+275)
						wallSpike(450,_H_Que_Trigger+375)
						wallTallTree(825,_H_Que_Trigger+300)
						
						wallSnowPlow(_H_Que_Trigger+750,4,2000)
						wallBounce(618,_H_Que_Trigger+500,1.5)
						wallBounce(918,_H_Que_Trigger+950,1.5)
						wallTallTree(1300,_H_Que_Trigger+750)
							
						wallNormal(550,_H_Que_Trigger+1025,150,10)
						wallNormal(400,_H_Que_Trigger+1050,150,-20)
						
						updateQueWall(_H_Que_Trigger+1350)
					elseif option == 2 then
						wallHouse(225,_H_Que_Trigger+150)
						wallHouse(225+265,_H_Que_Trigger+150)
						wallHouse(1326,_H_Que_Trigger+275)
						wallSpike(1086,_H_Que_Trigger+375)
						wallTallTree(711,_H_Que_Trigger+300)
						
						wallSnowPlow(_H_Que_Trigger+750,-4,2000)
						wallBounce(918,_H_Que_Trigger+500,1.5)
						wallBounce(618,_H_Que_Trigger+950,1.5)
						wallTallTree(236,_H_Que_Trigger+750)
							
						wallNormal(986,_H_Que_Trigger+1025,150,-10)
						wallNormal(1136,_H_Que_Trigger+1050,150,20)
						
						updateQueWall(_H_Que_Trigger+1350)
					end

				elseif nextSet == 2 then
					option = math.random(1,2)
					if option == 1 then
						wallBounce(1300,_H_Que_Trigger+150)
						wallHouse(225,_H_Que_Trigger+500)
						wallGate(725,_H_Que_Trigger+600)
						wallBounce(1150,_H_Que_Trigger+450)
						
						wallTallTree(1250,_H_Que_Trigger+550)
						
						wallNormal(725,_H_Que_Trigger+950,250,45)
						wallNormal(1300,_H_Que_Trigger+1000,250,0)
						wallNormal(550,_H_Que_Trigger+1075,150,20)

						wallBounce(375,_H_Que_Trigger+1050)
						
						updateQueWall(_H_Que_Trigger+1250)
					elseif option == 2 then
						wallBounce(236,_H_Que_Trigger+150)
						wallHouse(1326,_H_Que_Trigger+500)
						wallGate(811,_H_Que_Trigger+600)
						wallBounce(386,_H_Que_Trigger+450)
						
						wallTallTree(286,_H_Que_Trigger+550)
						
						wallNormal(811,_H_Que_Trigger+950,250,-45)
						wallNormal(236,_H_Que_Trigger+1000,250,0)
						wallNormal(986,_H_Que_Trigger+1075,150,-20)

						wallBounce(1161,_H_Que_Trigger+1050)
						
						updateQueWall(_H_Que_Trigger+1250)
					end

				elseif nextSet == 3 then
					option = math.random(1,2)
					if option == 1 then
						wallSnowPlow(_H_Que_Trigger+450,-2,1500)
						wallSnowPlow(_H_Que_Trigger+1050,-4,2000)
						
						wallTallTree(900,_H_Que_Trigger+350)
						windmill(736,_H_Que_Trigger+750,-1,"big")
						windmill(1250,_H_Que_Trigger+750,-1,"big")
						wallTallTree(300,_H_Que_Trigger+625)
						wallWind(_H_Que_Trigger+900,-30)

						wallTallTree(1300,_H_Que_Trigger+1100)
						wallTallTree(600,_H_Que_Trigger+1200)

						updateQueWall(_H_Que_Trigger+1500)
					elseif option == 2 then
						wallSnowPlow(_H_Que_Trigger+450,2,1500)
						wallSnowPlow(_H_Que_Trigger+1050,4,2000)
						
						wallTallTree(636,_H_Que_Trigger+350)
						windmill(800,_H_Que_Trigger+750,1,"big")
						windmill(286,_H_Que_Trigger+750,1,"big")
						wallTallTree(1236,_H_Que_Trigger+625)
						wallWind(_H_Que_Trigger+900,30)

						wallTallTree(236,_H_Que_Trigger+1100)
						wallTallTree(936,_H_Que_Trigger+1200)

						updateQueWall(_H_Que_Trigger+1500)
					end
				elseif nextSet == 4 then
					option = math.random(1,2)
					if option == 1 then
						wallTallTree(1400,_H_Que_Trigger-100)

						wallHouse(1326,_H_Que_Trigger+250)
						wallBounce(1326-265,_H_Que_Trigger+150,1.5)
						wallHouse(1326-265*2,_H_Que_Trigger+200)
						wallHouse(1326-265*3,_H_Que_Trigger+250)

						wallTallTree(175,_H_Que_Trigger+275)

						wallHouse(225,_H_Que_Trigger+650)
						wallHouse(225+265,_H_Que_Trigger+750)
						wallBounce(225+265*2,_H_Que_Trigger+650,1.5)
						wallHouse(225+265*3,_H_Que_Trigger+750)

						updateQueWall(_H_Que_Trigger+1200)
					elseif option == 2 then
						wallTallTree(136,_H_Que_Trigger-100)

						wallHouse(225,_H_Que_Trigger+250)
						wallBounce(225+265,_H_Que_Trigger+150,1.5)
						wallHouse(225+265*2,_H_Que_Trigger+200)
						wallHouse(225+265*3,_H_Que_Trigger+250)

						wallTallTree(1361,_H_Que_Trigger+275)

						wallHouse(1326,_H_Que_Trigger+650)
						wallHouse(1326-265,_H_Que_Trigger+750)
						wallBounce(1326-265*2,_H_Que_Trigger+650,1.5)
						wallHouse(1326-265*3,_H_Que_Trigger+750)

						updateQueWall(_H_Que_Trigger+1200)
					end

				elseif nextSet == 5 then
					option = math.random(1,4)
					if option == 1 then
						wallHouse(230,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*2,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*3,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*4+20,_H_Que_Trigger+400+math.random(1,175))
					elseif option == 2 then
						wallHouse(230,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*2,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*3+20,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*4+20,_H_Que_Trigger+400+math.random(1,175))
					elseif option == 3 then
						wallHouse(230,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*2+20,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*3+20,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*4+20,_H_Que_Trigger+400+math.random(1,175))
					elseif option == 4 then
						wallHouse(230,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265+20,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*2+20,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*3+20,_H_Que_Trigger+400+math.random(1,175))
						wallHouse(230+265*4+20,_H_Que_Trigger+400+math.random(1,175))
					end

						wallHouse(230+265-math.random(1,250),
							_H_Que_Trigger+800+math.random(1,175) )
						wallHouse(230+265*2,
							_H_Que_Trigger+800+math.random(1,175) )
						wallHouse(230+265*3+math.random(1,300),
							_H_Que_Trigger+800+math.random(1,175) )

						updateQueWall(_H_Que_Trigger+1200)
					
				end
					
		--==| Wasteland |==--
			elseif configGame.region == "Wasteland" then

		--==| Military Camp Tutorial |==--
			elseif configGame.tutorial == "Military Camp Tutorial" then

				wallNormal(93,350+_H_Que_Trigger,300,-50)
				wallNormal(1443,350+_H_Que_Trigger,300,50)

				wallNormal(268,550+_H_Que_Trigger,300,-40)
				wallNormal(1268,550+_H_Que_Trigger,300,40)
				
				local tempGate = wallGate(768,675+_H_Que_Trigger)

				updateQueWall(_H_Que_Trigger+1400)

				readyTutorialMilitaryCamp( tempGate )

		--==| Military Camp |==--
			elseif configGame.region == "Military Camp" 
			or tempRegion == "Military Camp" then
				
				nextSet = math.random(1,5)
				--nextSet = 6
				
				if nextSet == 1 then
					open = "either"
					option = 1
					if option == 1 then
						wallBoulder(500,_H_Que_Trigger+150)
						wallBoulder(1000,_H_Que_Trigger+250)
						wallBoulder(786,_H_Que_Trigger+350)

						wallBarbedWire(200,_H_Que_Trigger+700,0,1)
						wallGate(750,_H_Que_Trigger+750)
						wallBarbedWire(1300,_H_Que_Trigger+700,0,1)
				
						updateQueWall(_H_Que_Trigger+1250)
					elseif option == 2 then
						
					end
					
				elseif nextSet == 2 then
					open = "either"
					option = 1
					if option == 1 then
						wallBoulder(500,_H_Que_Trigger+150)
						wallBoulder(1400,_H_Que_Trigger+350)

						wallBarbedWire(200,_H_Que_Trigger+700,0,1.05)
						wallBarbedWire(600,_H_Que_Trigger+700,0,1.05)
						wallGate(1150,_H_Que_Trigger+750)

						wallBoulder(786,_H_Que_Trigger+950)
				
						updateQueWall(_H_Que_Trigger+1250)
					elseif option == 2 then
						
					end
					
				elseif nextSet == 3 then
					open = "either"
					option = 1
					if option == 1 then
						wallBoulder(1036,_H_Que_Trigger+150)
						wallBoulder(136,_H_Que_Trigger+350)

						wallGate(386,_H_Que_Trigger+750)
						wallBarbedWire(1336,_H_Que_Trigger+700,0,1.05)
						wallBarbedWire(936,_H_Que_Trigger+700,0,1.05)
						

						wallBoulder(786,_H_Que_Trigger+950)
				
						updateQueWall(_H_Que_Trigger+1250)
					elseif option == 2 then
						
					end
					
				elseif nextSet == 4 then
					open = "either"
					option = math.random(1,2)
					if option == 1 then
					
						wallWind(_H_Que_Trigger+650,30)
						wallBoulder(800,_H_Que_Trigger+150,1.5)
						wallBoulder(300,_H_Que_Trigger+200)
						
						wallBoulder(1118,_H_Que_Trigger+400)
						wallBoulder(1486,_H_Que_Trigger+500)
						wallBoulder(386,_H_Que_Trigger+600)
						wallBoulder(768,_H_Que_Trigger+550)
						
						wallBoulder(1100,_H_Que_Trigger+750)
						wallBoulder(600,_H_Que_Trigger+950,1.5)
						wallBoulder(200,_H_Que_Trigger+1050)
						
						wallBoulder(1000,_H_Que_Trigger+1100)
						wallBoulder(1336,_H_Que_Trigger+1150)
						
						updateQueWall(_H_Que_Trigger+1650)
					elseif option == 2 then
						
						wallWind(_H_Que_Trigger+650,-30)
						wallBoulder(736,_H_Que_Trigger+150,1.5)
						wallBoulder(1236,_H_Que_Trigger+200)
						
						wallBoulder(418,_H_Que_Trigger+400)
						wallBoulder(100,_H_Que_Trigger+300)--CHECK
						wallBoulder(1150,_H_Que_Trigger+600)
						wallBoulder(768,_H_Que_Trigger+550)
						
						wallBoulder(436,_H_Que_Trigger+750)
						wallBoulder(936,_H_Que_Trigger+950,1.5)
						wallBoulder(1336,_H_Que_Trigger+1050)
						
						wallBoulder(536,_H_Que_Trigger+1100)
						wallBoulder(200,_H_Que_Trigger+1150)
						
						updateQueWall(_H_Que_Trigger+1650)
					end

				elseif nextSet == 5 then
					open = "either"
					option = math.random(1,2)
					if option == 1 then

						wallBoulder(950,_H_Que_Trigger+150)
						wallBarbedWire(1200,_H_Que_Trigger+300,0,1)
						wallBoulder(500,_H_Que_Trigger+400)
						
						wallLandmine(1000,_H_Que_Trigger+600,1800)
						wallBoulder(1400,_H_Que_Trigger+800)
						wallBarbedWire(200,_H_Que_Trigger+850,0,1)
						wallGate(750,_H_Que_Trigger+900)

						wallLandmine(300,_H_Que_Trigger+1050,4500)
						wallBoulder( 1050, _H_Que_Trigger+1150)
						wallTallTree(700,_H_Que_Trigger+1150)
						wallBoulder( 1200, _H_Que_Trigger+1350)
						wallBoulder(600,_H_Que_Trigger+1450)
				
						updateQueWall(_H_Que_Trigger+1650)
					elseif option == 2 then

						wallBoulder(586,_H_Que_Trigger+150)
						wallBarbedWire(336,_H_Que_Trigger+300,0,1)
						wallBoulder(1036,_H_Que_Trigger+400)
						
						wallLandmine(536,_H_Que_Trigger+600,1800)
						wallBoulder(136,_H_Que_Trigger+800)
						wallBarbedWire(1336,_H_Que_Trigger+850,0,1)
						wallGate(786,_H_Que_Trigger+900)

						wallLandmine(1236,_H_Que_Trigger+1050,4500)
						wallBoulder( 486, _H_Que_Trigger+1150)
						wallTallTree(836,_H_Que_Trigger+1150)
						wallBoulder( 336, _H_Que_Trigger+1350)
						wallBoulder(936,_H_Que_Trigger+1450)
				
						updateQueWall(_H_Que_Trigger+1650)
					end
				elseif nextSet == 6 then
					open = "either"
					updateQueWall(_H_Que_Trigger+500)
					
				end
				
							
			end

			lastSet = nextSet
	end

	function sendNext()

		--if configGame.state == "play" then
		local Environment_Set_Start
		local Environment_Set_End

		--Stops two sets from occuring in a row
		for i = 1,#regionTable do

			if configGame.region == regionTable[i].environment then
				Environment_Set_Start = regionTable[i].first
				Environment_Set_End = regionTable[i].last
			end
		end


		if configGame.tutorial == true
		and configGame.region == "tutorial"
		and configGame.state == "ready" then

			startTutorial()
		
		else

			if lastSet == nextSet then
				while lastSet == nextSet do
					nextSet =  math.random(Environment_Set_Start,Environment_Set_End)
				end
			end

			wallSets()
		end
	end



	--
	function delayFunction(event)
		
		tempParams = event.source.params
		tempFunction = tempParams.tempFunction

		if tempFunction == "recycle" then
			recycle(tempParams.tempObject, tempParams.tempTable, tempParams.tempPosition)
		end
	end

	function recycle(tempObject, tempTable, tempPosition)

		--Get Position if object and table are provided
		if tempObject ~= nil
		and tempTable ~= nil
		and tempPosition == nil then
			tempPosition = table.indexOf( tempTable, tempObject )
		end	
		--decals

		if tempObject.type == "windmill" then
			display.remove( tempObject.decal )
			
		elseif tempObject.type == "gate" then
			display.remove( tempObject.flags )
			display.remove( tempObject.leftRope )
			display.remove( tempObject.rightRope )
			display.remove( tempObject.leftGate )
			display.remove( tempObject.rightGate )
		
		elseif tempObject.type == "house" then
			display.remove( tempObject.smoke )

		elseif tempObject.type == "bounce" then
			display.remove( tempObject.core )
			display.remove( tempObject.front )
			
		elseif tempObject.type == "normal" then
			display.remove( tempObject.decal )
			
		elseif tempObject.type == "fenceHole" then
			display.remove( tempObject.post_1 )
			display.remove( tempObject.post_2 )
			
		elseif tempObject.type == "road" then
			if tempObject.mound ~= nil then
				display.remove( tempObject.mound )
			end
			for i = 1,#tempObject.plow do
				display.remove( tempObject.plow[i] )
			end

			local index = table.indexOf( snowPlowTable, tempObject)
			table.remove( snowPlowTable, index )	
			timer.cancel( tempObject.timerHandle )

		elseif tempObject.type == "jump" then
			display.remove( tempObject.mound )
			if tempObject.decal ~= nil then
				display.remove( tempObject.decal )
			end

		elseif tempObject.type == "chopper" then
			display.remove( tempObject.shieldImage )
			display.remove( tempObject.smoke )
			display.remove( tempObject.indicator )

		elseif tempObject.type == "fighter" then
			display.remove( tempObject.shieldImage )
			display.remove( tempObject.smoke )
			display.remove( tempObject.indicator )

		elseif tempObject.type == "pond"
		and tempObject.decal ~= nil then
			if tempObject.decal.transitionHandle ~= nil then
				transition.cancel( tempObject.decal.transitionHandle )
			end
			display.remove(tempObject.decal)

		elseif tempObject.type == "explosion" then
			display.remove(tempObject.removeRadius)
		end

		
		
		if tempObject.timerHandle ~= nil then -- CANCEL TIMER -- will need to be removed
			timer.cancel( tempObject.timerHandle )
		end

		if tempObject.timerHandle2 ~= nil then
			timer.cancel( tempObject.timerHandle2 )
		end

		if tempTable ~= nil and tempPosition ~= nil then -- REMOVE FROM TABLE
			table.remove( tempTable, tempPosition)
		end
		
		display.remove(tempObject) -- REMOVE IMAGE
		tempObject = nil --JUST FOR GOOD MEASURE
	end

	function removeWall()
		
		for i = #wallTable,1,-1 do
			if wallTable[i].y < -1000 then -- CHANGE THIS NUMBER
				local index = table.indexOf( wallTable, wallTable[i] )
				recycle( wallTable[i], wallTable, index )
			end
		end
	end
--


function onEveryFrame( event )

	if configGame.state == "play" then

		if gameBall.hitSnowBall ~= nil then
			gameBall.x = gameBall.hitSnowBall.x
			gameBall.y = gameBall.hitSnowBall.y
		end

		if configGame.openGatesFaster == true then
			openGatesFaster()
		end

		for i = 1,#fighterTable do
			animate(fighterTable[i])
			approachFighter(fighterTable[i])
			updateIndicator(fighterTable[i])
		end
		
		for i = 1,#chopperTable do
			animate(chopperTable[i])
			approachChopper(chopperTable[i])
			updateIndicator(chopperTable[i])
		end
		
		for i = 1,#missleTable do
			animate(missleTable[i])
			approachFighter(missleTable[i])
		end
		
		for i = 1, #effectsTable do
			if effectsTable[i].type == "humvee" then
				animationHumvee(effectsTable[i])
				approachFighter(effectsTable[i])
			end
		end

		--SPRAY
		for i = 1,#wallTable do
			if wallTable[i].type == "machine"
			and wallTable[i].inRange == true then
				sprayEffect(wallTable[i])
			end
		end
	end

	
	--decals
	--TO FRONT
	for i = 1,#fighterTable do
		positionShield( fighterTable[i] )
		if fighterTable[i].smoke ~= nil then
			fighterTable[i].smoke.x = fighterTable[i].x
			fighterTable[i].smoke.y = fighterTable[i].y
		end
	end

	for i = 1,#chopperTable do
		positionShield(chopperTable[i])
		if chopperTable[i].smoke ~= nil then
			chopperTable[i].smoke.x = chopperTable[i].x
			chopperTable[i].smoke.y = chopperTable[i].y
		end
	end
	
	if configGame.state == "ready" then

		local vx
		local vy
		local velocity

		vx,vy = gameBall:getLinearVelocity()
		vy = vy + configGame.wallSpeed
		velocity = math.sqrt(vx^2 +vy^2)	
	
		animationRotation( vx, vy, velocity )
		animateGameBallDecals()

	elseif configGame.state == "play"
	and gameBall ~= nil then

		local vx
		local vy
		local velocity

		vx,vy = gameBall:getLinearVelocity()
		vy = vy + configGame.wallSpeed
		velocity = math.sqrt(vx^2 +vy^2)	
	
		jetPack( vx, vy, velocity )
		animationRotation( vx, vy, velocity )
		animateGameBallDecals()
		
		drawOnPlane()
		drawWithoutMoving()
		--fallingOffBridge()
	elseif
		configGame.state == "paused" then
		gameBall.x = gameBall.xPaused
		gameBall.y = gameBall.yPaused
	end


	positionBackground()
	reorderWalls()

	if queWall ~= nil then

		if configGame.tutorial == true
		and configGame.region == "City"
		and configGame.state == "play" then
			configGame.tutorial = "City Tutorial"
		end

		if configGame.tutorial == true
		and configGame.region == "Military Camp"
		and configGame.state == "play" then
			configGame.tutorial = "Military Camp Tutorial"
		end

		if queWall.y < _H_Que_Trigger then
			sendNext()
		end
	end
end








---------------------------------------------------------------------------------

function scene:create( event )

	--print("--==| CREATED SCENE GAME |==--")
	local sceneGroup = self.view

	scene.view:insert(gfenceMask)
	scene.view:insert(gbackground1)
	scene.view:insert(gbackground2)
	scene.view:insert(gbackground3)
	scene.view:insert(gground1)
	scene.view:insert(gground2)
	scene.view:insert(gground3)
	scene.view:insert(gsky1)
	scene.view:insert(gsky2)
	scene.view:insert(gsky3)
	scene.view:insert(gforeground1)
	scene.view:insert(gforeground2)
	scene.view:insert(gforeground3)

	loadGameTexturesToMemory()
	setupGame()

	local options = {
		params = {
			gotoGame = true
		}
	}
	composer.gotoScene("loadGame",options)

	--[[
	local function showGame()
		local options = {
			params = {
				start = nil
			}
		}
		composer.gotoScene("game",options)
	end
	timer.performWithDelay(1,showGame)
	--]]
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

		if event.params.startGame == true then
			prepareGame()
		end

	elseif ( phase == "did" ) then

		--print("--==| SHOW SCENE GAME |==--")

		if event.params.startGame == false then
			local options = {
				isModal = true,
				effect = "fade",
				time = 500
			}
			composer.showOverlay( "mainMenu",options )
		end

	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

		local event = {}
		event["phase"] = "ended"
		pauseGame(event)

		removeEverything()
		configGame.state = "mainMenu"
		physics.start()

	elseif ( phase == "did" ) then

		--print("--==| HIDE SCENE GAME |==--")
	end
end

function scene:destroy( event )

	--print("--==| DESTROYED SCENE GAME |==--")
	local sceneGroup = self.view
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene