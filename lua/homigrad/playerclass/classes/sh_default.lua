--- @class DefaultClass : PlayerClass
local DefaultClass = hg.PlayerClass:Extend({
    name = "Default",
    accessories = true
})


function DefaultClass:On(ply)
    if CLIENT then return end

    self:SetAppearance(ply)
end

function DefaultClass:Off()
    if CLIENT then return end
end