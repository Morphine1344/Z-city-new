--- @class GordonClass : PlayerClass
local GordonClass = hg.PlayerClass:Extend({
    name = "Gordon",
    callsigns = {
        "Gordon"
    },
    models = {
        "models/humans/gordon/group01/gordoncitizen.mdl"
    },
    accessories = false,
    color = {
        red = 246,
        green = 139,
        blue = 0
    },
    subclasses = {
        Rebel = {
            weapons = {
                primary = {
                    weapon_hg_crossbow = {
                        chance = 10,
                        ammoMultiplier = 9
                    },
                    weapon_osipr = {
                        chance = 15,
                        ammoMultiplier = 4
                    },
                    weapon_akm = {
                        chance = 20,
                        ammoMultiplier = 5
                    },
                    weapon_spas12 = {
                        chance = 25,
                        ammoMultiplier = 4
                    },
                    weapon_mp7 = {
                        chance = 30,
                        ammoMultiplier = 4,
                        attachments = {
                            sights = {
                                holo14 = 100
                            }
                        }
                    }
                },
                secondary = {
                    weapon_hk_usp = {},
                    weapon_revolver357 = {}
                },
                melee = {
                    weapon_hg_crowbar = {}
                },
                explosive = {
                    weapon_hg_hl2nade_tpik = {
                        count = 3
                    }
                }
            },
            equipment = {
                others = {
                    "weapon_physcannon",
                    "weapon_hg_slam",
                    "weapon_walkie_talkie"
                }
            }
        },
        Refugee = {
            weapons = {
                secondary = {
                    weapon_hk_usp = {}
                },
                melee = {
                    weapon_hg_crowbar = {}
                }
            }
        },
        Citizen = {}
    },
    hevSuit = {
        maxMorphine = 4,
        maxMedicine = 600,
        maxPower = 100
    }
})

function GordonClass:On(ply, data)
    if CLIENT then
        return
    end

    local equipment = data and data.equipment
    local bRestored = data and data.bRestored

    if not equipment or (not equipment == "rebel" or not equipment == "refugee") then
        self.subclass.name = "Citizen"
    else
        if equipment == "rebel" then
            self.subclass.name = "Rebel"

        elseif equipment == "refugee" then
            self.subclass.name = "Refugee"

            if game.GetMap() == "d1_canals_01" then
                self.subclasses.Refugee.weapons.secondary = {}
            end

            if game.GetMap() == "d1_trainstation_06" then
                self.subclasses.Refugee.weapons = {}
            end
        end
    end

    self:SetSubclass({
        name = self.subclass.name
    })

    self:GiveLoadout(ply)

    if not self.subclass.name == "citizen" and not bRestored then
        timer.Simple(1, function()
            for i, ent in pairs(ents.FindByClass("item_suit")) do
                ent:Remove()
            end
        end)

        self:HevCreate(ply)

    elseif bRestored and not self.subclass.name == "Citizen" then
        self:HevCreate(ply)
        self:HevChanged(ply)
    end

    if not ply:GetNetVar("HEVSuit") or ply:GetNetVar("HEVSuit") == false then
        self:SetAppearance(ply, {
            subMaterial = false
        })
        self:SetupModel(ply)
    end

    self:SetRole(ply, {
        name = "Freeman"
    })

    self:SetColor(ply)

    self:SetName(ply, {
        withName = false
    })
end

function GordonClass:Off(ply)
    if CLIENT then
        return
    end

    self:UnsetRole(ply)

    self:HevRemove(ply)
end

function GordonClass:PlayerDeath(ply)
    if CLIENT then
        return
    end
end

function GordonClass:HevCreate(ply, parameters)
    parameters = self:AddDefault(parameters, {
        hevSuit = {
            morphine = self.hevSuit.maxMorphine,
            medicine = self.hevSuit.maxMedicine,
            power = self.hevSuit.maxPower
        }
    })

    ply.organism.recoilmul = 0.2
    ply.organism.meleespeed = 2
    ply.HEV = {}
    ply.HEV.Morphine = parameters.hevSuit.morphine
    ply.HEV.Medicine = parameters.hevSuit.medicine
    ply.HEV.Power = parameters.hevSuit.power * (0.75)
    ply.organism.HEV = ply.HEV
    ply:SetNetVar("HEVMedicine", ply.HEV.Medicine)
    ply:SetNetVar("HEVPower", ply.HEV.Power)
    ply:SetNetVar("HEVSuit", true)
    ply:SetModel("models/gfreakman/gordonf_highpoly.mdl")
    ply:SetSubMaterial()
    ply.organism.CantCheckPulse = true
    ply.armors = {}
    ply.armors["torso"] = "gordon_armor"
    ply.armors["head"] = "gordon_helmet"
    ply:SyncArmor()

    self:HevChanged(ply)
end

function GordonClass:HevRemove(ply)
    ply.organism.recoilmul = 1
    ply.organism.meleespeed = 1
    ply.HEV = nil
    ply.organism.HEV = nil
    ply:SetNetVar("HEVMedicine", nil)
    ply:SetNetVar("HEVPower", nil)
    ply:SetNetVar("HEVSuit", nil)
    ply.organism.CantCheckPulse = false
    ply.armors = nil
    ply:SyncArmor()

    self:SetAppearance(ply, {
        subMaterial = false
    })
    self:SetupModel(ply)
end

function GordonClass:HevChanged(ply)
    if not ply.HEV or not ply.HEV.Power then return end

    local hevpow = (ply.HEV.Power / self.hevSuit.maxPower)
    ply.organism.recoilmul = 1 - 0.8 * hevpow
    ply.organism.meleespeed = 1 + 1 * hevpow
    ply.organism.stamina.regen = 1 + 3 * hevpow
end

function GordonClass:SetHooks()
    if SERVER then
        hook.Add("PostCleanupMap", "replaceItemsInCoop", function(ent)
            timer.Simple(1, function()
                for i, ent in ents.Iterator() do
                    if ent:GetClass() == "item_suitcharger" then
                        local entNew = ents.Create("prop_physics")
                        entNew:SetModel(ent:GetModel())
                        entNew:SetPos(ent:GetPos())
                        entNew:SetAngles(ent:GetAngles())
                        entNew.armorcharger = true
                        entNew.power = 100
                        entNew:Spawn()

                        local phys = entNew:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:EnableMotion(false)
                        end

                        timer.Simple(0.1, function()
                            ent:Remove()
                        end)
                    end

                    if ent:GetClass() == "item_healthcharger" then
                        local entNew = ents.Create("prop_physics")
                        entNew:SetModel(ent:GetModel())
                        entNew:SetPos(ent:GetPos())
                        entNew:SetAngles(ent:GetAngles())
                        entNew.healthcharger = true
                        entNew.power = 100
                        entNew:Spawn()

                        local phys = entNew:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:EnableMotion(false)
                        end

                        timer.Simple(0.1, function()
                            ent:Remove()
                        end)
                    end
                end
            end)
        end)

        util.AddNetworkString("HEV_DAMAGE")

        local CheckBones = {
            "spine3",
            "spine2",
            "spine1",
            "rleg",
            "lleg",
            "rarm",
            "larm",
            "skull",
            "chest",
            "pelvis"
        }

        local phrases = {
            "Gordon Freeman has died. Now what?",
            "He's dead. Who will lead the way now?",
            "Gordon Freeman has failed his mission.",
            "What an unfortunate end to such a good employee.",
        }

        local hev_color = Color(255, 125, 0)
        local dead_color = Color(255, 0, 0)

        hook.Add("Org Think", "gordonHealing", function(ply, org, timeValue)
            if org.HEV and not org.alive and not org.emitflatline then
                org.emitflatline = true
                hg.GetCurrentCharacter(ply):EmitSound("hl1/fvox/flatline.wav")

                if CurrentRound and CurrentRound().name == "coop" then
                    if zChatPrint then
                        zChatPrint(dead_color, phrases[math.random(#phrases)])
                    else
                        PrintMessage(HUD_PRINTTALK, phrases[math.random(#phrases)])
                    end
                end
            end

            if not ply:IsPlayer() or not ply:Alive() then return end

            if ply.PlayerClassName == self.name and ply:GetNetVar("HEVSuit") then
                ply:SetNetVar("HEVMedicine", ply.HEV.Medicine)
                if org.brain > 0.1 then
                    org.mannitol = org.brain * 2
                    ply:Notify("HEV suit has detected a traumatic brain injury. Injecting mannitol.", true,
                        "mannitol_hev", 0.5, function(ply)
                            net.Start("HEV_DAMAGE")
                            net.WriteString("hl1/fvox/automedic_on.wav")
                            net.Send(ply)
                        end, hev_color)
                else
                    ply:ResetNotification("mannitol_hev")
                end

                if org.pneumothorax > 0 then
                    org.lungsR[2] = 0
                    org.lungsL[2] = 0
                    org.pneumothorax = 0
                    org.needle = 0

                    ply:Notify("HEV suit has detected pneumothorax. Repairing.", true, "needle_hev", 0.5, function(ply)
                        net.Start("HEV_DAMAGE")
                        net.WriteString("hl1/fvox/automedic_on.wav")
                        net.Send(ply)
                    end, hev_color)
                end

                local pain = org.pain + org.shock * 3
                if pain > 30 then
                    if (org.NextMorphineInject or 0) < CurTime() then
                        org.NextMorphineInject = CurTime() + 10

                        local need = math.min(ply.HEV.Morphine, pain / 80)
                        local old = org.analgesia
                        org.analgesia = math.max(math.min(org.analgesia + need, pain / 80, 1), org.analgesia)
                        local administer = (org.analgesia - old)
                        ply.HEV.Morphine = ply.HEV.Morphine - administer

                        if administer > 0.1 then
                            ply:Notify(
                                "HEV suit has detected pain receptors almost reaching the threshold. Injecting morphine.",
                                10, "morphine_hev", 0.5,
                                function(ply)
                                    net.Start("HEV_DAMAGE")
                                    net.WriteString("hl1/fvox/morphine_shot.wav")
                                    net.Send(ply)
                                end, hev_color)
                        end
                    end
                end

                if (org.CO > 10) or (org.COregen > 10) then
                    ply:Notify("HEV suit has detected a carbon monoxide presence in the organism. Neutralising.", 60,
                        "co_hev", 0.5, function(ply)
                            net.Start("HEV_DAMAGE")
                            net.WriteString("hl1/fvox/automedic_on.wav")
                            net.Send(ply)
                        end, hev_color)

                    if (org.COThink or 0) < CurTime() then
                        org.COThink = CurTime() + (1 / 120) * 60

                        if org.alive then
                            org.o2[1] = math.min(org.o2[1] + hg.organism.OxygenateBlood(org) * 2, org.o2.range)
                            org.CO = math.Approach(org.CO, 0, 2)
                            org.COregen = math.Approach(org.COregen, 0, 2)
                        end
                    end
                end

                if (org.BoneCheck or 0) < CurTime() then
                    org.BoneCheck = CurTime() + 10

                    local bonesFixed = false
                    for _, v in ipairs(CheckBones) do
                        if org[v] > 0 then
                            local old = org[v]
                            org[v] = math.max(org[v] - ply.HEV.Medicine, 0)
                            ply.HEV.Medicine = math.max(ply.HEV.Medicine - (old - org[v]) * 10, 0)

                            if old == 1 then bonesFixed = true end
                        end
                    end

                    if bonesFixed then
                        ply:Notify("HEV suit has detected fractures. Repairing.", 60, "bones_hev", 0.5, function(ply)
                            net.Start("HEV_DAMAGE")
                            net.WriteString("hl1/fvox/automedic_on.wav")
                            net.Send(ply)
                        end, hev_color)
                    end
                end

                if org.bleed > 5 then
                    if (org.BleedThink or 0) < CurTime() then
                        org.BleedThink = CurTime() + 1

                        for i, wound in pairs(org.wounds) do
                            local old = wound[1]
                            wound[1] = math.max(wound[1] - 5, 0)
                            ply.HEV.Medicine = math.max(ply.HEV.Medicine - (-wound[1] + old), 0)
                        end
                    end
                end

                if ply.HEV.Medicine > 300 then
                    local regen = timeValue / 30

                    org.lleg = math.max(org.lleg - regen, 0)
                    org.rleg = math.max(org.rleg - regen, 0)
                    org.rarm = math.max(org.rarm - regen, 0)
                    org.larm = math.max(org.larm - regen, 0)
                    org.chest = math.max(org.chest - regen, 0)
                    org.pelvis = math.max(org.pelvis - regen, 0)
                    org.spine1 = math.max(org.spine1 - regen, 0)
                    org.spine2 = math.max(org.spine2 - regen, 0)
                    org.spine3 = math.max(org.spine3 - regen, 0)
                    org.skull = math.max(org.skull - regen, 0)

                    org.liver = math.max(org.liver - regen, 0)
                    org.intestines = math.max(org.intestines - regen, 0)
                    org.heart = math.max(org.heart - regen, 0)
                    org.stomach = math.max(org.stomach - regen, 0)
                    org.lungsR[1] = math.max(org.lungsR[1] - regen, 0)
                    org.lungsL[1] = math.max(org.lungsL[1] - regen, 0)
                    org.lungsR[2] = math.max(org.lungsR[2] - regen, 0)
                    org.lungsL[2] = math.max(org.lungsL[2] - regen, 0)
                    org.brain = math.max(org.brain - regen * 0.1, 0)
                end

                if (org.pulse < 40) or (org.blood < 3000) or (org.o2[1] < 10) then
                    ply:Notify(
                        "HEV suit has detected a critically low pulse. Epinephrine injected. Auto-pulse enabled. Plasma injected.",
                        60, "pulse_hev", 0.5, function(ply)
                            net.Start("HEV_DAMAGE")
                            net.WriteString("hl1/fvox/health_critical.wav")
                            net.Send(ply)
                        end, hev_color)

                    if (org.BloodThink or 0) < CurTime() then
                        org.BloodThink = CurTime() + 4

                        if org.blood < 4000 then
                            local needed = math.min(4000 - org.blood, 500, ply.HEV.Medicine / 6)
                            ply.HEV.Medicine = math.max(ply.HEV.Medicine - needed / 10, 0)
                            org.blood = org.blood + needed

                            org.adrenalineAdd = 4
                        end
                    end

                    if (org.CPRThink or 0) < CurTime() then
                        org.CPRThink = CurTime() + (1 / 120) * 60

                        if org.alive then
                            org.o2[1] = math.min(org.o2[1] + hg.organism.OxygenateBlood(org) * 2, org.o2.range)
                            org.pulse = math.min(org.pulse + 5, 70)
                            org.CO = math.Approach(org.CO, 0, 1)
                            org.COregen = math.Approach(org.COregen, 0, 1)
                            if org.pulse > 15 then org.heartstop = false end
                        end
                    end
                end
            end
        end)

        hook.Add("HomigradDamage", "HevMedical", function(ply, dmgInfo, hitgroup, ent, entharm)
            if ply.PlayerClassName == self.name and ply:GetNetVar("HEVSuit") then
                timer.Simple(0, function()
                    timer.Create("HEV_CheckDMG", 2, 1, function()
                        if not IsValid(ply) or not ply:Alive() or ply.PlayerClassName ~= self.name or ply.HEV.Medicine <= 0 then return end

                        if ply:Health() < 35 then
                            net.Start("HEV_DAMAGE")
                            net.WriteString("hl1/fvox/health_critical.wav")
                            net.Send(ply)
                        end
                    end)

                    timer.Create("HEV_CheckHP", 10, 1, function()
                        if not IsValid(ply) or not ply:Alive() or ply.PlayerClassName ~= self.name or ply.HEV.Medicine <= 0 then return end
                        if not entharm or entharm < 1 then return end

                        local org = ply.organism

                        net.Start("HEV_DAMAGE")
                        net.WriteString("hl1/fvox/automedic_on.wav")
                        net.Send(ply)

                        local oldMedicine = ply.HEV.Medicine

                        timer.Create("HEV_CheckHP", 5, 1, function()
                            local ammoutNeeds = 0

                            for _, v in ipairs(CheckBones) do
                                if not istable(org[v]) and org[v] > 0 then
                                    local needed = (1 - org[v]) * 10
                                    org[v] = math.max(org[v] - ply.HEV.Medicine, 0)
                                    ply.HEV.Medicine = math.max(ply.HEV.Medicine - needed, 0)
                                end

                                if istable(org[v]) then
                                    for k, w in pairs(org[v]) do
                                        local needed = (1 - w) * 10
                                        w = math.max(w - ply.HEV.Medicine, 0)
                                        ply.HEV.Medicine = math.max(ply.HEV.Medicine - needed, 0)
                                    end
                                end
                            end

                            if oldMedicine ~= ply.HEV.Medicine then
                                net.Start("HEV_DAMAGE")
                                net.WriteString("hl1/fvox/medical_repaired.wav")
                                net.Send(ply)
                            end
                        end)
                    end)

                    if #ply.organism.wounds > 0 or #ply.organism.arterialwounds > 0 or ply.organism.internalBleed > 0 then
                        if ply.organism.bleed > 0.025 and (not ply.HEV.BloodLossDetect or ply.HEV.BloodLossDetect < CurTime()) then
                            snd = "hl1/fvox/blood_loss.wav"
                            if ply.organism.internalBleed > 0.02 then
                                snd = "hl1/fvox/internal_bleeding.wav"
                            end
                            net.Start("HEV_DAMAGE")
                            net.WriteString(snd)
                            net.Send(ply)

                            ply.HEV.BloodLossDetect = CurTime() + 5
                        end

                        timer.Create("HEV_StopBleed", 5, 1, function()
                            if not IsValid(ply) or not ply:Alive() or ply.PlayerClassName ~= self.name or ply.HEV.Medicine <= 0 then return end

                            local bleedneedRemove = ply.organism.bleed
                            local bleedInterNeedRemove = ply.organism.internalBleed

                            ply.organism.internalBleed = math.max(ply.organism.internalBleed - ply.HEV.Medicine, 0)

                            ply.HEV.Medicine = math.max(ply.HEV.Medicine - bleedneedRemove, 0)
                            ply.HEV.Medicine = math.max(ply.HEV.Medicine - bleedInterNeedRemove, 0)

                            table.Empty(ply.organism.wounds)

                            ply.HEV.Medicine = ply.HEV.Medicine - #ply.organism.arterialwounds * 2.5
                            local snd = "hl1/fvox/bleeding_stopped.wav"
                            if #ply.organism.arterialwounds > 0 then
                                snd = "hl1/fvox/torniquette_applied.wav"
                            end

                            for i, wound in pairs(ply.organism.arterialwounds) do
                                wound[1] = 0
                            end

                            ply:SetNetVar("arterialwounds", ply.organism.arterialwounds)
                            ply:SetNetVar("wounds", ply.organism.wounds)
                            if ply.organism.bleed > 0.025 then
                                net.Start("HEV_DAMAGE")
                                net.WriteString(snd)
                                net.Send(ply)
                            end
                            ply.HEV.Medicine = math.max(ply.HEV.Medicine, 0)
                        end)
                    end
                end)
            end
        end)
    end

    if CLIENT then
        local queen = {}
        net.Receive("HEV_DAMAGE", function()
            local armors = lply.armors
            if not armors then return end
            if armors["head"] ~= "gordon_helmet" then return end
            queen[#queen + 1] = net.ReadString()
        end)
        local inPlaying = 0
        hook.Add("Think", "HevNotify", function()
            local armors = lply.armors
            if not lply:Alive() and #queen > 0 then
                queen = {}
                return
            end
            if not armors then return end
            if armors["head"] ~= "gordon_helmet" then return end
            if inPlaying < CurTime() - 0.1 and queen[#queen] and not lply.organism.otrub then
                inPlaying = CurTime() + SoundDuration(queen[#queen])
                surface.PlaySound(queen[#queen])
                queen[#queen] = nil
            end
        end)

        hook.Add("RenderScreenspaceEffects", "HevHelmetHud", function()
            if not lply:GetNetVar("HEVSuit") then return end

            if lply.armors["head"] ~= "gordon_helmet" then return end
            if lply:Alive() and lply.PlayerClassName == self.name then
                local hevMat = Material("sprites/mat_jack_helmoverlay_r")
                surface.SetDrawColor(255, 132, 0, 200)
                surface.SetMaterial(hevMat)
                surface.DrawTexturedRectRotated((ScrW() / 2) - 5, (ScrH() / 2) - 5, ScrW() + 10, ScrH() + 450, 180)
            end
            render.PushFilterMag(TEXFILTER.ANISOTROPIC)
            render.PushFilterMin(TEXFILTER.ANISOTROPIC)
            GordonClass:HUDPaint(lply)
            render.PopFilterMag()
            render.PopFilterMin()
        end)
    end

    hook.Add("WeaponEquip", "gordonPickUpCrowbar", function(wep, ply)
        if ply.PlayerClassName == self.name and wep:GetClass() == "weapon_hg_crowbar" then
            wep:Remove()
            local weapon = ply:Give("weapon_hg_crowbar_gordon")
            ply:SelectWeapon(weapon)
        elseif ply.PlayerClassName ~= self.name and wep:GetClass() == "weapon_hg_crowbar_gordon" then
            wep:Remove()
            local weapon = ply:Give("weapon_hg_crowbar")
            ply:SelectWeapon(weapon)
        end
    end)

    hook.Add("HG_CanThoughts", "gordonCanThoughts", function(ply)
        if ply.PlayerClassName == self.name then
            return false
        end
    end)

    hook.Add("PlayerCanPickupItem", "gordonPickupHevSuit", function(ply, ent)
        local entclass = ent:GetClass()
        if entclass == "item_suit" then
            if ply.PlayerClassName == self.name and not ply:GetNetVar("HEVSuit") then
                self:HevCreate(ply)
            else
                return false
            end
        end

        if entclass == "item_healthvial" then
            if ply.PlayerClassName == self.name and ply:GetNetVar("HEVSuit") then
                local noneedhealth = (ply:Health() == 100) and (ply.HEV.Medicine == self.hevSuit.maxMedicine) and
                    (ply.HEV.Morphine == self.hevSuit.maxMorphine)
                if noneedhealth then return false end
                ply.HEV.Medicine = math.min(ply.HEV.Medicine + 100, self.hevSuit.maxMedicine)
                if ply:Health() == 100 then ply:SetHealth(99) end
            else
                return false
            end
        end

        if entclass == "item_healthkit" then
            if ply.PlayerClassName == self.name and ply:GetNetVar("HEVSuit") then
                local noneedhealth = (ply:Health() == 100) and (ply.HEV.Medicine == self.hevSuit.maxMedicine) and
                    (ply.HEV.Morphine == self.hevSuit.maxMorphine)
                if noneedhealth then return false end
                ply.HEV.Medicine = math.min(ply.HEV.Medicine + 250, self.hevSuit.maxMedicine)
                ply.HEV.Morphine = math.min(ply.HEV.Morphine + 1, self.hevSuit.maxMorphine)
                if ply:Health() == 100 then ply:SetHealth(99) end
            else
                return false
            end
        end

        if entclass == "item_battery" then
            if ply.PlayerClassName == self.name and ply:GetNetVar("HEVSuit") then
                local noneedarmor = ply.HEV.Power == self.hevSuit.maxPower
                if noneedarmor then return false end
                ply.HEV.Power = math.min(ply.HEV.Power + 25, self.hevSuit.maxPower)
                ply:SetNetVar("HEVPower", ply.HEV.Power)
                ply:SetArmor(0)
                self:HevChanged(ply)
            else
                return false
            end
        end
    end)

    hook.Add("Player Think", "gordonHealthAndArmorHevSuit", function(ply)
        if not (ply.PlayerClassName == self.name and ply:GetNetVar("HEVSuit")) then return end
        local ent = hg.eyeTrace(ply).Entity
        if not (ent.armorcharger or ent.healthcharger) then return end
        if (ent.ThinkCharge or 0) > CurTime() then return end
        ent:SetCycle(1 - ent.power / 100)

        if not ply:KeyDown(IN_USE) then
            ply.keypresseduse = nil
            if ent.snd then
                ent:StopLoopingSound(ent.snd)
                ent.snd = nil
            end
            return
        end

        ent.ThinkCharge = CurTime() + 0.25

        if ent.power > 0 then
            timer.Create("huasd" .. ent:EntIndex(), 1, 1, function()
                if ent.snd then
                    ent:StopLoopingSound(ent.snd)
                    ent.snd = nil
                end
            end)

            if ent.armorcharger then
                local noneedarmor = ply.HEV.Power == self.hevSuit.maxPower
                if noneedarmor then
                    if not ply.keypresseduse then
                        ent:EmitSound(ent.armorcharger and "items/suitchargeno1.wav" or "items/medshotno1.wav")
                    end
                    ply.keypresseduse = true
                    if ent.snd then
                        ent:StopLoopingSound(ent.snd)
                        ent.snd = nil
                    end
                    return
                end

                if not ply.keypresseduse then
                    ent:EmitSound("items/suitchargeok1.wav")

                    ent.snd = ent:StartLoopingSound("items/suitcharge1.wav")
                end

                ply.HEV.Power = math.min(ply.HEV.Power + 1, self.hevSuit.maxPower)
                ply:SetNetVar("HEVPower", ply.HEV.Power)
                self:HevChanged(ply)
                ent.power = ent.power - 1
            else
                local noneedhealth = (ply:Health() == 100) and (ply.HEV.Medicine == self.hevSuit.maxMedicine) and
                    (ply.HEV.Morphine == self.hevSuit.maxMorphine)

                if noneedhealth then
                    if not ply.keypresseduse then
                        ent:EmitSound(ent.armorcharger and "items/suitchargeno1.wav" or "items/medshotno1.wav")
                    end
                    ply.keypresseduse = true
                    if ent.snd then
                        ent:StopLoopingSound(ent.snd)
                        ent.snd = nil
                    end
                    return
                end

                if not ply.keypresseduse then
                    ent:EmitSound("items/medshot4.wav")

                    ent.snd = ent:StartLoopingSound("items/medcharge4.wav")
                end

                ply.HEV.Medicine = math.min(ply.HEV.Medicine + 5, self.hevSuit.maxMedicine)
                ply.HEV.Morphine = math.min(ply.HEV.Morphine + 0.01, self.hevSuit.maxMorphine)
                ply:SetHealth(math.min(ply:Health() + 1, 100))
                ent.power = ent.power - 1
            end
        else
            if not ply.keypresseduse then
                ent:EmitSound(ent.armorcharger and "items/suitchargeno1.wav" or "items/medshotno1.wav")
            end
            if ent.snd then
                ent:StopLoopingSound(ent.snd)
                ent.snd = nil
            end
        end

        ply.keypresseduse = true
    end)

    hook.Add("HomigradDamage", "gordonTakeArmor", function(ply, dmginfo, hitgroup, ent, harm)
        if not (ply.PlayerClassName == self.name and ply:GetNetVar("HEVSuit")) then return end

        if dmginfo:IsDamageType(DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION) then return end

        local sub = math.Round(dmginfo:GetDamage() / 4, 0)
        ply.HEV.Power = math.Clamp(ply.HEV.Power - sub, 0, self.hevSuit.maxPower)
        ply:SetNetVar("HEVPower", ply.HEV.Power)

        self:HevChanged(ply)
    end)

    hook.Add("CanListenOthers", "GordonWeDontHearYou", function(talker)
        if talker:Alive() and talker.PlayerClassName == self.name then
            return false, false
        end
    end)

    hook.Add("HG_PlayerSay", "GordonWeDontSeeYouChat", function(ply, txtTbl, text)
        if ply:Alive() and ply.PlayerClassName == self.name then
            txtTbl[1] = ""
        end
    end)
end

function GordonClass:PlayerHud()
    if CLIENT then
        local BGColor = Color(0, 0, 0, 255)

        local function drawBGPanel(PosX, PosY, alpha)
            local sizeW, sizeH = ScrW() * 0.12, ScrH() * 0.075
            local posW, posH = ScrW() * PosX, ScrH() * PosY - sizeH

            return { posW, posH }, { sizeW, sizeH }
        end
        local armorlerp = 0

        surface.CreateFont("HEVFontDefault", {
            font = "Bahnschrift",
            extended = true,
            size = ScreenScale(24),
            weight = 500,
            blursize = 0,
            scanlines = 2,
            antialias = true
        })

        surface.CreateFont("HEVFontSmall", {
            font = "Bahnschrift",
            extended = true,
            size = ScreenScale(7.5),
            weight = 1500,
            blursize = 0,
            scanlines = 2,
            antialias = true
        })

        surface.CreateFont("HEVFontSmallBG", {
            font = "Bahnschrift",
            extended = true,
            size = ScreenScale(7.5),
            weight = 500,
            blursize = 1,
            scanlines = 2,
            antialias = true
        })

        surface.CreateFont("HEVFontDefaultBG", {
            font = "Bahnschrift",
            extended = true,
            size = ScreenScale(24.5),
            weight = 1500,
            blursize = 1,
            scanlines = 2,
            antialias = true
        })

        local color_hp1 = Color(255, 155, 0)
        local color_crit = Color(255, 0, 0)
        local color_ar = Color(255, 155, 0)
        local color_glow = Color(255, 155, 0, 0)
        local color_glow_ar = Color(255, 155, 0, 0)
        local color_glow_ammo = Color(255, 155, 0, 0)
        local color_bld = Color(255, 155, 0)
        local color_sight = Color(255, 155, 0, 220)
        local armorTxt = 0
        local hpTxt = 0
        local BloodTxt = 0
        local bloodlerp = 0
        local ammoTxt = 0
        local ammolerp = 0
        local bloodOld = 5000
        local oldHpTxt = 0
        local oldArTxt = 0
        local oldAmmoTxt = 0
        local posSight = Vector(ScrW(), ScrH(), 0)

        function GordonClass:HUDPaint(ply)
            if not ply:Alive() then return end
            if not ply:GetNetVar("HEVSuit") then return end
            --HP
            local FRT = FrameTime() * 5
            local pos, size = drawBGPanel(0.065, 0.98)
            surface.SetFont("HEVFontDefault")
            local _, txtSizeY = surface.GetTextSize(math.Round(lply:GetNetVar("HEVMedicine", 600) / 6, 0))
            hpTxt = math.min(hpTxt + 1, math.Round(lply:GetNetVar("HEVMedicine", 600) / 6, 0))
            local color_bg = BGColor
            color_bg.a = 225
            draw.DrawText("000", "HEVFontDefaultBG", pos[1] + size[1] * 0.08 + 1, pos[2] + (size[2] / 2) - txtSizeY / 2 +
            1, color_bg, TEXT_ALIGN_RIGHT)

            color_glow.a = math.Round(Lerp(FRT, color_glow.a, oldHpTxt ~= hpTxt and 255 or 0))

            local color_hp = color_hp1:Lerp(color_crit, (1 - hpTxt / 25) * math.abs(math.cos(CurTime() * 2)))

            draw.GlowingText(hpTxt, "HEVFontDefault", pos[1] + size[1] * 0.08, pos[2] + (size[2] / 2) - txtSizeY / 2,
                color_hp, color_glow, nil, TEXT_ALIGN_RIGHT)
            oldHpTxt = hpTxt

            draw.DrawText("Medicine", "HEVFontSmall", pos[1] + size[1] * 0.085 + 1, pos[2] + (size[2] / 1.8) + 1,
                color_bg, TEXT_ALIGN_LEFT)
            draw.DrawText("Medicine", "HEVFontSmall", pos[1] + size[1] * 0.085, pos[2] + (size[2] / 1.8), color_hp,
                TEXT_ALIGN_LEFT)

            local armor = ply:GetNetVar("HEVPower") or 0
            armorlerp = Lerp(FRT, armorlerp, armor > 1 and 1 or 0)
            local pos, size = drawBGPanel(0.17, 0.98, 125 * (armor > 1 and 1 or 0))
            surface.SetFont("HEVFontDefault")
            local _, txtSizeY = surface.GetTextSize(armor)
            local color_bg = BGColor
            color_bg.a = 225 * armorlerp
            color_ar.a = 255 * armorlerp
            armorTxt = math.min(armorTxt + 1, armor)
            draw.DrawText("000", "HEVFontDefaultBG", pos[1] + size[1] * 0.08 + 1, pos[2] + (size[2] / 2) - txtSizeY / 2 +
            1, color_bg, TEXT_ALIGN_RIGHT)

            draw.DrawText(armorTxt, "HEVFontDefault", pos[1] + size[1] * 0.08, pos[2] + (size[2] / 2) - txtSizeY / 2,
                color_ar, TEXT_ALIGN_RIGHT)
            color_glow_ar.a = math.Round(Lerp(FRT, color_glow_ar.a, oldArTxt ~= armorTxt and 255 or 0))
            draw.GlowingText(armorTxt, "HEVFontDefault", pos[1] + size[1] * 0.08, pos[2] + (size[2] / 2) - txtSizeY / 2,
                color_ar, color_glow_ar, nil, TEXT_ALIGN_RIGHT)
            oldArTxt = armorTxt
            draw.DrawText("Armor", "HEVFontSmall", pos[1] + size[1] * 0.085 + 1, pos[2] + (size[2] / 1.8) + 1, color_bg,
                TEXT_ALIGN_LEFT)
            draw.DrawText("Armor", "HEVFontSmall", pos[1] + size[1] * 0.085, pos[2] + (size[2] / 1.8), color_ar,
                TEXT_ALIGN_LEFT)
            -- Sights
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) then
                if not IsValid(wep) or not wep.GetTrace then return end
                local tr = wep:GetTrace(true)
                posSight = LerpVector(FRT * 5, posSight, Vector(tr.HitPos:ToScreen().x, tr.HitPos:ToScreen().y, 0))
                color_sight.a = Lerp(FRT * 5, color_sight.a, lply:KeyDown(IN_ATTACK2) and 0 or 255)

                draw.RoundedBox(0, posSight.x - 1, posSight.y + 2, 2, 6, color_sight)
                draw.RoundedBox(0, posSight.x - 1, posSight.y - 8, 2, 6, color_sight)
                draw.RoundedBox(0, posSight.x + 2, posSight.y - 1, 6, 2, color_sight)
                draw.RoundedBox(0, posSight.x - 8, posSight.y - 1, 6, 2, color_sight)
            end
            --Ammo
            if IsValid(wep) and wep.Clip1 then
                local FRT = FrameTime() * 5
                ammolerp = Lerp(FRT, ammolerp, wep:Clip1() < 0 and 0 or 1)
                local pos, size = drawBGPanel(0.93, 0.98)
                surface.SetFont("HEVFontDefault")
                local _, txtSizeY = surface.GetTextSize(ply:Armor())
                local color_bg = BGColor
                color_bg.a = 225 * ammolerp
                color_ar.a = 255 * ammolerp
                ammoTxt = math.min(ammoTxt + 1, wep:Clip1())
                draw.DrawText("000", "HEVFontDefaultBG", pos[1] + size[1] * 0.08 + 1, pos[2] + (size[2] / 2) - txtSizeY /
                2 + 1, color_bg, TEXT_ALIGN_RIGHT)
                --draw.DrawText( ammoTxt, "HEVFontDefault",pos[1]+size[1]*0.08,pos[2]+(size[2]/2) - txtSizeY/2,color_ar,TEXT_ALIGN_RIGHT)

                color_glow_ammo.a = math.Round(Lerp(FRT, color_glow_ammo.a, oldAmmoTxt ~= ammoTxt and 255 or 0))
                draw.GlowingText(ammoTxt, "HEVFontDefault", pos[1] + size[1] * 0.08, pos[2] + (size[2] / 2) - txtSizeY /
                2, color_ar, color_glow_ammo, nil, TEXT_ALIGN_RIGHT)
                oldAmmoTxt = ammoTxt

                draw.DrawText("Ammo", "HEVFontSmall", pos[1] + size[1] * 0.085 + 1, pos[2] + (size[2] / 1.8) + 1,
                    color_bg, TEXT_ALIGN_LEFT)
                draw.DrawText("Ammo", "HEVFontSmall", pos[1] + size[1] * 0.085, pos[2] + (size[2] / 1.8), color_ar,
                    TEXT_ALIGN_LEFT)
            end
            --Blood
            local pos, size = drawBGPanel(0.035, 0.93)
            surface.SetFont("HEVFontSmall")
            if not ply.organism or not ply.organism.blood then return end
            bloodlerp = Lerp(FRT, bloodlerp, ply.organism.blood > 4900 and 0 or 1)
            bloodOld = ply.organism.blood
            local _, txtSizeY = surface.GetTextSize(ply.organism.blood)
            BloodTxt = math.Round(math.min(BloodTxt + 25, ply.organism.blood))

            local color_bg = BGColor
            color_bg.a = 125 * bloodlerp
            color_bld.a = 255 * bloodlerp

            draw.DrawText(BloodTxt, "HEVFontSmall", pos[1] + size[1] * -0.09, pos[2] + (size[2] / 2), color_bg,
                TEXT_ALIGN_LEFT)
            draw.DrawText(BloodTxt, "HEVFontSmall", pos[1] + size[1] * -0.09, pos[2] + (size[2] / 2), color_bld,
                TEXT_ALIGN_LEFT)
            draw.DrawText("Blood/Ml", "HEVFontSmall", pos[1] + size[1] * 0.085 + 1, pos[2] + (size[2] / 2) + 1, color_bg,
                TEXT_ALIGN_LEFT)
            draw.DrawText("Blood/Ml", "HEVFontSmall", pos[1] + size[1] * 0.085, pos[2] + (size[2] / 2), color_bld,
                TEXT_ALIGN_LEFT)
        end
    end
end

GordonClass:PlayerHud()
GordonClass:SetHooks()