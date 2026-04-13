--- @class BloodzClass : PlayerClass
local BloodzClass = hg.PlayerClass:Extend({
    name = "bloodz",
    accessories = false,
    color = {
        red = 165,
        green = 0,
        blue = 0
    },
    subclasses = {
        OG = {
            prefixes = {
                OG = 100
            },
            chance = 5,
            models = {
                "models/gang_ballas_boss/gang_ballas_boss.mdl"
            }
        },
        Big = {
            prefixes = {
                Big = 100
            },
            chance = 20,
            models = {
                "models/gang_ballas_chem/gang_ballas_chem.mdl"
            }
        },
        Lil = {
            prefixes = {
                Lil = 100
            },
            chance = 75,
            models = {
                "models/gang_ballas/gang_ballas_1.mdl",
            }
        }
    }
})

function BloodzClass:On(ply)
    if CLIENT then
        return
    end

    self:SetSubclassesBodygroups({
        OG = {
            bodygroups = {
                glasses = math.random(0, 1),
                rings = math.random(0, 1),
                chain = math.random(0, 1)
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
                body = math.random(0, 2),
                glasses = math.random(0, 2),
                mask = math.random(0, 2),
                arms = math.random(0, 2),
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

function BloodzClass:Off()
    if CLIENT then
        return
    end
end

function BloodzClass:PlayerDeath()
    if CLIENT then 
        return
    end
end