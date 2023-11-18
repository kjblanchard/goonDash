---Loads and plays sounds
--- levels: 1:debug 2:info 3:warn 4:error

local Sound = {}
local sound = require("Sound")
local debug = require("Core.debug")
local settings = require("settings")
local loadedBgms = {}
local loadedSfx = {}
local filePath = "assets/audio/"
local currentPlayingBgm = ""

---Loads a function into the table if it isn't already loaded
---@param filename string The name that we should load
---@param loopStart number the time in seconds that the beginning of the loop should start, 0 is beginning
---@param loopEnd number the point in the song that we should loop to loopStart
function Sound.Load(filename, loopStart, loopEnd)
    local fullFilepath = filePath .. filename .. ".ogg"
    if loadedBgms[filename] ~= nil then return end
    local bgm = sound.LoadBgm(fullFilepath, loopStart, loopEnd)
    if bgm == nil then return end
    loadedBgms[filename] = bgm
end

---Plays a Bgm, this will preload some data automatically.
---@param filename string The filename we should play
function Sound.Play(filename)
    if currentPlayingBgm == filename then return end
    if loadedBgms[filename] == nil then
        debug.Warn("Could not play " .. filename .. " as it isn't loaded!")
        return
    end
    sound.PlayBgm(loadedBgms[filename], settings.bgmVolume)
    currentPlayingBgm = filename
end

function Sound.RestartBgm()
    if not currentPlayingBgm then return end
    if loadedBgms[currentPlayingBgm] == nil then
        debug.Warn("Could not restart " .. currentPlayingBgm .. " as it isn't loaded!")
        return
    end
    sound.PlayBgm(loadedBgms[currentPlayingBgm], settings.bgmVolume)
end

---Loads a function into the table if it isn't already loaded
---@param filename string The name that we should load
function Sound.LoadSfx(filename)
    if loadedSfx[filename] ~= nil then return end
    local fullFilepath = filePath .. filename .. ".ogg"
    local sfx = sound.LoadSfx(fullFilepath)
    if sfx == nil then return end
    loadedSfx[filename] = sfx
end

---Plays a Bgm, this will preload some data automatically.
---@param filename string The filename we should play
function Sound.PlaySfx(filename)
    if loadedSfx[filename] == nil then
        debug.Warn("Could not play sound " .. filename .. " as it isn't loaded!")
        return
    end
    sound.PlaySfx(loadedSfx[filename], settings.sfxVolume)
end


---Destroys a BGM that is loaded
---@param filename string The bgm to destroy
function Sound.Destroy(filename)
    local loadedSound = loadedBgms[filename]
    if loadedSound == nil then
        debug.Warn("Trying to destroy a sound that wasn't actaully loaded: " .. filename)
        return
    end
    sound.FreeBgm(filename)
end

Sound.__index = Sound
return Sound
