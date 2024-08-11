
local os=love.system.getOS()
if os =="Windows" then
    backend = SMODS.load_file('Love2talk/tolk.lua')()
    backend.trySAPI(true)
elseif os=="OS X" then
    backend = SMODS.load_file('Love2talk/macspeech.lua')()
end

local function say(text, interrupt)
    interrupt=interrupt or false
    backend.output(text, interrupt)
end

local function isSpeaking()
    return backend.isSpeaking()
end

local function silence()
    return backend.silence()
end
local function setRate(rate)
    backend.setRate(rate)
end

return {say=say, isSpeaking=isSpeaking, silence=silence, setRate=setRate}



