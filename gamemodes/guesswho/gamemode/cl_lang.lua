require( "gwlang" )

for _,locale in pairs( file.Find( "guesswho/gamemode/lang/*", "LUA" ) ) do
    include( "lang/" .. locale )
end

if GetConVar( "gw_language" ):GetString() != "auto" then
    if !gwlang.setLocale( GetConVar( "gw_language" ):GetString() ) then
        MsgN( "GW gw_language holds invalid value, falling back to default [" .. gwlang.getLocale() .. "].")
    end
else
    if !gwlang.setLocale( GetConVar( "gmod_language" ):GetString() ) then
        MsgN( "GW gmod_language holds invalid value, automatic language detection failed, falling back to default [" .. gwlang.getLocale() .. "].")
    else
        MsgN( "GW Language auto detected, language set to " .. gwlang.getLocale() .. "." )
    end
end

local function setLang( ply, cmd, args )

    if !gwlang.setLocale( args[1] ) then
        MsgN( "GW Could not set language to: " .. args[1] .. "." )
    else
        MsgN( "GW Language set to " .. gwlang.getLocale() .. "." )
        RunConsoleCommand( "gw_language", args[1] )
        GAMEMODE:RoundStateChange( GAMEMODE:GetRoundState(), GAMEMODE:GetRoundState() )
    end

end

concommand.Add( "gw_selectlanguage", setLang  )
