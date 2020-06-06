gwlang = {}

gwlang.defaultLocale = "en"
gwlang.currentLocale = gwlang.defaultLocale
gwlang.locales = {}

function gwlang:translate( token )
    return self.locales[ self.currentLocale ][ token ] or self.locales[ self.defaultLocale ][ token ] or "MISSING TRANSLATION"
end

function gwlang:setLocale( locale )
    if self:isLocale( locale ) then
        self.currentLocale = locale
        return true
    end
    return false
end

function gwlang:getLocale()
    return self.currentLocale
end

function gwlang:getLanguageName( locale )
    return self.locales[ locale ].language_name or "MISSING NAME"
end

function gwlang:addLangguage( langTbl, locale )
    self.locales[ locale ] = langTbl
end

function gwlang:isLocale( locale )
    return self.locales[ locale ] ~= nil
end

function gwlang:getLocaleList()
    return table.GetKeys( self.locales )
end

for _,locale in pairs( file.Find( "guesswho/gamemode/lang/*", "LUA" ) ) do
    include( "lang/" .. locale )
end

if GetConVar( "gw_language" ):GetString() ~= "auto" then
    if not gwlang:setLocale( GetConVar( "gw_language" ):GetString() ) then
        MsgN( "GW gw_language holds invalid value, falling back to default [" .. gwlang:getLocale() .. "].")
    end
else
    if not gwlang:setLocale( GetConVar( "gmod_language" ):GetString() ) then
        MsgN( "GW gmod_language holds invalid value, automatic language detection failed, falling back to default [" .. gwlang:getLocale() .. "].")
    else
        MsgN( "GW Language auto detected, language set to " .. gwlang:getLocale() .. "." )
    end
end

local function setLang( ply, cmd, args )

    if not gwlang:setLocale( args[1] ) then
        MsgN( "GW Could not set language to: " .. args[1] .. "." )
    else
        MsgN( "GW Language set to " .. gwlang:getLocale() .. "." )
        RunConsoleCommand( "gw_language", args[1] )
        GWRound:RoundStateChange( GWRound:GetRoundState(), GWRound:GetRoundState() )
    end

end

concommand.Add( "gw_selectlanguage", setLang  )
