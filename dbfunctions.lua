--MODULE


local M = {}


---------------------------------------------------------------------------------
--| Create The DataBase File |--

--Step 1 - Create Database File
local function init(dbName)
	path = system.pathForFile(dbName, system.DocumentsDirectory)
	db = sqlite3.open( path )
	M.generateTables()
	M.populateData()
	return "done"
end
M.init = init

--Step 2 - Create Database Tables
local function generateTables()
	local table1,table2,table3, table4, table5

	
	local table1 = [[CREATE TABLE IF NOT EXISTS generalSettings (keyID INTEGER PRIMARY KEY AUTOINCREMENT,
						setting VARCHAR(20) not null,
						value VARCHAR(20) not null)
					;]]    
	db:exec( table1 ) 

	local table2 = [[CREATE TABLE IF NOT EXISTS hatTable (keyID INTEGER PRIMARY KEY AUTOINCREMENT,
						gearName VARCHAR(20) not null,
						image VARCHAR(20) not null,
						imageGame VARCHAR(20) not null,
						cost VARCHAR(20) not null,
						selected VARCHAR(20) not null,
						unlocked VARCHAR(20) not null)
					;]]    
	db:exec( table2 ) 
	
	local table3 = [[CREATE TABLE IF NOT EXISTS jacketTable (keyID INTEGER PRIMARY KEY AUTOINCREMENT,
						gearName VARCHAR(20) not null,
						image VARCHAR(20) not null,
						imageGame VARCHAR(20) not null,
						cost VARCHAR(20) not null,
						selected VARCHAR(20) not null,
						unlocked VARCHAR(20) not null)
					;]]		
	db:exec( table3 ) 
	
	local table4 = [[CREATE TABLE IF NOT EXISTS pantsTable (keyID INTEGER PRIMARY KEY AUTOINCREMENT,
						gearName VARCHAR(20) not null,
						image VARCHAR(20) not null,
						imageGame VARCHAR(20) not null,
						cost VARCHAR(20) not null,
						selected VARCHAR(20) not null,
						unlocked VARCHAR(20) not null)
					;]]			
	db:exec( table4 )
	
	local table5 = [[CREATE TABLE IF NOT EXISTS sledTable (keyID INTEGER PRIMARY KEY AUTOINCREMENT,
						gearName VARCHAR(20) not null,
						image VARCHAR(20) not null,
						imageGame VARCHAR(20) not null,
						cost VARCHAR(20) not null,
						selected VARCHAR(20) not null,
						unlocked VARCHAR(20) not null)
					;]]   
	db:exec( table5 )     
end
M.generateTables = generateTables

--Step 3 - Load Data into table  if you need to pre-populate the data
local function populateData()
	local numRows = M.numberOfRows("jacketTable")
	if numRows < 4 then

		--Insert Data In generalSettings
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'tip','1');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'bannerAds','off');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'music','on');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'sound','on');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'serverCode','');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'rate','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'rateStart','0');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'score','0');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'coins','0');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'furthestStage','tutorial');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'completedCityTutorial','0');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO generalSettings values(NULL,'completedMilitaryCampTutorial','0');]]
		db:exec( settingsToAdd );

		--print("Hats")

		--Insert Data In hatTable
		settingsToAdd = [[INSERT INTO hatTable values(NULL,'White','Hat_White_Custom.png','Hat_White_Game.png','1','yes','yes');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO hatTable values(NULL,'Blue','Hat_Blue_Custom.png','Hat_Blue_Game.png','1000','no','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO hatTable values(NULL,'Red','Hat_Red_Custom.png','Hat_Red_Game.png','2000','no','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO hatTable values(NULL,'Gold','Hat_Gold_Custom.png','Hat_Gold_Game.png','6000','no','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO hatTable values(NULL,'Black','Hat_Black_Custom.png','Hat_Black_Game.png','10000','no','no');]]
		db:exec( settingsToAdd );
		
		--print("Jackets")

		--Insert Data In jacketTable
		settingsToAdd = [[INSERT INTO jacketTable values(NULL,'Classic','Jacket_Classic_Custom.png','Jacket_Classic_Game.png','1','yes','yes');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO jacketTable values(NULL,'Pixel','Jacket_Pixel_Custom.png','Jacket_Pixel_Game.png','10000','no','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO jacketTable values(NULL,'Camo','Jacket_Camo_Custom.png','Jacket_Camo_Game.png','20000','no','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO jacketTable values(NULL,'Razor','Jacket_Razor_Custom.png','Jacket_Razor_Game.png','60000','no','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO jacketTable values(NULL,'Eclipse','Jacket_Eclipse_Custom.png','Jacket_Eclipse_Game.png','100000','no','no');]]
		db:exec( settingsToAdd );
		
		--Insert Data In pantsTable
		settingsToAdd = [[INSERT INTO pantsTable values(NULL,'Gold','Pants_Gold_Custom.png','Pants_Gold_Game.png','1','yes','yes');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO pantsTable values(NULL,'Red','Pants_Red_Custom.png','Pants_Red_Game.png','10000','no','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO pantsTable values(NULL,'Green','Pants_Green_Custom.png','Pants_Green_Game.png','10000','no','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO pantsTable values(NULL,'Black','Pants_Black_Custom.png','Pants_Black_Game.png','10000','no','no');]]
		db:exec( settingsToAdd );
	
		--Insert Data In sledTable
		settingsToAdd = [[INSERT INTO sledTable values(NULL,'oldFaithful','Sled_OldFaithful_MainMenu.png','Sled_OldFaithful_Game.png','1','yes','yes');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO sledTable values(NULL,'leadSled','Sled_Lead_MainMenu.png','Sled_Lead_Game.png','50000','no','no');]]
		db:exec( settingsToAdd );
		settingsToAdd = [[INSERT INTO sledTable values(NULL,'turbo','Sled_Turbo_MainMenu.png','Sled_Turbo_Game.png','100000','no','no');]]
		db:exec( settingsToAdd );
	end
end
M.populateData = populateData

--Step 4 - Check for how many rows of data are in your table this is called from step 3 below
local function numberOfRows(tableToCheck)
	--print ("Checking Table:",tableToCheck)
	local count = 0
	for row in db:nrows("SELECT count(*) as c FROM "..tableToCheck) do
		count = row.c
	end
	--print("Rows in table:",tableToCheck,count)
	return count
end
M.numberOfRows = numberOfRows

---------------------------------------------------------------------------------
--| Access / update the data in the database |--

local function getSelectedImage(tempTable, tempValue)

	local dataRow = {}
	--print(tempTable)
	if tempTable == "hatTable" then
		defaultValue1 = [[SELECT * FROM hatTable WHERE selected='yes' ;]]
	elseif tempTable == "jacketTable" then
		defaultValue1 = [[SELECT * FROM jacketTable WHERE selected='yes' ;]]
	elseif tempTable == "pantsTable" then
		defaultValue1 = [[SELECT * FROM pantsTable WHERE selected='yes' ;]]
	elseif tempTable == "sledTable" then
		defaultValue1 = [[SELECT * FROM sledTable WHERE selected='yes' ;]]
	end
	
	dataRow = db:exec(defaultValue1)
	
	for tempRow in db:nrows(defaultValue1) do
		dataRow = tempRow -- Save everything to an array to get out of this "for/do" loop
	end   
	--print("WHAT I GOT",dataRow)
	--print("Settings",dataRow['selected'],dataRow['unlocked'])

	if dataRow == 0 then 
		return "NOTSET"
	else return
		--dataRow['image']
		--temp = [[']]..tempValue..[[']]
		dataRow[ tempValue ]
	end
end
M.getSelectedImage = getSelectedImage

local function getTableValue(tempTable, tempKeyID, tempValue)

	local dataRow = {}
	--print(tempTable)
	if tempTable == "generalSettings" then
		defaultValue1 = [[SELECT * FROM generalSettings WHERE setting=']]..tempKeyID..[[' ;]]
	elseif tempTable == "hatTable" then
		defaultValue1 = [[SELECT * FROM hatTable WHERE keyID=']]..tempKeyID..[[' ;]]
	elseif tempTable == "jacketTable" then
		defaultValue1 = [[SELECT * FROM jacketTable WHERE keyID=']]..tempKeyID..[[' ;]]
	elseif tempTable == "pantsTable" then
		defaultValue1 = [[SELECT * FROM pantsTable WHERE keyID=']]..tempKeyID..[[' ;]]
	elseif tempTable == "sledTable" then
		defaultValue1 = [[SELECT * FROM sledTable WHERE keyID=']]..tempKeyID..[[' ;]]
	end
	
	dataRow = db:exec(defaultValue1)
	
	for tempRow in db:nrows(defaultValue1) do
		dataRow = tempRow -- Save everything to an array to get out of this "for/do" loop
	end   

	--print(tempValue)
	--print(dataRow[tempValue])
	
	if dataRow == 0 then 
		return "NOTSET"
	else
		return dataRow[tempValue]
	end
end
M.getTableValue = getTableValue

local function updateTableValue(tempTable, tempKeyID, tempParam, tempValue)

	if tempTable == "generalSettings" then
		--print("UPDATE RATE")
		--print(tempTable)
		--print(tempKeyID)
		--print(tempParam)
		--print(tempValue)
		--Change General Settings
		local rowUpdate  = [[UPDATE ]]..tempTable..[[ SET ]]..tempParam..[[ = ']]..
							tempValue..[[' WHERE setting=']]..tempKeyID..[[';]]

		--print (rowUpdate)
		message = db:exec(rowUpdate);     
		--print ("Message",message)

	else
		--All Other Tables
		--print("Update database Setting Value")
		local rowUpdate  = [[UPDATE ]]..tempTable..[[ SET ]]..tempParam..[[ = ']]..
							tempValue..[[' WHERE keyID=']]..tempKeyID..[[';]]
		
		--local rowUpdate  = [[UPDATE settings SET settingvalue = ']]..tempValue..[[' WHERE settingname=']]..tempName ..[[';]]
		--print (rowUpdate)
		message = db:exec(rowUpdate);     
		--print ("Message",message)

		
	end
end
M.updateTableValue = updateTableValue



---------------------------------------------------------------------------------
--| Encode / decode table |--

local function encodeValue(tempTable, tempKeyID, tempValue)
	
	if tempValue == "yes" then
		encodedValue = (258-43*tempKeyID)*tempKeyID*(-1)^(tempKeyID)
		updateTableValue(tempTable, tempKeyID, "unlocked", encodedValue)
		--print("encodedValue")
		--print(encodedValue)
	end
end
M.encodeValue = encodeValue

local function decodeValue(tempTable, tempKeyID, tempValue)
	
	encodedValue = (258-43*tempKeyID)*tempKeyID*(-1)^(tempKeyID)
	updateTableValue(tempTable, tempKeyID, "unlocked", encodedValue)
	--print("encodedValue")
	--print(encodedValue)
end
M.decodeValue = decodeValue


--Settings	
function getSettingValue(tempSettingName)

	local dataRow = {}

	local defaultValue1 = [[SELECT * FROM settings WHERE settingname=']]..tempSettingName..[[' ;]]
	dataRow = db:exec(defaultValue1)

	for tempRow in db:nrows(defaultValue1) do
	dataRow = tempRow -- Save everything to an array to get out of this "for/do" loop
	end   
	--print("WHAT I GOT",dataRow)
	--print("Settings",dataRow['settingname'],dataRow['settingvalue'])
	if dataRow == 0 then
		return "NOTSET"
	else
		return dataRow['settingvalue']
	end
end
M.getSettingValue = getSettingValue

function updateSetting(tempName,tempValue)

	local checking = M.getSettingValue(tempName) -- check for the setting in the table if its not there you can use this function to add a new setting
	
	if checking == "NOTSET" then 
		settingsToAdd = [[INSERT INTO settings values(NULL,']]..tempName..[[',']]..tempValue..[[');]] 
		--print("RECOD DID NOT EXIST.  Making a new record for it:",settingsToAdd)
		db:exec( settingsToAdd ); 
	else
		--print("Update database Setting Value")
		local rowUpdate  = [[UPDATE settings SET settingvalue = ']]..tempValue..[[' WHERE settingname=']]..tempName ..[[';]]
		--print (rowUpdate)
		message = db:exec(rowUpdate);     
		--print ("Message",message)
	end
end
M.updateSetting = updateSetting


---------------------------------------------------------------------------------
--| Close Database |--

--Step END - Close Database
local function stop()
	db:close()
end
M.stop = stop




return M