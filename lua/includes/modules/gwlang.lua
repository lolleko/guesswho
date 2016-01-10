local table = table

module( "gwlang" )

local defaultLocale = "en"
local currentLocale = defaultLocale
local locales = {}

function translate( token )
    return locales[ currentLocale ][ token ] or locales[ defaultLocale ][ token ] or "MISSING TRANSLATION"
end

function setLocale( locale )
    if isLocale( locale ) then
        currentLocale = locale
        return true
    end
    return false
end

function getLocale()
    return currentLocale
end

function getLanguageName( locale )
    return locales[ locale ].language_name or "MISSING NAME"
end

function addLangguage( langTbl, locale )
    locales[ locale ] = langTbl
end

function isLocale( locale )
    return locales[ locale ] ~= nil
end

function getLocaleList()
    return table.GetKeys( locales )
end
