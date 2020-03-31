
--Keep Playing Sound
	if audio.supportsSessionProperty == true then
	    --print("\n\naudio.supportsSessionProperty == true\n\n")
	    audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
	end
	


--------------------------------------------------------------------
--==|Download File From Server|==--

	---------------------------------------------------------------------------------
	--| NOTES |--

	--Format
	--IMPORTANT_DATA,key,value,serverCode,
	--Example
	--IMPORTANT_DATA,coins,50,pushNote1,

	--ADD TO dbfunctions.lua
	--settingsToAdd = [[INSERT INTO generalSettings values(NULL,'serverCode','');]]
	--db:exec( settingsToAdd );

	---------------------------------------------------------------------------------
	--| VARIABLES |--
	--Old file from my google drive
	--local url = "https://docs.google.com/document/d/1fipO_7RaQJBsM-7nkmNxX7HEbtfIRp4DvCbjuL-zJ4s/edit?usp=sharing"
	local url = "https://drive.google.com/open?id=1q-fWzuwf5DQxoE6VU6CkMLMfOfx0KTA754R5fz9lyz8"
	local fileName = "serverFile.txt"
	local path = system.pathForFile( fileName, system.TemporaryDirectory )
	--system.openURL(url)

	---------------------------------------------------------------------------------
	--| REQUIRE |--
	require("sqlite3")
	local dbfunctions = require("dbfunctions")
	dbfunctions.init("dbGear.db")

	---------------------------------------------------------------------------------
	--| CODE |--

	os.remove(path)

	local function networkListener()

		-- Open the file handle
		local file, errorString = io.open( path, "r" )

		if not file then
			-- Error occurred; output the cause
			--print( "File error: " .. errorString )
		else
			-- Output lines
		   
			for s_textLine in file:lines() do
				--print( s_textLine )
				local startIndex
				local endIndex
				startIndex, endIndex = string.find(s_textLine, "IMPORTANT_DATA")

				local comma1 = string.find(s_textLine, ",", endIndex+1)
				local comma2 = string.find(s_textLine, ",", comma1+1)
				local comma3 = string.find(s_textLine, ",", comma2+1)
				local comma4 = string.find(s_textLine, ",", comma3+1)

				local key = string.sub(s_textLine, comma1+1, comma2-1)
				local value =  string.sub(s_textLine, comma2+1, comma3-1)
				local value = tonumber(value)
				local serverCode = string.sub(s_textLine, comma3+1, comma4-1)

				local lastServerCode = dbfunctions.getTableValue("generalSettings", "serverCode", "value")
				
				if type(key) == "string"
				and type(value) == "number"
				and type(serverCode) == "string" then
				
					if lastServerCode == "NOTSET"
					or serverCode ~= lastServerCode then

						FREE_COINS = value -- GLOBAL VARIABLE

						if key == "coins" then
							local coinsCurrent = dbfunctions.getTableValue("generalSettings", "coins", "value")
							local coinsTotal = coinsCurrent + FREE_COINS
							--print(coinsTotal)
							dbfunctions.updateTableValue("generalSettings", "coins", "value", coinsTotal)
						end

						dbfunctions.updateTableValue("generalSettings", "serverCode", "value", serverCode)
					end
				end

				break --stops loop from going to next line
			end
			-- Close the file handle
			io.close( file )
		end
	end

	network.download( 
		url, 
		"GET", 
		networkListener, 
		fileName, 
		system.TemporaryDirectory
	)

--------------------------------------------------------------------
--==| OneSignal |==--

	-- This function gets called when the user opens a notification or one is received when the app is open and active.
	-- Change the code below to fit your app's needs.
	function DidReceiveRemoteNotification(message, additionalData, isActive)
		if (additionalData) then
		
   			--for key,value in pairs(additionalData) do
      			--if key == "coins" then
      				--local myCoins = dbfunctions.getTableValue("generalSettings", "coins", "value")
      				--myCoins = tonumber(myCoins)
      				--myCoins = myCoins + tonumber( value )
      				--dbfunctions.updateTableValue("generalSettings", "coins", "value", myCoins)
   				--end
   			--end
			
			if (additionalData.discount) then
				native.showAlert( "Discount!", message, { "OK" } )
				-- Take user to your app store
			elseif (additionalData.actionSelected) then -- Interactive notification button pressed
				native.showAlert("Button Pressed!", "ButtonID:" .. additionalData.actionSelected, { "OK"} )
			end
		else
			native.showAlert("OneSignal Message", message, { "OK" } )
		end
	end

	OneSignal = require("plugin.OneSignal")
	-- Uncomment SetLogLevel to debug issues.
	-- OneSignal.SetLogLevel(4, 4)
	OneSignal.Init("f5c064f8-5dae-4b93-a3c4-439fa651d9c3", "############", DidReceiveRemoteNotification)

--------------------------------------------------------------------
--==|Game Center|==--

	local gameNetwork = require( "gameNetwork" )

	-- Game Center request listener function
	local function requestCallback( event )

		if ( event.data ) then

			-- Event type of "loadLocalPlayer"
			if ( event.type == "loadLocalPlayer" ) then
		
			-- Event type of "loadLeaderboardCategories"
			elseif ( event.type == "loadLeaderboardCategories" ) then
			
			end
		end
	end

	-- Game Center initialization listener function
	local function initCallback( event )

		if initializedGC == false then

			if ( event.data ) then

				-- Set initialized flag as true
				initializedGC = true

				-- Request local player information
				gameNetwork.request( "loadLocalPlayer", { listener=requestCallback } )

				-- Load leaderboard categories
				gameNetwork.request( "loadLeaderboardCategories", { listener=requestCallback } )

				-- Load achievement descriptions
				--gameNetwork.request( "loadAchievementDescriptions", { listener=requestCallback } )
				
				-- Load player achievements
				--gameNetwork.request( "loadAchievements", { listener=requestCallback } )
				native.showAlert( "Success", "Cannot initialize Game Center.", { "OK" } )
			else
				-- Display alert that Game Center cannot be initialized
				native.showAlert( "Error", "Cannot initialize Game Center.", { "OK" } )
			end
		end
	end

	-- Initialize Game Center if platform is an iOS device
	if ( system.getInfo( "platformName" ) == "iPhone OS" ) then
		gameNetwork.init( "gamecenter", initCallback )
	else
		--native.showAlert( "Not Supported", "Apple Game Center is not supported on this platform. Please build and deploy to an iOS device.", { "OK" } )
	end

--------------------------------------------------------------------
--==|AdMob|==--

--------------------------------------------------------------------
--==|Everything Else|==--

local composer = require( "composer" )
display.setStatusBar(display.HiddenStatusBar)


--| GLOBAL REQUIRE |--
analytics = require( "analytics" )
analytics.init("S52RN5ZNSBDH26MY9ZWK")

local options = {
	isModal = true,
	effect = "fade",
	time = 500,
	params = {
		gotoGame = false
	}
}
composer.gotoScene("loadGame",options)
--------------------------------------------------------------------