--- @class CombineClass : PlayerClass
local CombineClass = hg.PlayerClass:Extend({
    name = "Combine",
    callsigns = {
        "Alpha",
        "Bravo",
        "Charlie",
        "Delta",
        "Echo",
        "Foxtrot",
        "Tango",
        "Sierra",
        "Uniform",
        "Kilo",
        "Yankee",
        "Regent",
        "Zulu",
        "Omega",
        "Nova",
        "Viper",
        "Ghost",
        "Raven",
    },
    models = {
        "models/player/combine_soldier.mdl"
    },
    accessories = false,
    color = {
        red = 0,
        green = 220,
        blue = 220
    },
    subclasses = {
        Elite = {
            chance = 5,
            callsigns = {
                "Leader",
                "Obliterator",
                "Overlord",
                "Director",
                "Control"
            },
            models = {
                "models/player/combine_super_soldier.mdl"
            },
            color = {
                red = 246,
                green = 13,
                blue = 13
            },
            weapons = {
                primary = {
                    weapon_osipr = {}
                },
                secondary = {
                    weapon_revolver357 = {}
                }
            }
        },
        Sniper = {
            chance = 15,
            weapons = {
                primary = {
                    weapon_combinesniper = {}
                },
                explosive = {}
            }
        },
        Shotgunner = {
            chance = 30,
            skin = 1,
            color = {
                red = 220,
                green = 0,
                blue = 0
            },
            weapons = {
                primary = {
                    weapon_spas12 = {}
                }
            }
        },
        Soldier = {
            chance = 50,
            weapons = {
                primary = {
                    weapon_osipr = {
                        chance = 75
                    },
                    weapon_mp7 = {
                        chance = 25,
                        attachments = {
                            sights = {
                                holo14 = 100
                            }
                        }
                    }
                }
            }
        }
    },
    weapons = {
        secondary = {
            weapon_hk_usp = {}
        },
        melee = {
            weapon_melee = {}
        },
        explosive = {
            weapon_hg_hl2nade_tpik = {}
        }
    },
    equipment = {
        armor = {
            helmets = {
                "cmb_helmet"
            },
            vests = {
                "cmb_armor"
            }
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

function CombineClass:On(ply)
    if CLIENT then
        return
    end

    if eightbit and eightbit.EnableEffect and ply.UserID then
		eightbit.EnableEffect(ply:UserID(), eightbit.EFF_PROOT) --!! placeholder
	end

    if IsValid(ply.FakeRagdoll) then
        hg.FakeUp(ply, nil, true)
    end

    ply.organism.CantCheckPulse = true
    ply.organism.recoilmul = 0.6


    local subclass = self:SetSubclass()

    self:GiveLoadout(ply)
    
    self:SetAppearance(ply, {
        subMaterial = false
    })
    self:SetupModel(ply, {
        skin = subclass.skin
    })

    self:SetColor(ply, {
        color = subclass.color
    })

    self:SetName(ply, {
        withName = false,
        numberedCallsigns = true
    })

    self:SetRole(ply, {
        color = subclass.color
    })

    self:SetNpcRelationships(ply)

end

function CombineClass:Off(ply)
    if CLIENT then 
        return 
    end

    ply.organism.CantCheckPulse = false
    ply.organism.recoilmul = 1
    self:UnsetRole(ply)
    self:UnsetNpcRelationships(ply)
end

function CombineClass:PlayerDeath()
    if CLIENT then 
        return
    end
end

function CombineClass:SetHooks()

    if SERVER then
        
        hook.Add("HG_ReplacePhrase", "Combine_phrase", function(ply, phrase, muffed, pitch)
            if IsValid(ply) and ply.PlayerClassName == self.name then
                local cmb_phrases = {
                    "npc/combine_soldier/vo/reportingclear.wav",
                    "npc/combine_soldier/vo/ripcordripcord.wav",
                    "npc/combine_soldier/vo/reportallpositionsclear.wav",
                    "npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
                    "npc/combine_soldier/vo/overwatchrequestreserveactivation.wav",
                    "npc/combine_soldier/vo/overwatchconfirmhvtcontained.wav",
                    "npc/combine_soldier/vo/onedown.wav",
                    "npc/combine_soldier/vo/heavyresistance.wav",
                    "npc/combine_soldier/vo/containmentproceeding.wav",
                    "npc/combine_soldier/vo/contactconfirmprosecuting.wav",
                    "npc/combine_soldier/vo/movein.wav",
                    "npc/combine_soldier/vo/overwatchteamisdown.wav",
                    "npc/combine_soldier/vo/prosecuting.wav",
                    "npc/combine_soldier/vo/stayalertreportsightlines.wav",
                    "npc/combine_soldier/vo/teamdeployedandscanning.wav",
                    "npc/combine_soldier/vo/copythat.wav",
                    "npc/combine_soldier/vo/engagedincleanup.wav",
                    "npc/combine_soldier/vo/executingfullresponse.wav",
                    "npc/combine_soldier/vo/goactiveintercept.wav",
                    "npc/combine_soldier/vo/necroticsinbound.wav",
                    "npc/combine_soldier/vo/standingby].wav",
                    "npc/combine_soldier/vo/stayalert.wav",
                    "npc/combine_soldier/vo/targetmyradial.wav",
                    "npc/combine_soldier/vo/weareinaninfestationzone.wav",
                    "npc/combine_soldier/vo/wehavenontaggedviromes.wav"
                }
                return ply, cmb_phrases[math.random(#cmb_phrases)], muffed, pitch
            end
        end)

        hook.Add("HG_PlayerFootstep", "Combine_footsteps", function(ply)
            local chr = hg.GetCurrentCharacter(ply)
            if ply:Alive() and ply.PlayerClassName == self.name then
                ply.CombineLerpedFootStep = LerpFT(0.5, ply.CombineLerpedFootStep or 60,
                    (not ply:IsSprinting() and (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK))) and 20 or 60)
                if IsValid(ply.FakeRagdoll) and ply:GetNetVar("lastFake") == 0 then return end
                chr:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", ply.CombineLerpedFootStep)
            end
        end)

        hook.Add("HG_CanThoughts", "Combine_canThoughts", function(ply)
            if ply.PlayerClassName == self.name then
                return false
            end
        end)

        hook.Add("HGReloading", "Combine_reloadAlert", function(wep)
            local ply = wep:GetOwner()
            if not IsValid(ply) then return end
            local nearPlayers = ents.FindInSphere(ply:GetPos(), 300)
            
            for _, mate in ipairs(nearPlayers) do
                if mate:IsPlayer() and mate ~= ply and mate:Alive() and mate.PlayerClassName == self.name then
                    if ply:Alive() and not ply.organism.otrub and ply.PlayerClassName == self.name and wep.ShellEject ~= "ShotgunShellEject" then
                        local phrases = {
                            "npc/combine_soldier/vo/coverme.wav",
                            "npc/combine_soldier/vo/coverhurt.wav"
                        }
                        local phrase = phrases[math.random(#phrases)]
                        ply:EmitSound(phrase, 75, ply.VoicePitch)
                        ply.phrCld = CurTime() + (SoundDuration(phrase) or 0)
                        ply.lastPhr = phrase
                        return
                    end
                end
            end
        end)

        util.AddNetworkString("CombineRadioStart")
        util.AddNetworkString("CombineRadioEnd")
        util.AddNetworkString("CombineChatMessage")

        hook.Add("HG_PlayerCanHearPlayersVoice", "CombineRadio", function(listener, talker)
            if talker.PlayerClassName == self.name and listener.PlayerClassName == self.name and talker:Alive() then
                return true, false
            end
        end)

        hook.Add("HG_PlayerSay", "CombineChatMessage", function(ply, txtTbl, text)
            if ply.PlayerClassName == self.name and ply:Alive() and not ply.organism.otrub then
                local radioSounds = {
                    off = {
                        "npc/combine_soldier/vo/off1.wav",
                        "npc/combine_soldier/vo/off2.wav",
                    }
                }
                ply:EmitSound(radioSounds.off[math.random(#radioSounds.off)])
            end
        end)
    end


    if CLIENT then
        local radioSounds = {
            off = {
                "npc/combine_soldier/vo/off1.wav",
                "npc/combine_soldier/vo/off2.wav",
                "npc/combine_soldier/vo/off3.wav"
            },
            on = {
                "npc/combine_soldier/vo/on1.wav",
                "npc/combine_soldier/vo/on2.wav"
            }
        }

        hook.Add("PlayerStartVoice", "CombineRadioStart", function(ply)
            if ply.PlayerClassName == self.name and ply:Alive() then
                ply:EmitSound(radioSounds.on[math.random(#radioSounds.on)])
            end
        end)
        
        hook.Add("PlayerEndVoice", "CombineRadioEnd", function(ply)
            if ply.PlayerClassName == self.name and ply:Alive() then
                ply:EmitSound(radioSounds.off[math.random(#radioSounds.off)])
            end
        end)

        hook.Add("HG_NoSoundproof", "CombineNoSoundproof", function(pPly, lply)
            if pPly.PlayerClassName == self.name and pPly:Alive() and lply.PlayerClassName == self.name and lply:Alive() then
                return true
            end
        end)

        hook.Add("ZC_DisableShootTinnitus", "NoCombineTinnitus", function(lply)
            if lply.PlayerClassName == self.name then return true end
        end)

        hook.Add("ZC_BodyTemperature", "CombineSuitWarming", function(ply, org, timeValue, changeRate, MaxWarmMul, warmLoseMul)
            if ply.PlayerClassName == self.name then
                return changeRate, MaxWarmMul + 0.5, warmLoseMul - 0.4
            end
        end)

        -- PNV 
        local pnv_enabled = false
        local next_toggle_time = 0
        local toggle_cooldown = 1
        local transition_time = 1
        local transition_start = 0
        local transitioning = false
        local pnv_light = nil

        local pnv_color_1 = {
            ["$pp_colour_addr"] = 0, ["$pp_colour_addg"] = 0.07, ["$pp_colour_addb"] = 0.1,
            ["$pp_colour_brightness"] = 0.01, ["$pp_colour_contrast"] = 0.6,
            ["$pp_colour_colour"] = 0.08, ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0.1, ["$pp_colour_mulb"] = 0.2
        }
        
        local pnv_color_2 = {
            ["$pp_colour_addr"] = 0.06, ["$pp_colour_addg"] = 0, ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0.05, ["$pp_colour_contrast"] = 0.6,
            ["$pp_colour_colour"] = 0.08, ["$pp_colour_mulr"] = 0.2,
            ["$pp_colour_mulg"] = 0, ["$pp_colour_mulb"] = 0
        }

        local function togglePNV()
            local ply = LocalPlayer()
            if ply.PlayerClassName ~= self.name or not ply:Alive() then
                if pnv_enabled then
                    pnv_enabled = false
                    surface.PlaySound("items/nvg_off.wav")
                    hook.Remove("RenderScreenspaceEffects", "PNV_ColorCorrection_Dynamic")
                    if IsValid(pnv_light) then
                        pnv_light:Remove()
                        pnv_light = nil
                    end
                end
                return
            end

            pnv_enabled = not pnv_enabled
            transition_start = CurTime()

            if pnv_enabled then
                transitioning = true
                surface.PlaySound("items/nvg_on.wav")
                hook.Add("RenderScreenspaceEffects", "PNV_ColorCorrection_Dynamic", function()
                    if ply.PlayerClassName ~= self.name then return end
                    local progress = math.min((CurTime() - transition_start) / transition_time, 1)
                    local class = ply:GetNWString("PlayerRole")
                    local cc = (class == "Elite" or class == "Shotgunner") and table.Copy(pnv_color_2) or table.Copy(pnv_color_1)
                    
                    for k, v in pairs(cc) do
                        cc[k] = v * progress
                    end
                    
                    DrawColorModify(cc)
                    DrawBloom(0.1 * progress, 1 * progress, 2 * progress, 2 * progress, 1 * progress, 0.4 * progress, 1, 1, 1)
                    if progress >= 1 then transitioning = false end
                end)
            else
                transitioning = false
                surface.PlaySound("items/nvg_off.wav")
                hook.Remove("RenderScreenspaceEffects", "PNV_ColorCorrection_Dynamic")
            end
        end

        hook.Add("RenderScreenspaceEffects", "PNV_ColorCorrection", function()
            local ply = LocalPlayer()
            if ply.PlayerClassName ~= self.name then return end
            if pnv_enabled and not transitioning then
                local class = ply:GetNWString("PlayerRole")
                local cc = (class == "Elite" or class == "Shotgunner") and pnv_color_2 or pnv_color_1
                DrawColorModify(cc)
                DrawBloom(0.1, 0.5, 2, 2, 1, 0.4, 1, 1, 1)
            end
        end)

        hook.Add("PreDrawHalos", "PNV_Light", function()
            local ply = LocalPlayer()
            if ply.PlayerClassName ~= self.name then return end
            if pnv_enabled then
                if not IsValid(pnv_light) then
                    pnv_light = ProjectedTexture()
                    pnv_light:SetTexture("effects/flashlight001")
                    pnv_light:SetBrightness(2)
                    pnv_light:SetEnableShadows(false)
                    pnv_light:SetConstantAttenuation(0.02)
                    pnv_light:SetNearZ(12)
                    pnv_light:SetFOV(70)
                end
                pnv_light:SetPos(ply:EyePos())
                pnv_light:SetAngles(ply:EyeAngles())
                pnv_light:Update()
            elseif IsValid(pnv_light) then
                pnv_light:Remove()
                pnv_light = nil
            end
        end)

        hook.Add("Think", "PNV_Think", function()
            local ply = LocalPlayer()
            if ply:Alive() and ply.PlayerClassName == self.name then
                if input.IsKeyDown(KEY_F) and not gui.IsGameUIVisible() and not IsValid(vgui.GetKeyboardFocus()) and (CurTime() > next_toggle_time) then
                    togglePNV()
                    next_toggle_time = CurTime() + toggle_cooldown
                end
            end
            if not ply:Alive() and pnv_enabled then togglePNV() end
            if ply.PlayerClassName ~= self.name and pnv_enabled then togglePNV() end

            if pnv_enabled and IsValid(pnv_light) then
                pnv_light:SetPos(ply:EyePos())
                pnv_light:SetAngles(ply:EyeAngles())
                pnv_light:Update()
            end
        end)
    end
end

function CombineClass:PlayerHud()
    if not CLIENT then return end

    local color_hp = Color(0, 255, 255, 220)
    local color_ar = Color(0, 255, 255, 220)
    local color_glow = Color(15, 165, 165, 0)
    local color_glow_ar = Color(15, 165, 165, 0)
    local color_glow_ammo = Color(15, 165, 165, 0)
    
    local color_hp2 = Color(165, 15, 15)
    local color_ar2 = Color(165, 15, 15)
    local color_glow2 = Color(165, 15, 15)
    local color_glow_ar2 = Color(165, 15, 15)
    local color_glow_ammo2 = Color(165, 15, 15)

    local bg_color = Color(0, 0, 0, 150)
    local silentclr = Color(0, 255, 255, 220)
    
    local hp_txt, pulse_txt, stamina_txt, ammo_txt = 0, 0, 0, 0
    local old_hp_txt, old_ammo_txt = 0, 0
    local ammolerp, silentlerp = 0, 0

    local cmb_mat = Material("sprites/mat_jack_helmoverlay_r")


    surface.CreateFont("CMBFontDefault", {
        font = "Roboto Light", extended = true, size = ScreenScale(24),
        weight = 500, scanlines = 3, antialias = true
    })

    surface.CreateFont("CMBFontSmall", {
        font = "Roboto Light", extended = true, size = ScreenScale(7.5),
        weight = 1500, scanlines = 3, antialias = true
    })

    surface.CreateFont("CMBFontDefaultBG", {
        font = "Roboto Light", extended = true, size = ScreenScale(24.5),
        weight = 1500, blursize = 1, scanlines = 3, antialias = true
    })

    local function drawGlowingText(txt, font, x, y, col, col_glow, col_glow2, align)
        draw.DrawText(txt, font, x + 1, y + 1, col_glow, align)
        if col_glow2 then draw.DrawText(txt, font, x + 2, y + 2, col_glow2, align) end
        draw.DrawText(txt, font, x, y, col, align)
    end

    local function drawBGPanel(pos_x, pos_y, alpha)
        local size_w, size_h = ScrW() * 0.12, ScrH() * 0.075
        local pos_w, pos_h = ScrW() * pos_x, ScrH() * pos_y - size_h
        return { pos_w, pos_h }, { size_w, size_h }
    end


    function CombineClass:HUDPaint(ply)
        local lply = LocalPlayer()
        local frt = FrameTime() * 5
        local role = ply:GetNWString("PlayerRole")
        local is_red = (role == "Shotgunner" or role == "Elite")

        -- HP
        do
            local pos, size = drawBGPanel(0.065, 0.98)
            surface.SetFont("CMBFontDefault")
            local bloodcount = math.Round(100 * (ply.organism and ply.organism.blood or 5000) / 5000, 0)
            local _, txt_size_y = surface.GetTextSize(bloodcount)
            hp_txt = math.min(hp_txt + 1, bloodcount)
            local col_bg = table.Copy(bg_color)
            col_bg.a = 225
            
            draw.DrawText("000", "CMBFontDefaultBG", pos[1] + size[1] * 0.08 + 1, pos[2] + (size[2] / 2) - txt_size_y / 2 + 1, col_bg, TEXT_ALIGN_RIGHT)

            if is_red then
                color_glow2.a = math.Round(Lerp(frt, color_glow2.a, old_hp_txt ~= hp_txt and 255 or 0))
                drawGlowingText(hp_txt, "CMBFontDefault", pos[1] + size[1] * 0.08, pos[2] + (size[2] / 2) - txt_size_y / 2, color_hp2, color_glow2, nil, TEXT_ALIGN_RIGHT)
            else
                color_glow.a = math.Round(Lerp(frt, color_glow.a, old_hp_txt ~= hp_txt and 255 or 0))
                drawGlowingText(hp_txt, "CMBFontDefault", pos[1] + size[1] * 0.08, pos[2] + (size[2] / 2) - txt_size_y / 2, color_hp, color_glow, nil, TEXT_ALIGN_RIGHT)
            end
            old_hp_txt = hp_txt

            draw.DrawText("% | BLOOD", "CMBFontSmall", pos[1] + size[1] * 0.085 + 1, pos[2] + (size[2] / 1.8) + 1, col_bg, TEXT_ALIGN_LEFT)
            draw.DrawText("% | BLOOD", "CMBFontSmall", pos[1] + size[1] * 0.085, pos[2] + (size[2] / 1.8), is_red and color_hp2 or color_hp, TEXT_ALIGN_LEFT)
        end

        -- Pulse
        do
            local pos, size = drawBGPanel(0.035, 0.925)
            surface.SetFont("CMBFontSmall")
            local org = ply.organism
            if org and org.pulse then
                local pulse = org.heartbeat
                pulse_txt = math.Round(math.min(pulse_txt + 1, pulse))
                local col_bg = table.Copy(bg_color)
                col_bg.a = 225

                draw.DrawText(pulse_txt, "CMBFontSmall", pos[1] + size[1] * -0.09, pos[2] + (size[2] / 2), col_bg, TEXT_ALIGN_LEFT)
                draw.DrawText(pulse_txt, "CMBFontSmall", pos[1] + size[1] * -0.095, pos[2] + (size[2] / 2), is_red and color_hp2 or color_hp, TEXT_ALIGN_LEFT)
                draw.DrawText("| HEART.B/MIN", "CMBFontSmall", pos[1] + size[1] * 0.06 + 1 + 10, pos[2] + (size[2] / 2) + 1, col_bg, TEXT_ALIGN_LEFT)
                draw.DrawText("| HEART.B/MIN", "CMBFontSmall", pos[1] + size[1] * 0.06 + 12, pos[2] + (size[2] / 2), is_red and color_hp2 or color_hp, TEXT_ALIGN_LEFT)
            end
        end

        -- Stamina
        do
            local pos, size = drawBGPanel(0.035, 0.895)
            surface.SetFont("CMBFontSmall")
            local org = ply.organism
            if org and org.stamina then
                local stamina = org.stamina[1] or 180
                stamina_txt = math.Round(math.min(stamina_txt + 1, stamina))
                local col_bg = table.Copy(bg_color)
                col_bg.a = 225

                draw.DrawText(stamina_txt, "CMBFontSmall", pos[1] + size[1] * -0.09, pos[2] + (size[2] / 2), col_bg, TEXT_ALIGN_LEFT)
                draw.DrawText(stamina_txt, "CMBFontSmall", pos[1] + size[1] * -0.095, pos[2] + (size[2] / 2), is_red and color_hp2 or color_hp, TEXT_ALIGN_LEFT)
                draw.DrawText("| STAMINA", "CMBFontSmall", pos[1] + size[1] * 0.065 + 1 + 10, pos[2] + (size[2] / 2) + 1, col_bg, TEXT_ALIGN_LEFT)
                draw.DrawText("| STAMINA", "CMBFontSmall", pos[1] + size[1] * 0.065 + 12, pos[2] + (size[2] / 2), is_red and color_hp2 or color_hp, TEXT_ALIGN_LEFT)
            end
        end

        -- Silent mode
        do
            local pos, size = drawBGPanel(0.5, 0.99)
            surface.SetFont("CMBFontSmall")
            silentlerp = LerpFT(0.1, silentlerp, (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 1 or 0)
            local col_bg = table.Copy(bg_color)
            col_bg.a = 225 * silentlerp
            silentclr.a = 225 * silentlerp
            
            draw.DrawText("SNEAK MODE", "CMBFontSmall", pos[1], pos[2] + (size[2] / 2), col_bg, TEXT_ALIGN_CENTER)
            draw.DrawText("SNEAK MODE", "CMBFontSmall", pos[1], pos[2] + (size[2] / 2), silentclr, TEXT_ALIGN_CENTER)
        end

        -- Ammunition
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.Clip1 then
            ammolerp = Lerp(frt, ammolerp, (wep:Clip1() < 0) and 0 or 1)
            local pos, size = drawBGPanel(0.93, 0.98)
            surface.SetFont("CMBFontDefault")
            local _, txt_size_y = surface.GetTextSize(ply:Armor())
            local col_bg = table.Copy(bg_color)
            col_bg.a = 225 * ammolerp
            ammo_txt = math.min(ammo_txt + 1, wep:Clip1())

            draw.DrawText("000", "CMBFontDefaultBG", pos[1] + size[1] * 0.08 + 1, pos[2] + (size[2] / 2) - txt_size_y / 2 + 1, col_bg, TEXT_ALIGN_RIGHT)

            if is_red then
                color_glow_ammo2.a = math.Round(Lerp(frt, color_glow_ammo2.a, old_ammo_txt ~= ammo_txt and 255 or 0))
                drawGlowingText(ammo_txt, "CMBFontDefault", pos[1] + size[1] * 0.08, pos[2] + (size[2] / 2) - txt_size_y / 2, color_ar2, color_glow_ammo2, nil, TEXT_ALIGN_RIGHT)
            else
                color_glow_ammo.a = math.Round(Lerp(frt, color_glow_ammo.a, old_ammo_txt ~= ammo_txt and 255 or 0))
                drawGlowingText(ammo_txt, "CMBFontDefault", pos[1] + size[1] * 0.08, pos[2] + (size[2] / 2) - txt_size_y / 2, color_ar, color_glow_ammo, nil, TEXT_ALIGN_RIGHT)
            end
            old_ammo_txt = ammo_txt

            draw.DrawText("AMMO", "CMBFontSmall", pos[1] + size[1] * 0.085 + 1, pos[2] + (size[2] / 1.8) + 1, col_bg, TEXT_ALIGN_LEFT)
            draw.DrawText("AMMO", "CMBFontSmall", pos[1] + size[1] * 0.085, pos[2] + (size[2] / 1.8), is_red and color_ar2 or color_ar, TEXT_ALIGN_LEFT)
        end
    end

    hook.Add("HUDPaint", "CombineClass_HUD_Render", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or lply.PlayerClassName ~= self.name then return end


        local role = lply:GetNWString("PlayerRole")
        if role == "Elite" or role == "Shotgunner" then
            surface.SetDrawColor(255, 25, 25, 255)
        else
            surface.SetDrawColor(25, 190, 190, 255)
        end
        surface.SetMaterial(cmb_mat)
        surface.DrawTexturedRectRotated((ScrW() / 2) - 5, (ScrH() / 2) - 5, ScrW() + 10, ScrH() + 450, 180)

        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
        CombineClass.HUDPaint(lply)
        render.PopFilterMag()
        render.PopFilterMin()
    end)
end

CombineClass:PlayerHud()
CombineClass:SetHooks()