--- @author Morphine

--- @class PlayerClass
--- @field name string # Название класса
--- @field prefixes? table<string, number> # Префиксы в имени игрока (сумма шансов не должна превышать 100)
--- @field callsigns? string[] # Позывные в имени игрока
--- @field models? table<string, string> # Модели
--- @field accessories? boolean | {attachments: {random: table, required: table }} # Аксессуары. Из таблицы random выдается ОДИН случайный аксессуар. Из таблицы required обязательно выдаются все аксессуары из нее.
--- @field subclasses? table<string, table> # Может иметь все те же ключи, что и PlayerClass, кроме name. Если bodygroups должны быть динамичными, то нужно их вынести в отдельный метод, иначе они рандомно выберутся раз и навсегда.
--- @field subclass? table # Сюда записывается выбранный subclass из subclasses
--- @field color? {red: number, green: number, blue: number} # Цвет игрока
--- @field weapons? { primary: table<string, {chance: number, ammoMultiplier: number, ammoType: string, attachments: {grips: table<string, number>, magwells: table<string, number>, muzzles: table<string, number>, sights: table<string, number>, underbarrel: table<string, number>}}>, secondary: table<string, {chance: number, ammoMultiplier: number, ammoType: string, attachments: {grips: table<string, number>, magwells: table<string, number>, muzzles: table<string, number>, sights: table<string, number>, underbarrel: table<string, number>}}>, melee: table<string, number>, explosive: table<string, number> } # Оружие
--- @field equipment? {armor: {helmets: table, masks: table, vests: table}, medicine: table, others: table} # Снаряжение
--- @field npc? table<string, string[]> # Таблица NPC и их команда. TODO: вынести это в другой класс
--- @field relations? { npc: { friendly: string[], hostile: string[] } } # Таблица отношений. NPC: отношение NPC к игрокам friendly/hostile
hg.PlayerClass = {
    name = "base",
    prefixes = {},
    callsigns = {},
    models = {},
    accessories = {
        attachments = {
            random = {},
            required = {}
        }
    },
    color = {
        red = 255,
        green = 255,
        blue = 0
    },
    subclasses = {},
    subclass = {},
    weapons = {
        primary = {},
        secondary = {},
        melee = {},
        explosive = {}
    },
    equipment = {
        armor = {
            helmets = {},
            masks = {},
            vests = {}
        },
        medicine = {},
        others = {}
    },
    npc = {
        rebels = {
            "npc_alyx",
            "npc_barney",
            "npc_citizen",
            "npc_eli",
            "npc_fisherman",
            "npc_kleiner",
            "npc_magnusson",
            "npc_mossman",
            "npc_odessa",
            "npc_rollermine_hacked",
            "npc_turret_floor_resistance",
            "npc_vortigaunt"
        },
        alliance = {
            "npc_combine_s",
            "npc_strider",
            "npc_metropolice",
            "npc_hunter",
            "npc_rollermine",
            "npc_cscanner",
            "npc_combinegunship",
            "npc_combinedropship",
            "npc_clawscanner",
            "npc_manhack",
            "npc_combine_camera",
            "npc_turret_ceiling",
            "npc_turret_floor"
        }
    },
    relations = {
        npc = {
            friendly = {},
            hostile = {}
        }     
    }
}
hg.PlayerClass.__index = hg.PlayerClass

--------------------------------------------------------------------------------
--- @private
--------------------------------------------------------------------------------

    --- К переданным значениям добавляет значения по умолчанию.
    --- @private
    --- @generic T : table
    --- @param input T | nil
    --- @param defaults T
    --- @return T
local function __AddDefault(input, defaults)
    input = input or {}
    defaults = defaults or {}
    for k, v in pairs(defaults) do
        if input[k] == nil then
            input[k] = v
        end
    end
    return input
end

    --- Возвращает случайный ключ из таблицы на основе весов (поля chance или числовых значений)
    --- @private
    --- @param tbl table
    --- @return string | nil
local function __GetItemWithChance(tbl)
    local _, value = next(tbl)
    if type(tbl) == "table" and type(value) == "table" then
        local totalWeight = 0

        for _, data in pairs(tbl) do
            totalWeight = totalWeight + (data.chance or (100 / table.Count(tbl)))
        end

        local roll = math.random() * totalWeight
        local currentWeight = 0

        for key, data in pairs(tbl) do
            currentWeight = currentWeight + (data.chance or (100 / table.Count(tbl)))
            if roll <= currentWeight then
                return key
            end
        end

    elseif type(tbl) == "table" and type(value) == "number" then
        local totalWeight = 0
        for _, value in pairs(tbl) do
            totalWeight = totalWeight + value or (100 / table.Count(tbl))
        end

        local roll = math.random() * totalWeight
        local currentChance = 0

        for key, value in pairs(tbl) do
            currentChance = currentChance + value or (100 / table.Count(tbl))
            if roll <= currentChance then
                return key
            end
        end
    end
end

--------------------------------------------------------------------------------
--- @abstract
--------------------------------------------------------------------------------

    --- Вызывается при смене или удалении класса у игрока.
    --- @protected
    --- @abstract
function hg.PlayerClass:Off()
    error("Abstract method \"Off\" must be realised in " .. self.name)
end

    --- Вызывается при выдаче класса игроку.
    --- @protected
    --- @abstract
function hg.PlayerClass:On()
    error("Abstract method \"On\" must be realised in " .. self.name)
end

    --- Содержит хуки. Должен вызываться в методе On.
    --- @protected
    --- @abstract
function hg.PlayerClass:SetHooks()
    error("Abstract method \"Hooks\" must be realised in " .. self.name)
end

--------------------------------------------------------------------------------
--- @protected
--------------------------------------------------------------------------------

    --- Создает дочерний класс, наследуя свойства текущего.
    --- Регистрирует класс в системе и возвращает финальный объект.
    --- @protected
    --- @param childTable table|nil Таблица для нового класса
    --- @return PlayerClass childTable
    --- @return table hgClass
function hg.PlayerClass:Extend(childTable)
    childTable = childTable or {}
    setmetatable(childTable, self)

    childTable.__index = childTable

    local hgClass = player.RegClass(childTable.name)

    setmetatable(hgClass, {
        __index = childTable
    })

    return childTable, hgClass
end

    --- Возвращает аксессуары
    --- @protected
    --- @param ply Player
    --- @return table | nil
function hg.PlayerClass:GetAccessoriesAttachments(ply)
    local attachments = {}

    if self.accessories == false then
        return
    end
    if self.accessories == true then
        local appearance = self:GetAppearance(ply)
        attachments = appearance.AAttachments
        return attachments
    end

    if type(self.accessories) == "table" and next(self.accessories) then

        local atts = self.accessories.attachments

        -- Проверяем, существует ли atts и является ли таблицей
        if type(atts) == "table" then
            if atts.random and next(atts.random) then
                table.insert(attachments, atts.random[math.random(#atts.random)])
            end

            if atts.required and next(atts.required) then
                for _, value in pairs(atts.required) do
                    table.insert(attachments, value)
                end
            end
        end  
    end

    if type(attachments) == "table" and not next(attachments) then
        return
    end

    return attachments
end

    --- Возвращает внешность.
    --- @protected
    --- @param ply Player
    --- @return table
function hg.PlayerClass:GetAppearance(ply)
    local appearance = ply.CurAppearance or hg.Appearance.GetRandomAppearance()

    return appearance
end

    --- Возвращает префикс.
    --- @param parameters? {prefixes: table}
    --- @return string | nil
function hg.PlayerClass:GetPrefix(parameters)
    parameters = __AddDefault(parameters, {
        prefixes = self.prefixes
    })
    if not parameters.prefixes or not next(parameters.prefixes) then
        return error("Class " .. self.name .. " doesn't have any prefixes")
    end

    local prefix = __GetItemWithChance(parameters.prefixes)
    return prefix
end

    --- Выдает игроку Loadout: оружие, снаряжение и броня. Работает и с subclasses, и без них
    --- @protected
    --- @param ply Player
function hg.PlayerClass:GiveLoadout(ply)

    local function giveWeapon(parameters)
        parameters = __AddDefault(parameters, {
            category = nil,
            ammoMultiplier = 3
        })
        local source = (self.subclass.weapons and self.subclass.weapons[parameters.category]) or self.weapons[parameters.category]

        if source and next(source) then
            

            local weaponName = __GetItemWithChance(source)
            
            local weapon = ply:Give(weaponName, false)

            if IsValid(weapon) and source[weaponName] then

                if source[weaponName].attachments then
                    for _, items in pairs(source[weaponName].attachments) do
                        if type(items) == "table" and next(items) then
                            local randomAttachment = __GetItemWithChance(items)
                            if randomAttachment ~= "nothing" then
                                hg.AddAttachmentForce(ply, weapon, randomAttachment)
                            end
                        end
                    end
                end

                if source[weaponName].ammoMultiplier or parameters.ammoMultiplier then
                    local ammoMultiplier = source[weaponName].ammoMultiplier or parameters.ammoMultiplier
                    local ammoType = source[weaponName].ammoType or weapon:GetPrimaryAmmoType() -- Есть нюанс: если тип патронов не дефолтный, то игроку придется сменить его через Q-меню.

                    ply:GiveAmmo(weapon:GetMaxClip1() * ammoMultiplier, ammoType, true)
                end
            end
        end
    end 
    
    local function giveEquipment(category)
        local source = (self.subclass.equipment and self.subclass.equipment[category]) or self.equipment[category]

        if source and #source > 0 then
            for _, value in pairs(source) do
                ply:Give(value, true)
            end
        end
    end

    local function giveArmor(category)
        local source = (self.subclass.equipment and self.subclass.equipment.armor and self.subclass.equipment.armor[category]) or self.equipment.armor[category]
        if source and #source > 0 then
            hg.AddArmor(ply, source[math.random(#source)])

            ply:SyncArmor()
        end
        
    end

    giveWeapon({
        category = "primary",
        ammoMultiplier = 3
    })
    giveWeapon({
        category = "secondary",
        ammoMultiplier = 2
    })
    giveWeapon({
        category = "melee",
    })
    giveWeapon({
        category = "explosive",
    })

    giveEquipment("medicine")
    giveEquipment("others")

    giveArmor("helmets")
    giveArmor("masks")
    giveArmor("vests")

end

    --- Устанавливает внешность игрока на основе параметров.
    --- @protected
    --- @param ply Player
    --- @param parameters? { subMaterial: boolean }
function hg.PlayerClass:SetAppearance(ply, parameters)
    parameters = __AddDefault(parameters, {
        -- Значения по умолчанию
        subMaterial = true,
    })

    ApplyAppearance(ply, nil, nil, nil, true)

    ply:SetNetVar("Accessories", self:GetAccessoriesAttachments(ply) or "none")

    if parameters.subMaterial == false then
        ply:SetSubMaterial()
    end
end

    --- Устанавливает цвет игрока.
    --- @protected
    --- @param ply Player
    --- @param parameters? { color: table }
function hg.PlayerClass:SetColor(ply, parameters)
    parameters = __AddDefault(parameters, {
        color = self.color
    })
    ply:SetPlayerColor(Color(parameters.color.red, parameters.color.green, parameters.color.blue):ToVector())
end

    --- Устанавливает имя игрока с префиксами и позывными.
    --- @protected
    --- @param ply Player
function hg.PlayerClass:SetName(ply)
    local name = self:GetAppearance(ply).AName
    local callsign = nil
    local prefix = nil

    if self.prefixes and next(self.prefixes) then
        prefix = self:GetPrefix({
            prefixes = self.prefixes
        })
    elseif self.subclass.prefixes and next(self.subclass.prefixes) then
        prefix = self:GetPrefix({
            prefixes = self.subclass.prefixes
        })
    end

    if self.callsigns and next(self.callsigns) then
        callsign = self.callsigns[math.random(#self.callsigns)]
    elseif self.subclass.callsigns and next(self.subclass.callsigns) then
        callsign = self.subclass.callsigns[math.random(#self.subclass.callsigns)]
    end

    ply:SetNWString("PlayerName", (prefix and prefix .. " " or "") .. (callsign and callsign .. " " or "") .. name)
end

    --- Устанавливает отношения между игроком и NPC
    --- Вызывать внутри метода On
    --- @protected
    --- @param ply Player
    --- @param parameters? {npc: table}
function hg.PlayerClass:SetNpcRelationships(ply, parameters)
    parameters = __AddDefault(parameters, {
        npc = {
            friendly = self.relations.npc.friendly,
            hostile = self.relations.npc.hostile
        }
    })

    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if IsValid(npc) and npc:IsNPC() then
            self:SetSingleNpcRelationship(ply, npc, parameters)
        end
    end
end

    --- Устанавливает роль (подкласс) игрока в Q-меню
    --- @protected
    --- @param ply Player
    --- @param parameters? {color: {red: number, green: number, blue: number}} 
function hg.PlayerClass:SetRole(ply, parameters)
    parameters = __AddDefault(parameters, {
        color = {
            red = self.color.red,
            green = self.color.green,
            blue = self.color.blue
        }
    })
    if zb and zb.GiveRole then
        zb.GiveRole(ply, (self.subclass and self.subclass.name) or self.name, Color(parameters.color.red, parameters.color.green, parameters.color.blue))
    end
end

    --- Устанавливает отношения между игроком и одним NPC.
    --- @protected
    --- @param ply Player
    --- @param npc table
    --- @param parameters {npc: table}
function hg.PlayerClass:SetSingleNpcRelationship(ply, npc, parameters)
    if not (IsValid(ply) and IsValid(npc)) then return end
    
    local npcClass = npc:GetClass()
    local npcData = parameters.npc or {}
    local npcGroups = self.npc or hg.PlayerClass.npc 

    for _, category in pairs(npcData.friendly or {}) do
        -- Используем npcGroups вместо self.npc
        if npcGroups[category] and table.HasValue(npcGroups[category], npcClass) then
            npc:AddEntityRelationship(ply, D_LI, 99)
            npc:ClearEnemyMemory()
            return
        end
    end

    for _, category in pairs(npcData.hostile or {}) do
        if npcGroups[category] and table.HasValue(npcGroups[category], npcClass) then
            npc:AddEntityRelationship(ply, D_HT, 99)
            npc:ClearEnemyMemory()
            return
        end
    end
end

    --- Устанавливает подкласс игрока.
    --- @protected
    --- @return table | any
function hg.PlayerClass:SetSubclass()
    if not self.subclasses or not next(self.subclasses) then
        return error("Class " .. self.name .. " doesn't have any subclasses")
    end

    local chance = 0
    for _, data in pairs(self.subclasses) do
        chance = chance + (data.chance)
    end

    local roll = math.random() * chance
    local currentChance = 0

    for key, data in pairs(self.subclasses) do
        currentChance = currentChance + (data.chance)

        if roll <= currentChance then
            self.subclass = data
            self.subclass["name"] = key
            return data --
        end
    end
end

    --- Устанавливает бодигруппы для определенного класса. Использовать, если бодигруппы случайные.
    --- @protected
    --- @param parameters table
function hg.PlayerClass:SetSubclassesBodygroups(parameters)
    if not parameters or not next(parameters) then
        return error("Method \"SetSubclassesBodygroups\" was called in " ..
            self.name .. " without the required \"subclass.bodygroups\" parameter")
    end
    for name, _ in pairs(parameters or self.subclasses.bodygroups) do
        for _, value in pairs(parameters[name]) do
            self.subclasses[name]["bodygroups"] = value
        end
    end
end

    --- Устанавливает один бодигрупп по имени.
    --- @protected
    --- @param ply Player
    --- @param parameters { bodygroup: { name: string, value: number } }
function hg.PlayerClass:SetupBodygroup(ply, parameters)
    if not parameters.bodygroup or not next(parameters.bodygroup) then
        return error("Method \"SetupBodygroup\" was called in " ..
            self.name .. " without the required \"bodygroup\" parameter")
    end
    for i = 0, ply:GetNumBodyGroups() - 1 do
        if ply:GetBodygroupName(i) == parameters.bodygroup.name then
            ply:SetBodygroup(i, parameters.bodygroup.value)
            return
        end
    end
end

    --- Устанавливает несколько бодигруппов по имени.
    --- @protected
    --- @param ply Player
    --- @param parameters { bodygroups: table<string, number> } # Ключ - название (например, "body"), значение - индекс (например, 1)
function hg.PlayerClass:SetupBodygroups(ply, parameters)
    if not parameters.bodygroups or not next(parameters.bodygroups) then
        return error("Method \"SetupBodygroups\" was called in " ..
            self.name .. " without the required \"bodygroups\" parameter")
    end
    for name, value in pairs(parameters.bodygroups) do
        local index = ply:FindBodygroupByName(name)
        if index ~= -1 then
            ply:SetBodygroup(index, value)
        end
    end
end

    --- Устанавливает модель игрока, выбирая подходящую из списка доступных.
    --- @protected
    --- @param ply Player
    --- @param parameters? { skin: number }
function hg.PlayerClass:SetupModel(ply, parameters)
    -- Значения по умолчанию
    parameters = __AddDefault(parameters, {
        skin = 0
    })
    local models = (self.subclass and self.subclass.models) or self.models
    if not models or not next(models) then
        return error("Class " .. self.name .. " doesn't have any models")
    end
    local appearance = self:GetAppearance(ply)
    local modelKey = appearance.AModel


    if not models[modelKey] then
        local keys = {}
        for k in pairs(models) do
            table.insert(keys, k)
        end
        modelKey = keys[math.random(#keys)]
    end

    ply:SetModel(models[modelKey])

    if parameters.skin then
        ply:SetSkin(parameters.skin)
    end
end

    --- Убирает отношения между игроком и NPC
    --- Вызывать внутри метода Off
    --- @protected
    --- @param ply Player
    --- @param parameters? {npc: table}
function hg.PlayerClass:UnsetNpcRelationships(ply, parameters)
    parameters = __AddDefault(parameters, {
        npc = {
            friendly = self.relations.npc.hostile,
            hostile = self.relations.npc.friendly
        }
    })

    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if IsValid(npc) and npc:IsNPC() then
            self:SetSingleNpcRelationship(ply, npc, parameters)
        end
    end
end