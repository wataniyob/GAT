

function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

function right_layout()
    if has("shuffled_abilities") then
        Tracker:AddLayouts("layouts/collectibles_layout/collectibles_abilities.json")
    else
        Tracker:AddLayouts("layouts/collectibles_layout/collectibles.json")
    end
end