GWLANG = {}

GWLANG.defaultLocale = "en"
GWLANG.currentLocale = GWLANG.defaultLocale
GWLANG.locales = {}

function GWLANG:Translate( token )
    return self.locales[ self.currentLocale ][ token ] or self.locales[ self.defaultLocale ][ token ] or "MISSING TRANSLATION"
end

function GWLANG:SetLocale( locale )
    if self:IsLocale( locale ) then
        self.currentLocale = locale
        return true
    end
    return false
end

function GWLANG:GetLocale()
    return self.currentLocale
end

function GWLANG:GetLanguageName( locale )
    return self.locales[ locale ].language_name or "MISSING NAME"
end

function GWLANG:AddLangguage( langTbl, locale )
    self.locales[ locale ] = langTbl
end

function GWLANG:IsLocale( locale )
    return self.locales[ locale ] ~= nil
end

function GWLANG:GetLocaleList()
    return table.GetKeys( self.locales )
end

for _,locale in pairs( file.Find( "guesswho/gamemode/lang/*", "LUA" ) ) do
    include( "lang/" .. locale )
end

if GetConVar( "gw_language" ):GetString() ~= "auto" then
    if not GWLANG:SetLocale( GetConVar( "gw_language" ):GetString() ) then
        MsgN( "GW gw_language holds invalid value, falling back to default [" .. GWLANG:GetLocale() .. "].")
    end
else
    if not GWLANG:SetLocale( GetConVar( "gmod_language" ):GetString() ) then
        MsgN( "GW gmod_language holds invalid value, automatic language detection failed, falling back to default [" .. GWLANG:GetLocale() .. "].")
    else
        MsgN( "GW Language auto detected, language set to " .. GWLANG:GetLocale() .. "." )
    end
end

local function setLang( ply, cmd, args )

    if not GWLANG:SetLocale( args[1] ) then
        MsgN( "GW Could not set language to: " .. args[1] .. "." )
    else
        MsgN( "GW Language set to " .. GWLANG:GetLocale() .. "." )
        RunConsoleCommand( "gw_language", args[1] )
        GWRound:RoundStateChange( GWRound:GetRoundState(), GWRound:GetRoundState() )
    end

end

concommand.Add( "gw_selectlanguage", setLang  )
