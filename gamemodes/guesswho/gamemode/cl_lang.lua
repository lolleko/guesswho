require( "gwlang" )

for _,locale in pairs( file.Find( "guesswho/gamemode/lang/*", "LUA" ) ) do
    include( "lang/" .. locale )
end

if GetConVar( "gw_language" ):GetString() != "auto" then
    if !gwlang.setLocale( GetConVar( "gw_language" ):GetString() ) then
        MsgN( "GW gw_language holds invalid value, falling back to default [" .. gwlang.getLocale() .. "].")
    end
else
    if !gwlang.setLocale( system.GetCountry() ) then
        MsgN( "GW gw_language holds invalid value, falling back to default [" .. gwlang.getLocale() .. "].")
    end
end

local function setLang( ply, cmd, args )

    if !gwlang.setLocale( args[1] ) then
        MsgN( "GW Could not set language to: " .. gwlang.getLocale() .. "." )
    else
        RunConsoleCommand( "gw_language", args[1] )
        GAMEMODE:RoundStateChange( GAMEMODE:GetRoundState(), GAMEMODE:GetRoundState() )
    end

end

concommand.Add( "gw_selectlanguage", setLang  )
