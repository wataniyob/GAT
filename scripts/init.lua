-- entry point for all lua code of the pack
-- more info on the lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
ENABLE_DEBUG_LOG = true
DEBUG = true

-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/modifiers.json")

Tracker:AddMaps("maps/maps.json")
ScriptHost:LoadScript("scripts/locations.lua")

-- Layout
Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")

-- AutoTracking for Poptracker
ScriptHost:LoadScript("scripts/autotracking/archipelago.lua")

-- Update total cubes with Golden and Anti counts
local function updateTotal()
    local g = Tracker:FindObjectForCode("golden")
    local a = Tracker:FindObjectForCode("anti")
    local t = Tracker:FindObjectForCode("total")

    if not g or not a or not t then
        return
    end

    t.AcquiredCount = g.AcquiredCount + a.AcquiredCount
end

-- Update Golden count after collecting enough bits
local function updateGoldenFromBits()
	local g = Tracker:FindObjectForCode("golden")
	local b = Tracker:FindObjectForCode("bit")
	
	if not g or not b then
        return
    end
	
	if b.AcquiredCount >= 8 then
		local wholeCubesInBits = b.AcquiredCount // 8
		b.AcquiredCount = b.AcquiredCount - (wholeCubesInBits*8)
		g.AcquiredCount = g.AcquiredCount + wholeCubesInBits
	end
	
	updateTotal()
end

ScriptHost:AddWatchForCode("WatchGolden", "golden", updateTotal)
ScriptHost:AddWatchForCode("WatchAnti", "anti", updateTotal)
ScriptHost:AddWatchForCode("WatchBit", "bit", updateGoldenFromBits)
ScriptHost:AddWatchForCode("PreventTotal", "total", updateTotal)