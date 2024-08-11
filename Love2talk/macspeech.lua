
objc = SMODS.load_file('Love2talk/objc/objc.lua')()
local synth=objc.AVSpeechSynthesizer:alloc():init()

-- Because Older Mac OS versions don't use the default voice with this API we have to use the previous one to get the default voice
synth.voice=objc.NSSpeechSynthesizer:alloc():init():defaultVoice()


local function output(text, interrupt)
    if type(text) ~="string" then
        text=tostring(text)
    end
    interrupt = interrupt or false
	if interrupt then
		synth:stopSpeakingAtBoundary(0)
	end
	local utterance = objc.AVSpeechUtterance:alloc():initWithString(text)
	utterance.voice = objc.AVSpeechSynthesisVoice:voiceWithIdentifier(synth.voice)
    synth:speakUtterance(utterance)
    print("speaking", text, interrupt)
end
local function isSpeaking()
    if synth:isSpeaking()==1 then
        return true
    else
        return false
    end
end
local function silence()
synth:stopSpeakingAtBoundary(0)
end


return {output=output, isSpeaking=isSpeaking, silence=silence}

