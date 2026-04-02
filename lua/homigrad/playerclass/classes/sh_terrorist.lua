--- @class TerroristClass : PlayerClass
local TerroristClass = hg.PlayerClass:Extend({
    name = "terrorist",
    accessories = {
        attachments = {
            "arctic_balaclava",
            "phoenix_balaclava",
            "bandana"
        }
    }
})

function TerroristClass:On(ply)
    if CLIENT then
        return
    end

    self:SetAppearance(ply)

    self:SetHooks()
end

function TerroristClass:Off()
    if CLIENT then
        return
    end
end

function TerroristClass:SetHooks()
    hook.Add("HG_PlayerFootstep", "terrorist_footsteps", function(ply, pos, foot, sound, volume, rf)
        local chr = hg.GetCurrentCharacter(ply)
        if ply:Alive() and ply.PlayerClassName == "terrorist" then
            local ent = hg.GetCurrentCharacter(ply)

            if not (ply:IsWalking() or ply:Crouching()) and ent == ply then
                local snd = "homigrad/" .. sound
                if SoundDuration(snd) <= 0 then
                    snd = sound -- missing footsteps fix
                end

                EmitSound("homigrad/player/footsteps/new/bass_0"..math.random(9)..".wav", pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95,105)))
                EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95,105)))
            end
        end
    end)
end

