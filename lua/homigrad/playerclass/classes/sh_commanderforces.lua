--- @class CommanderForcesClass : PlayerClass
local CommanderForcesClass = hg.PlayerClass:Extend({
    name = "commanderforces",
    models = {
        ["Male 01"] = "models/dejtriyev/enhancednatguard/male_01.mdl",
        ["Male 02"] = "models/dejtriyev/enhancednatguard/male_02.mdl",
        ["Male 03"] = "models/dejtriyev/enhancednatguard/male_03.mdl",
        ["Male 04"] = "models/dejtriyev/enhancednatguard/male_04.mdl",
        ["Male 05"] = "models/dejtriyev/enhancednatguard/male_05.mdl",
        ["Male 06"] = "models/dejtriyev/enhancednatguard/male_06.mdl",
        ["Male 07"] = "models/dejtriyev/enhancednatguard/male_07.mdl",
        ["Male 08"] = "models/dejtriyev/enhancednatguard/male_08.mdl",
        ["Male 09"] = "models/dejtriyev/enhancednatguard/male_09.mdl"
    },
    accessories = false,
    color = {
        red = 100,
        green = 37,
        blue = 54
    }
})

function CommanderForcesClass:On(ply)
    if CLIENT then
        return
    end

    self:SetAppearance(ply, {
        subMaterial = false
    })

    self:SetupModel(ply, {
        skin = math.random(0, 2)
    })
    self:SetupBodygroups(ply, {
        bodygroups = {
        headgear = 14,
        ["Helmet Things"] = 0,
        top = math.random(12, 13),
        lower = math.random(12, 13),
        vest = 0,
        }
    })

    self:SetColor(ply)
    self:SetName(ply)

end

function CommanderForcesClass:Off()
    if CLIENT then
        return
    end
end

function CommanderForcesClass:PlayerDeath()
    if CLIENT then
        return
    end
end

function CommanderForcesClass:SetHooks()
    if SERVER then
        hook.Add("HG_PlayerFootstep", "commanderforces_footsteps", function(ply, pos, foot, sound, volume, rf)
            if ply:Alive() and ply.PlayerClassName == CommanderForcesClass.name then
                local ent = hg.GetCurrentCharacter(ply)

                if not (ply:IsWalking() or ply:Crouching()) and ent == ply then
                    local snd = "zcitysnd/" .. string.Replace(sound, "player/footsteps", "player/footsteps_military/")
                    if SoundDuration(snd) <= 0 then
                        snd = sound -- missing footsteps fix
                    end
                    EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95, 105)))

                    return true
                end
            end
        end)
    end
end

CommanderForcesClass:SetHooks()