--MODULE

--Common Function File

local M = {}


local function positiveAngle( _angle )

	local count

	count = 0
	while _angle < 0 do
		_angle = _angle + 360

		count = count + 1
		if count == 5 then
			--print("STUCK IN WHILE LOOP")
			break
		end
	end

	count = 0
	while _angle > 360 do
		_angle = _angle - 360

		count = count + 1
		if count == 5 then
			--print("STUCK IN WHILE LOOP")
			break
		end
	end

	return _angle
end
M.positiveAngle = positiveAngle

local function sortTable(tempTable, parameter)

	local sortedTable = {}

	for i = 1,#tempTable do
		local lowestItem = tempTable[1]
		local pos = 1
		local i

		for i = 1,#tempTable do
			if tempTable[i][parameter] < lowestItem[parameter] then
				lowestItem = tempTable[i]
				pos = i
			end
		end

		
		local id = #sortedTable+1
		sortedTable[id] = lowestItem
		table.remove( tempTable, pos )
	end

	return sortedTable
end
M.sortTable = sortTable

local function getDistance( object1, object2)

	local obj_1x = object1.x
	local obj_1y = object1.y
	local obj_2x = object2.x
	local obj_2y = object2.y

	local dist_x = obj_2x - obj_1x
	local dist_y = obj_2y - obj_1y

	local distance = math.sqrt( dist_x^2 + dist_y^2 )
	return distance
end
M.getDistance = getDistance



return M