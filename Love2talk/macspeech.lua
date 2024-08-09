
objc = SMODS.load_file('Love2talk/objc/objc.lua')()
objc.load'AVFAudio'
local synth=objc.AVSpeechSynthesizer:alloc():init()
local function silence()
    synth:stopSpeakingAtBoundary(objc.AVSpeechBoundaryImmediate)
end 
local function output(text, interrupt)
    if type(text) ~="string" then
        text=tostring(text)
    end
    local toSpeak = objc.AVSpeechUtterance:alloc():initWithString(objc.toobj(text)) 
    if interrupt then
        silence()
    end
    synth:speakUtterance(toSpeak)
end
local function isSpeaking()
    if synth:isSpeaking()==1 then
        return true
    else
        return false
    end
end

return {output=output, isSpeaking=isSpeaking, silence=silence}

