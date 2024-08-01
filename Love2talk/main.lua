function love.load()
tts=require "Love2talk"
end
function love.keypressed()
    print("synthesizer about to speak, currently " ..tostring(tts.isSpeaking()) ..".")
    tts.say("Hello world!")
    if tts.isSpeaking()==true then print("It's talking!") end 
end
