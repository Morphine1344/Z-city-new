--- @class RebelClass : PlayerClass
local RebelClass = hg.PlayerClass:Extend({
    name = "Rebel",
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
    accessories = false,
    color = {
        red = 246,
        green = 139,
        blue = 0
    },
    subclasses = {
        Grenadier = {
            chance = 5,
            weapons = {
                primary = {
                    weapon_hg_rebelrpg = {
                        ammoMultiplier = 1
                    },
                    weapon_hg_rpg = {
                        ammoMultiplier = 1
                    }
                },
                explosive = {
                    weapon_hg_pipebomb_tpik = {}
                }
            },
            equipment = {
                others = {
                    "weapon_hg_slam",
                    "weapon_traitor_ied",
                    "weapon_claymore",
                    "weapon_walkie_talkie"
                }
            }
        },
        Sniper = {
            chance = 15,
            weapons = {
                primary = {
                    weapon_svd = {
                        chance = 20,
                        attachments = {
                            sights = {
                                optic11 = 25,
                                optic4 = 35,
                                nothing = 40
                            },
                            muzzles = {
                                supressor1 = 10,
                                nothing = 90
                            }
                        },
                    },
                    weapon_sks = {
                        chance = 35
                    },
                    weapon_mosin = {
                        chance = 45,
                        attachments = {
                            sights = {
                                optic12 = 25,
                                nothing = 75
                            }
                        }
                    },
                },
                explosive = {
                    weapon_hg_smokenade_tpik = {}
                }
            },
        },
        Medic = {
            chance = 25,
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
            weapons = {
                primary = {
                    weapon_mp7 = {
                        attachments = {
                            sights = {
                                holo14 = 75,
                                nothing = 25
                            }
                        }
                    },
                },
                explosive = {}
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
        Rifleman = {
            chance = 55,
            weapons = {
                primary = {
                    weapon_osipr = {
                        chance = 10
                    },
                    weapon_akm = {
                        chance = 15
                    },
                    weapon_spas12 = {
                        chance = 25
                    },
                    
                    weapon_mp7 = {
                        attachments = {
                            chance = 50,
                            sights = {
                                holo14 = 75,
                                nothing = 25
                            }
                        }
                    },
                },
                explosive = {
                    weapon_hg_hl2nade_tpik = {}
                }
            },
        }
    },
    weapons = {
        secondary = {
            weapon_m9beretta = {},
            weapon_browninghp = {},
            weapon_revolver357 = {},
            weapon_revolver2 = {},
            weapon_hk_usp = {},
            weapon_glock17 = {}
        },
        melee = {
            weapon_hammer = {},
            weapon_buck200knife = {},
            weapon_pocketknife = {},
            weapon_sogknife = {}
        }
    },
    equipment = {
        armor = {
            helmets = {
                "helmet1",
                "helmet7"
            },
            vests = {
                "vest5",
                "vest4",
                "vest1"
            }
        },
        medicine = {
            "weapon_tourniquet"
        },
        others = {
            "weapon_walkie_talkie"
        }
    }
})

function RebelClass:On(ply)
    if CLIENT then
        return
    end

    self:SetSubclass()
    self:GiveLoadout(ply)

    self:SetAppearance(ply, {
        subMaterial = false
    })

    self:SetupModel(ply)
    self:SetColor(ply)
    self:SetName(ply)
    self:SetRole(ply, {
        color = {
            red = 13,
            green = 101,
            blue = 5
        }
    })
end

function RebelClass:Off(ply)
    if CLIENT then
        return
    end
    self:UnsetRole(ply)
end

function RebelClass:PlayerDeath()
    if CLIENT then 
        return
    end
end


