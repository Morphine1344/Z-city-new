--- @class SwatClass : PlayerClass
local SwatClass = hg.PlayerClass:Extend({
    name = "swat",
    prefixes = {
        SWAT = 100
    },
    models = {
        "models/css_seb_swat/css_swat.mdl"
    },
    accessories = false,
    color = {
        red = 10,
        green = 10,
        blue = 100
    }
})

function SwatClass:On(ply)
    if CLIENT then
        return
    end

    self:SetAppearance(ply, {
        subMaterial = false
    })

    self:SetupModel(ply)

    self:SetupBodygroups(ply, {
        bodygroups = {
            body = math.random(0, 1),
            headwear = 0,
            headphones = 0,
            helmet_attach = 0,
            facewear = 0,
            vest = 0,
            vest_patch = 0,
            gear = 0,
            mags = 0,
            lowr_gear = 1
        }
    })

    self:SetColor(ply)
    self:SetName(ply)
end

function SwatClass:Off()
    if CLIENT then
        return
    end
end

function SwatClass:PlayerDeath()
    if CLIENT then 
        return
    end
end

function SwatClass:SetHooks()
    hook.Add("HG_PlayerFootstep", "swat_footsteps", function(ply, pos, foot, sound, volume, rf)
        if ply:Alive() and ply.PlayerClassName == SwatClass.name then
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

SwatClass:SetHooks()

