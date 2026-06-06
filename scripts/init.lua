-- entry point for all lua code of the pack
-- more info on the lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
ENABLE_DEBUG_LOG = true
DEBUG = true

-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/modifiers.json")
Tracker:AddItems("items/knowledge_elements.json")

Tracker:AddMaps("maps/maps.json")
ScriptHost:LoadScript("scripts/locations.lua")

-- Layout
Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")

-- AutoTracking for Poptracker
ScriptHost:LoadScript("scripts/autotracking/archipelago.lua")

-- Update knowledge rule items
-- -- Fox is 2 cubes
local function checkFox()
    local total = Tracker:FindObjectForCode("total")
    local Fox = Tracker:FindObjectForCode("Fox")

    if not total or not Fox then
        return
    end

    Fox.Active = (total.AcquiredCount >= 2)
end

-- -- know tetro is reaching "Code Machine" e.i. 2 cubes + bigthrone door unlock
local function checkKnowTetro()
    local total = Tracker:FindObjectForCode("total")
    local throne = Tracker:FindObjectForCode("bigthrone_room")
    local know_tetro = Tracker:FindObjectForCode("know_tetro")

    if not total or not throne or not know_tetro then
        return
    end

    know_tetro.Active = throne.Active and total.AcquiredCount >= 2
end
ScriptHost:AddWatchForCode("checkTetroKnowledge", "bigthrone_room", checkKnowTetro)

-- -- nuzu_school is 8 cubes
local function checknuzu_school()
    local total = Tracker:FindObjectForCode("total")
    local nuzu_school = Tracker:FindObjectForCode("nuzu_school")

    if not total or not nuzu_school then
        return
    end

    nuzu_school.Active = (total.AcquiredCount >= 8)
end

-- -- Oldschool is 16 cubes
local function checkOldschool()
    local total = Tracker:FindObjectForCode("total")
    local Oldschool = Tracker:FindObjectForCode("Oldschool")

    if not total or not Oldschool then
        return
    end

    Oldschool.Active = (total.AcquiredCount >= 16)
end

-- Update total cubes with Golden and Anti counts
local function updateTotal()
    local g = Tracker:FindObjectForCode("golden")
    local a = Tracker:FindObjectForCode("anti")
    local t = Tracker:FindObjectForCode("total")

    if not g or not a or not t then
        return
    end

    t.AcquiredCount = g.AcquiredCount + a.AcquiredCount
    
    -- update custom item for knowledge
    checkFox()
    checkKnowTetro()
    checknuzu_school()
    checkOldschool()
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