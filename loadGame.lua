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
    
	local title
	local loadingImageSky
    local loadingImageMtn
    local blackBox
    local loadingImage
    local tipBanner
    local tipImage

---------------------------------------------------------------------------------
--| GLOBAL VARIABLES |--

    --FURTHEST_STAGE
    --CURRENT_STAGE

---------------------------------------------------------------------------------
--| REQUIRE |--
    require("sqlite3") 
    local dbfunctions = require("dbfunctions")
    dbfunctions.init("dbGear.db")

---------------------------------------------------------------------------------
--| FUNCTIONS |--

local function destroyScene()
    display.remove(title); title = nil
    display.remove(loadingImageSky); loadingImageSky = nil
    display.remove(loadingImageMtn); loadingImageMtn = nil
    display.remove(blackBox); blackBox = nil

    display.remove(loadingImage); loadingImage = nil
    display.remove(tipBanner); tipBanner = nil
    display.remove(tipImage); tipImage = nil
end

local function createBackground()

    --loadingImageSky = display.newImage("images/mainMenu/CC_Sky.png")
    loadingImageSky = display.newImageRect("images/mainMenu/CC_Sky.png",_W,_H_Real)
    loadingImageSky.x = _W/2
    loadingImageSky.y = _H_Real/2
    --loadingImageSky.xScale = 2 --Unknown Error Should be 1
    --loadingImageSky.yScale = 2*(_H_Real/_H) --Unknown Error Should be 1
    loadingImageSky.type = "background"
    --gbackground1:insert( loadingImageSky )
    scene.view:insert(loadingImageSky)

    --loadingImageMtn = display.newImage("images/mainMenu/loadScreen.png")
    loadingImageMtn = display.newImageRect("images/mainMenu/loadScreen.png",_W,_H)
    loadingImageMtn.x = _W/2
    loadingImageMtn.y = _H_Real - _H/2
    loadingImageMtn.xScale = 1 --Unknown Error Should be 1
    loadingImageMtn.yScale = 1 --Unknown Error Should be 1
    loadingImageMtn.type = "background"
    --gbackground1:insert( loadingImageMtn )
    scene.view:insert(loadingImageMtn)
    
    title = display.newImage("images/mainMenu/downHillDash.png")
    title.x = _W/2
    title.y = 300
    title.xScale = 1.25
    title.yScale = 1.25
    scene.view:insert(title)

    --TIP
    local randomTip = dbfunctions.getTableValue("generalSettings", "tip", "value")--math.random(1,8)
    randomTip = tonumber(randomTip)
    if randomTip == nil then
    	randomTip = 1
    end
    
    if randomTip < 8 then
    	dbfunctions.updateTableValue("generalSettings", "tip", "value", randomTip + 1)
    else
    	dbfunctions.updateTableValue("generalSettings", "tip", "value",  1)
    end
    
    tipBanner = display.newRect(999, 999, _W, 200)
    tipBanner.anchorY = 1
    tipBanner.x = _W/2
    tipBanner.y = _H_Real
    tipBanner:setFillColor(0,0,0)
    tipBanner.alpha = 0.75

    if randomTip == 1 then
        tipImage = display.newImageRect("images/tips/Tip1.png",1536,200)
    elseif randomTip == 2 then
        tipImage = display.newImageRect("images/tips/Tip2.png",1536,200)
    elseif randomTip == 3 then
        tipImage = display.newImageRect("images/tips/Tip3.png",1536,200)
    elseif randomTip == 4 then
        tipImage = display.newImageRect("images/tips/Tip4.png",1536,200)
    elseif randomTip == 5 then
        tipImage = display.newImageRect("images/tips/Tip5.png",1536,200)
    elseif randomTip == 6 then
        tipImage = display.newImageRect("images/tips/Tip6.png",1536,200)
    elseif randomTip == 7 then
        tipImage = display.newImageRect("images/tips/Tip7.png",1536,200)
    else
        tipImage = display.newImageRect("images/tips/Tip8.png",1536,200)
    end
    tipImage.anchorY = 1
    tipImage.x = _W/2
    tipImage.y = _H_Real
    --tipImage.xScale = 1.5
    --tipImage.yScale = 1.5
    
    loadingImage = display.newImage("images/mainMenu/loading.png")
    loadingImage.x = _W/2 + 50
    loadingImage.y = _H_Real - 275
    
	scene.view:insert(loadingImage)
    scene.view:insert(tipBanner)
    scene.view:insert(tipImage)

    
end

local function transitionBlackComplete()

    --print("GO TO GAME")

    loadingImageSky.isVisible = false
    loadingImageMtn.isVisible = false

    local options = {
        params = {
            startGame = false
        }
    }
    composer.gotoScene( "game",options )
end

local function transitionBlack()

    blackBox = display.newRect(_W/2,_H_Real/2,_W,_H_Real)
    blackBox:setFillColor(0,0,0)
    blackBox.alpha = 0
    transition.to(blackBox, 
        {alpha = 1, time = 500, onComplete = transitionBlackComplete})
    scene.view:insert(blackBox)
end



---------------------------------------------------------------------------------

function scene:create( event )

    local sceneGroup = self.view
    --print("--==| CREATE SCENE ????? |==--")

    createBackground()
end

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then

        --print("--==| SHOW SCENE ????? |==--")

        if event.params.gotoGame == false then

            local function getCurrentStage()

                if CURRENT_STAGE == nil then
                    FURTHEST_STAGE = dbfunctions.getTableValue("generalSettings", "furthestStage", "value")
                    CURRENT_STAGE = FURTHEST_STAGE
                    --print("getCurrentStage")
                end
            end
            getCurrentStage()

            local function loadGame()
                composer.loadScene("game")
            end
            timer.performWithDelay(1,loadGame)

        elseif event.params.gotoGame == true then

           transitionBlack()
        end
    end
end

function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then

        --print("--==| HIDE SCENE ????? |==--")

    end
end

function scene:destroy( event )

    local sceneGroup = self.view
    --print("--==| DESTROY SCENE ????? |==--")
    destroyScene()
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene