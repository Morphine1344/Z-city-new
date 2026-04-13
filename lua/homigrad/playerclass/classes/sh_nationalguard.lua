--- @class NationalGuardClass : PlayerClass
local NationalGuardClass = hg.PlayerClass:Extend({
    name = "nationalguard",
    prefixes = {
        MAJ = 0.02,
        CPT = 0.08,
        ["1LT"] = 0.2,
        ["2LT"] = 0.3,
        SMA = 0.5,
        CSM = 0.7,
        SGM = 0.9,
        ["1SG"] = 1.1,
        MSG = 1.3,
        SFC = 2.5,
        SSG = 4.0,
        SGT = 7.0,
        CPL = 8.0,
        SPC = 11.4,
        PFC = 15.0,
        PV2 = 18.0,
        PVT = 29.0
    },
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
        red = 5,
        green = 65,
        blue = 0
    }
})

function NationalGuardClass:On(ply)
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
        top = math.random(0, 1),
        lower = math.random(0, 1),
        vest = 1,
        }
    })

    self:SetColor(ply)
    self:SetName(ply)
end

function NationalGuardClass:Off()
    if CLIENT then
        return
    end
end

function NationalGuardClass:PlayerDeath()
    if CLIENT then 
        return
    end
end

function NationalGuardClass:SetHooks()
    hook.Add("HG_PlayerFootstep", "nationalguard_footsteps", function(ply, pos, foot, sound, volume, rf)
	local chr = hg.GetCurrentCharacter(ply)
	if ply:Alive() and ply.PlayerClassName == NationalGuardClass.name then
		local ent = hg.GetCurrentCharacter(ply)

		if not (ply:IsWalking() or ply:Crouching()) and ent == ply then
			local snd = "zcitysnd/" .. string.Replace(sound, "player/footsteps", "player/footsteps_military/")
			if SoundDuration(snd) <= 0 then
				snd = sound -- missing footsteps fix
			end
			EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95,105)) )

			return true
		end
	end
    end)
end

NationalGuardClass:SetHooks()

