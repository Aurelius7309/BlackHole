local ffi = require "ffi"
local encoding = SMODS.load_file('Love2talk/encoding.lua')()
ffi.cdef[[
void Tolk_Load();
void Tolk_Output(const char *s, bool interrupt);
void Tolk_Silence();
void Tolk_Speak(const char *s, bool interrupt);
void Tolk_Braille(const char *s, bool interrupt);
void Tolk_TrySAPI(bool try);
void Tolk_PreferSAPI(bool prefer);
const wchar_t * Tolk_DetectScreenReader();
bool Tolk_HasSpeech();
bool Tolk_HasBraille();
bool Tolk_IsSpeaking();]]
local tolk = ffi.load(BlackHole.path.."bin/tolk.dll")
tolk.Tolk_Load()
local function output(s, interrupt)
    interrupt=interrupt or false
    
    tolk.Tolk_Output(encoding.to_utf16(s), interrupt)
end

local function speak(s, interrupt)
    interrupt=interrupt or false
    
    tolk.Tolk_Speak(encoding.to_utf16(s), interrupt)
end

local function braille(s)
    tolk.Tolk_Braille(encoding.to_utf16(s))
end

local function silence()
tolk.Tolk_Silence()
end

local function trySAPI(try)
    tolk.Tolk_TrySAPI(try)
end

local function preferSAPI(prefer)
    tolk.Tolk_PreferSAPI(prefer)
end
local function isSpeaking()
    return tolk.Tolk_IsSpeaking()
end

local function detectScreenReader()
    --todo, need to convert the returned value to something Lua likes
end

local function hasSpeech()
    return tolk.Tolk_HasSpeech()
end

local function hasBraille()
    return tolk.Tolk_HasBraille()
end


return {
    output=output,
    speak=speak,
    braille=braille,
    silence=silence,
    isSpeaking=isSpeaking,
    trySAPI=trySAPI,
    preferSAPI=preferSAPI,
    detectScreenReader=detectScreenReader,
    hasSpeech=hasSpeech,
    hasBraille=hasBraille}
