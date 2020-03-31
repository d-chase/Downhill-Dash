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

	local gbackground = display.newGroup()
	local gforeground = display.newGroup()

	local sizeSmall_W = 550
	local sizeSmall_H = 150

	local pauseMenu
	local confirmText
	local btn_NO
	local btn_YES
	local btn_MainMenu
	local btn_Restart
	local btn_Resume
	
	local _font = "HelveticaNeue-Light"
	local _fontSize = 60

---------------------------------------------------------------------------------
--| GLOBAL VARIABLES |--
	--configGame.state

---------------------------------------------------------------------------------
--| GLOBAL FUNCTIONS |--
	--pauseGame(event) -- Game File
	--removeEverything() -- Game File
	--prepareGame() -- Game File

---------------------------------------------------------------------------------
--| FUNCTIONS |--

local function destroyScene2()

	display.remove( pauseMenu ); pauseMenu = nil
	display.remove( confirmText ); confirmText = nil
	display.remove( btn_NO ); btn_NO = nil
	display.remove( btn_YES ); btn_YES = nil
	display.remove( btn_MainMenu ); btn_MainMenu = nil
	display.remove( btn_Restart ); btn_Restart = nil
	display.remove( btn_Resume ); btn_Resume = nil

	whereToGo = nil
end

local function confirm(event)
	confirmText.isVisible = true

	btn_MainMenu.isVisible = false
	btn_Restart.isVisible = false
	btn_Resume.isVisible = false
	btn_NO.isVisible = true
	btn_YES.isVisible = true
end

local function back(event)
	confirmText.isVisible = false

	btn_MainMenu.isVisible = true
	btn_Restart.isVisible = true
	btn_Resume.isVisible = true
	btn_NO.isVisible = false
	btn_YES.isVisible = false

	whereToGo = nil
end

local function go_MainMenu(event)

	--print("GO TO MAIN MENU")
	pauseGame(event)
	removeEverything()
	configGame.state = "mainMenu"

	composer.hideOverlay( "flip", 125 )
	local options = {
		isModal = true,
		effect = "fade",
		time = 250
	}
	composer.showOverlay("mainMenu",options)
end

local function go_restart(event) --MAKE SURE THIS IS THE SAME AS SCORE.LUA
	--print("RESTART")
	pauseGame(event)
	removeEverything()
	prepareGame()
	composer.hideOverlay( "flip",125 )
end

local function go_resume(event)
	--print("RESUME")
	pauseGame(event)
	composer.hideOverlay( "flip",125 )
end

local function createButtons()

	whereToGo = nil

	pauseMenu = display.newImage("images/mainMenu/rateMenu.png")
	pauseMenu.x = _W/2
	pauseMenu.y = _H/2
	pauseMenu.xScale = 1.75
	pauseMenu.yScale = 1.5


	local options = 
		{
		    --parent = textGroup,
		    text = "FILL TEXT",     
		    x = pauseMenu.x,
		    y = pauseMenu.y - 200,
		    width = 460,
		    height = 0,     --required for multi-line and alignment
		    font = _font,   
		    fontSize = _fontSize,
		    align = "center"  --new alignment parameter
		}
	confirmText = display.newText( options )
	confirmText:setFillColor(1,1,1)
	confirmText.anchorY = 0
	confirmText.isVisible = false


	btn_MainMenu =  require("widget").newButton
	{
		--left = pauseMenu.x,
		--top = pauseMenu.y - 125,
		defaultFile = "images/mainMenu/button_MainMenu.png",
		--font = "Helvetica",
		--fontSize = 35,
		--label = "Main Menu",
		width = sizeSmall_W,
		height = sizeSmall_H,
		--cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				confirmText.text = "Go to Main Menu?"
				whereToGo = "mainMenu"
				confirm(event)
			end
		end
	}
	--btn_MainMenu.anchorX = 1
	--btn_MainMenu.anchorY = 1
	btn_MainMenu.x = _W/2
	btn_MainMenu.y = _H/2 - sizeSmall_H*5/4


	btn_Restart =  require("widget").newButton
	{
		--left = pauseMenu.x,
		--top = pauseMenu.y,
		defaultFile = "images/mainMenu/button_Restart.png",
		--font = "Helvetica",
		--fontSize = 35,
		--label = "Restart",
		width = sizeSmall_W,
		height = sizeSmall_H,
		--cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				confirmText.text = "Restart Game?"
				whereToGo = "restart"
				confirm(event)
			end
		end
	}
	--btn_Restart.anchorX = 1
	--btn_Restart.anchorY = 1
	btn_Restart.x = _W/2
	btn_Restart.y = _H/2

	btn_Resume =  require("widget").newButton
	{
		--left = pauseMenu.x,
		--top = pauseMenu.y + 125,
		defaultFile = "images/mainMenu/button_Resume.png",
		--font = "Helvetica",
		--fontSize = 35,
		--label = "Resume",
		width = sizeSmall_W,
		height = sizeSmall_H,
		--cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				confirmText.text = "Resume Game?"
				whereToGo = "resume"
				confirm(event)
			end
		end
	}
	btn_Resume.x = _W/2
	btn_Resume.y = _H/2 + sizeSmall_H*5/4


	btn_NO =  require("widget").newButton
	{
		left = pauseMenu.x - 150,
		top = pauseMenu.y + 125,
		defaultFile = "images/mainMenu/button_No.png",
		--font = "Helvetica",
		--fontSize = 35,
		--label = "No",
		width = sizeSmall_W/2,
		height = sizeSmall_H,
		--cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				back(event)
			end
		end
	}
	btn_NO.anchorX = 1
	btn_NO.isVisible = false


	btn_YES =  require("widget").newButton
	{
		left = pauseMenu.x + 150,
		top = pauseMenu.y + 125,
		defaultFile = "images/mainMenu/button_Yes.png",
		--font = "Helvetica",
		--fontSize = 35,
		--label = "Yes",
		width = sizeSmall_W/2,
		height = sizeSmall_H,
		--cornerRadius = 4,

		onEvent = function(event) 
			if "ended" == event.phase then
				if whereToGo == "mainMenu" then
					go_MainMenu(event)
				elseif whereToGo == "restart" then
					go_restart(event)
				elseif whereToGo == "resume" then
					go_resume(event)
				end
			end
		end
	}
	btn_YES.anchorX = 1
	btn_YES.isVisible = false




	
	gbackground:insert(pauseMenu)
	gforeground:insert(confirmText)
	gforeground:insert(btn_NO)
	gforeground:insert(btn_YES)
	gforeground:insert(btn_MainMenu)
	gforeground:insert(btn_Restart)
	gforeground:insert(btn_Resume)
end

---------------------------------------------------------------------------------

function scene:create( event )

	--print("--==| CREATED SCENE mainMenu|==--")
	local sceneGroup = self.view

	scene.view:insert( gbackground )
	scene.view:insert( gforeground )

	createButtons()
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		--print("--==| SHOW SCENE mainMenu|==--")
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		--print("--==| HIDE SCENE mainMenu|==--")
	end
end

function scene:destroy( event )

	--print("--==| DESTROYED SCENE mainMenu|==--")
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