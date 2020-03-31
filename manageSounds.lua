--MODULE

local M = {}



local introLoopingSound = audio.loadSound("soundClips/introLoopingSound.wav")
--Channel 1 is reserved for music
local usedChannels = {}


local function createSound( _fileAndPath, _volumePercent, _fadeOutDelay, _fadeOutTime )

	if _volumePercent == nil then
		_volumePercent = 1
	end
	tempVolume = 0.75*_volumePercent

	if _fadeOutDelay ~= nil then
		_loops = -1
	else
		_loops = 0
	end

	if _fileAndPath == introLoopingSound then
		loopStart = 1
		loopEnd = 1
	else
		loopStart = 2
		loopEnd = 32
	end

	--print(loopStart, loopEnd)

	for i = loopStart,loopEnd do
		if usedChannels[i] == nil then

			--print(i)

			usedChannels[i] = {}

			audio.setMaxVolume( tempVolume, { channel=i} )
			audio.setVolume( tempVolume, { channel=i } )


			audio.play( _fileAndPath,{
				channel = i,
				loops = _loops,
				--duration = nil,
				--fadin = 2000,
				onComplete = M.soundTableRemove
				})

			if _fadeOutDelay ~= nil then
				usedChannels[i].timerHandle = timer.performWithDelay(_fadeOutDelay, M.fadeSound, 1)
				usedChannels[i].timerHandle.params = {}
				usedChannels[i].timerHandle.params.fadeOutTime = _fadeOutTime
				usedChannels[i].timerHandle.params.channel = i
			end

			--print("Sound Played On Channel "..i)
			break
		end
	end
end
M.createSound = createSound

local function fadeSound(event)

	--print("FADE")
	tempParams = event.source.params
	_time = tempParams.fadeOutTime
	_channel = tempParams.channel

	audio.fade( { channel=_channel, time=_time, volume = 0 } )
end
M.fadeSound = fadeSound

local function soundTableRemove(tempSound)
	
	if usedChannels[tempSound.channel].timerHandle ~= nil then
		timer.cancel( usedChannels[tempSound.channel].timerHandle )
	end
	usedChannels[tempSound.channel] = nil
end
M.soundTableRemove = soundTableRemove




return M