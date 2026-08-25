--[[
    1337 Hub Loader — Auto-Detect & Auto-Execute
    Execute → Detect Game → Run Script → Done
--]]

--=========================================================================
-- GAME DATABASE
-- [PlaceId] = { "Nama Game", "Script URL", "Script Key" }
--=========================================================================
local GAMES = {
    [128784467030899] = { "Merge a Nuke!", "https://api.jnkie.com/api/v1/luascripts/public/a110766c7bd5ed95482a4163317711d7655ae41eae3f7b1cac2cc040a5c15906/download", "KEYLESS" },

    -- Add more games:
    -- [PlaceId] = { "Game Name", "Script URL", "Key" },
}

--=========================================================================
-- AUTO-DETECT & EXECUTE
--=========================================================================
local currentGame = GAMES[game.PlaceId]

if currentGame then
    local gameName  = currentGame[1]
    local scriptURL = currentGame[2]
    local scriptKey = currentGame[3]

    if scriptKey then
        getgenv().SCRIPT_KEY = scriptKey
    end

    loadstring(game:HttpGet(scriptURL))()
else
    warn("[1337 Hub] Script not available for this game (PlaceId: " .. game.PlaceId .. ")")
end
