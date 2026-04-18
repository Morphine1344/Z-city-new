--- @class RefugeeClass : PlayerClass
local RefugeeClass = hg.PlayerClass:Extend({
    name = "Refugee",
    accessories = false,
    subclasses = {
        Commander = {
            chance = 5,
            models = {
                ["Male 01"]   = "models/player/group03/male_01.mdl",
                ["Male 02"]   = "models/player/group03/male_02.mdl",
                ["Male 03"]   = "models/player/group03/male_03.mdl",
                ["Male 04"]   = "models/player/group03/male_04.mdl",
                ["Male 05"]   = "models/player/group03/male_05.mdl",
                ["Male 06"]   = "models/player/group03/male_06.mdl",
                ["Male 07"]   = "models/player/group03/male_07.mdl",
                ["Male 08"]   = "models/player/group03/male_08.mdl",
                ["Male 09"]   = "models/player/group03/male_09.mdl",
                ["Female 01"] = "models/player/group03/female_01.mdl",
                ["Female 02"] = "models/player/group03/female_02.mdl",
                ["Female 03"] = "models/player/group03/female_03.mdl",
                ["Female 04"] = "models/player/group03/female_04.mdl",
                ["Female 05"] = "models/player/group03/female_05.mdl",
                ["Female 06"] = "models/player/group03/female_06.mdl"

            },
            color = {
                red = 246,
                green = 139,
                blue = 0
            },
        },
        Medic = {
            chance = 20,
            models = {
                ["Male 01"] = "models/player/group03m/male_01.mdl",
                ["Male 02"] = "models/player/group03m/male_02.mdl",
                ["Male 03"] = "models/player/group03m/male_03.mdl",
                ["Male 04"] = "models/player/group03m/male_04.mdl",
                ["Male 05"] = "models/player/group03m/male_05.mdl",
                ["Male 06"] = "models/player/group03m/male_06.mdl",
                ["Male 07"] = "models/player/group03m/male_07.mdl",
                ["Male 08"] = "models/player/group03m/male_08.mdl",
                ["Male 09"] = "models/player/group03m/male_09.mdl",
                ["Female 01"] = "models/player/group03m/female_01.mdl",
                ["Female 02"] = "models/player/group03m/female_02.mdl",
                ["Female 03"] = "models/player/group03m/female_03.mdl",
                ["Female 04"] = "models/player/group03m/female_04.mdl",
                ["Female 05"] = "models/player/group03m/female_05.mdl",
                ["Female 06"] = "models/player/group03m/female_06.mdl"
            },
            equipment = {
                medicine = {
                    "weapon_bloodbag",
                    "weapon_bandage_sh",
                    "weapon_medkit_sh",
                    "weapon_mannitol",
                    "weapon_morphine",
                    "weapon_naloxone",
                    "weapon_painkillers",
                    "weapon_tourniquet",
                    "weapon_needle",
                    "weapon_betablock",
                    "weapon_adrenaline"
                }
            }
        },
        Refugee = {
            chance = 75,
            models = {},
            subMaterials = {
                male = {
                    ["4"] = "models/humans/male/group02/citizen_sheet",
                    ["5"] = "models/humans/male/group02/citizen_sheet",
                    ["6"] = "models/humans/male/group02/citizen_sheet",
                    ["7"] = "models/humans/male/group02/citizen_sheet",
                },
                female = {
                    ["4"] = "models/humans/female/group02/citizen_sheet",
                    ["5"] = "models/humans/female/group02/citizen_sheet",
                    ["6"] = "models/humans/female/group02/citizen_sheet",
                    ["7"] = "models/humans/female/group02/citizen_sheet",
                }
            }
        }
    },
    color = {
        red = 0,
        green = 60,
        blue = 10
    }
})

function RefugeeClass:On(ply)
    if CLIENT then
        return
    end
    
    self:SetSubclass()

    self:GiveLoadout(ply)

    self:SetAppearance(ply, {
        subMaterial = false,
    })

    self:SetupModel(ply)

    self:SetupSubMaterials(ply)

    self:SetColor(ply)

    self:SetName(ply)

    self:SetRole(ply)
end

function RefugeeClass:Off(ply)
    if CLIENT then
        return
    end

    self:UnsetRole(ply)
end

function RefugeeClass:PlayerDeath()
    if CLIENT then
        return
    end
end