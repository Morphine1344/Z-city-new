--- @class MetrocopClass : PlayerClass
local MetrocopClass = hg.PlayerClass:Extend({
    name = "Metrocop",
    prefixes = {
        Officer = 100
    },
    callsigns = {
        "Alpha",
        "Charlie",
        "Bravo",
        "Delta"
    },
    models = {
        "models/player/police.mdl"
    },
    accessories = false,
    color = {
        red = 24,
        green = 24,
        blue = 24
    },
    weapons = {
        primary = {
            weapon_mp7 = {
                attachments = {
                    sights = {
                        holo14 = {}
                    }
                }
            }
        },
        secondary = {
            weapon_hk_usp = {}
        },
        melee = {
            weapon_hg_stunstick = {}
        }
    },
    equipment = {
        armor = {
            helmets = {
                "metrocop_helmet"
            },
            vests = {
                "metrocop_armor"
            }
        },
        medicine = {
            "weapon_medkit_sh",
            "weapon_naloxone",
            "weapon_bigbandage_sh",
            "weapon_tourniquet",
        },
        others = {
            "weapon_handcuffs",
            "weapon_handcuffs_key",
            "weapon_walkie_talkie"
        }
    },
    relations = {
        npc = {
            friendly = {
                "alliance"
            },
            hostile = {
                "rebels"
            }
        }
    }
})

function MetrocopClass:On(ply)
    if CLIENT then
        return
    end

    self:SetAppearance(ply, {
        subMaterial = false
    })

    self:SetupModel(ply)

    self:SetColor(ply)

    self:GiveLoadout(ply)

    self:SetRole(ply, {
        name = "Officer",
        color = {
            red = 89,
            green = 230,
            blue = 255
        }
    })

    self:SetName(ply, {
        withName = false,
        numberedCallsigns = true
    })
    

    self:SetNpcRelationships(ply)
end

function MetrocopClass:Off(ply)
    if CLIENT then
        return
    end

    self:UnsetRole(ply)

    self:UnsetNpcRelationships(ply)
end

function MetrocopClass:PlayerDeath(ply)

    local function playDeathSound(ply)

        if IsValid(ply) then
            local sounds = {
                "npc/metropolice/die1.wav",
                "npc/metropolice/die2.wav",
                "npc/metropolice/die3.wav",
                "npc/metropolice/die4.wav"
            }

            EmitSound(sounds[math.random(#sounds)], ply:GetPos())
        end
    end

    playDeathSound(ply)
    
end

function MetrocopClass:SetHooks()
    if SERVER then
        hook.Add("HG_ReplacePhrase", "metrocop_phrase", function(ply, phrase, muffed, pitch)
            if IsValid(ply) and ply.PlayerClassName == self.name then
                local phrases = {}
                local files, _ = file.Find("sound/npc/metropolice/vo/*.wav", "GAME")
                for key, value in ipairs(files) do
                    phrases[key] = "npc/metropolice/vo/" .. value
                end
                return ply, phrases[math.random(#phrases)], muffed, pitch
            end
        end)

        hook.Add("HG_PlayerFootstep", "metrocop_footsteps", function(ply, pos, foot, sound, volume, rf)
            local chr = hg.GetCurrentCharacter(ply)

            if ply:Alive() and ply.PlayerClassName == self.name then
                ply.MetrocopLerpedFootStep = LerpFT(0.5, ply.MetrocopLerpedFootStep or 60,
                    (not ply:IsSprinting() and (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK))) and 20 or 60)
                if IsValid(ply.FakeRagdoll) and ply:GetNetVar("lastFake") == 0 then return end
                chr:EmitSound("npc/metropolice/gear" .. math.random(1, 6) .. ".wav", ply.MetrocopLerpedFootStep)
            end
        end)
    end

    if CLIENT then
        local cmb_mat = Material("sprites/mat_jack_helmoverlay_r")
        hook.Add("PostDrawHUD", "Metrocop_helmet", function()
            local lply = LocalPlayer()
            if lply:Alive() and lply.PlayerClassName == self.name then
                surface.SetDrawColor(150, 190, 190, 255)

                surface.SetMaterial(cmb_mat)
                surface.DrawTexturedRectRotated(
                    (ScrW() / 2) - 5,
                    (ScrH() / 2) - 5,
                    ScrW() + 10,
                    ScrH() + 450,
                    180
                )
            end
        end)
    end
end

MetrocopClass:SetHooks()
