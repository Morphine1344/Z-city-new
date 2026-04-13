--- @class GrooveClass : PlayerClass
local GrooveClass = hg.PlayerClass:Extend({
    name = "groove",
    accessories = false,
    color = {
        red = 0,
        green = 165,
        blue = 0
    },
    subclasses = {
        OG = {
            prefixes = {
                OG = 100
            },
            chance = 5,
            models = {
                "models/gang_groove_boss/gang_groove_boss.mdl"
            }
        },
        Big = {
            prefixes = {
                Big = 100
            },
            chance = 20,
            models = {
                "models/gang_chem/gang_groove_chem.mdl"
            }
        },
        Lil = {
            prefixes = {
                Lil = 100
            },
            chance = 75,
            models = {
                "models/gang_groove/gang_1.mdl",
            }
        }
    }
})

function GrooveClass:On(ply)
    if CLIENT then
        return
    end

    self:SetSubclassesBodygroups({
        OG = {
            bodygroups = {
                glasses = math.random(0, 2),
                headphone = math.random(0, 2)
            }
        },
        Big = {
            bodygroups = {
                cap = math.random(0, 2),
                mask = math.random(0, 1),
                arms = math.random(0, 1),
                arm_clock = math.random(0, 1),
            }
        },
        Lil = {
            bodygroups = {
                cap = math.random(0, 1),
                chain = math.random(0, 1),
                glasses = math.random(0, 2),
                mask = math.random(0, 2),
                arms = math.random(0, 1),
                arm_clock = math.random(0, 1),
            }
        }
    })
    local subclass = self:SetSubclass()

    self:SetAppearance(ply, {
        subMaterial = false
    })
    self:SetupModel(ply)
    self:SetupBodygroups(ply, {
        bodygroups = subclass.bodygroups
    })
    self:SetColor(ply)
    self:SetName(ply)
end

function GrooveClass:Off()
    if CLIENT then
        return
    end
end

function GrooveClass:PlayerDeath()
    if CLIENT then 
        return
    end
end

