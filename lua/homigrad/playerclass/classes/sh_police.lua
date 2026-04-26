---@class PoliceClass : PlayerClass
local PoliceClass = hg.PlayerClass:Extend({
    name = "police",
    models = {
        ["Male 01"] = "models/monolithservers/mpd/male_01.mdl",
        ["Male 03"] = "models/monolithservers/mpd/male_03.mdl",
        ["Male 04"] = "models/monolithservers/mpd/male_04.mdl",
        ["Male 05"] = "models/monolithservers/mpd/male_05.mdl",
        ["Male 07"] = "models/monolithservers/mpd/male_07.mdl",
        ["Male 08"] = "models/monolithservers/mpd/male_08.mdl",
        ["Male 09"] = "models/monolithservers/mpd/male_09.mdl"
    },
    accessories = false,
    color = {
        red = 10,
        green = 10,
        blue = 100
    },
    subclasses = {
        Sergeant = {
            prefixes = {
                Sergeant = 100
            },
            chance = 5,
            bodygroups = {
                ranks = 2
            }
        },
        Corporal = {
            prefixes = {
                Corporal = 100
            },
            chance = 20,
            bodygroups = {
                ranks = 1
            }
        },
        Officer = {
            prefixes = {
                Officer = 100
            },
            chance = 75,
            bodygroups = {
                ranks = 3
            }
        }
    }
})

function PoliceClass:On(ply)
    if CLIENT then
        return
    end

    self:SetSubclass()

    self:SetAppearance(ply, {
        subMaterial = false
    })
    self:SetupModel(ply)
    
    self:SetupBodygroups(ply, {
        bodygroups = {
            headgear = math.random(0, 2),
            shades = math.random(0, 3),
            mask = 0,
            belt = 0,
            armour = 0,
            ranks = self.subclass.bodygroups.ranks
        }
    })
    self:SetRole(ply, {
        name = "Police"
    })
    self:SetColor(ply)
    self:SetName(ply)
end

function PoliceClass:Off()
    if CLIENT then
        return
    end
end

function PoliceClass:PlayerDeath()
    if CLIENT then 
        return
    end
end