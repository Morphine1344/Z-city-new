--- @author Morphine

--- @class PlayerClass
--- @field name string # Название класса
--- @field prefixes? table<string, number> # Префиксы в имени игрока (сумма шансов не должна превышать 100)
--- @field callsigns? string[] # Позывные в имени игрока
--- @field models? table<string, string> # Модели
--- @field accessories? boolean | {attachments: {random: table, required: table }} # Аксессуары. Из таблицы random выдается ОДИН случайный аксессуар. Из таблицы required обязательно выдаются все аксессуары из нее.
--- @field subclasses? {string: table } # можеть иметь все те же ключи, что и PlayerClass, кроме name. Если bodygroups должны быть динамичными, то нужно их вынести в отдельный метод, иначе они рандомно выберутся раз и навсегда.
--- @field subclass? {string: table } # Сюда записывается выбранный subclass из subclasses
--- @field color? {red: number, green: number, blue: number} Цвет игрока
--- @field primaryWeapons? string[] # Основное оружие
--- @field secondaryWeapons? string[] # Вторичное оружие
--- @field equipment? string[] # Cнаряжение
--- @field npc? {string: table} # Таблица NPC и их команда. TODO: вынести это в другой класс
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
    primaryWeapons = {},
    secondaryWeapons = {},
    equipment = {},
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

--------------------------------------------------------------------------------
--- @virtual
--------------------------------------------------------------------------------

    --- Вызывается при смене или удалении класса у игрока.
    --- @protected
    --- @virtual
function hg.PlayerClass:Off()
    error("Abstract method \"Off\" must be realised in " .. self.name)
end

    --- Вызывается при выдаче класса игроку.
    --- @protected
    --- @virtual
function hg.PlayerClass:On()
    error("Abstract method \"On\" must be realised in " .. self.name)
end

    --- Содержит хуки. Должен вызываться в методе On.
    --- @protected
    --- @virtual
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

    --- Выдает внешность.
    --- @protected
    --- @param ply Player
    --- @return table
function hg.PlayerClass:GetAppearance(ply)
    local appearance = ply.CurAppearance or hg.Appearance.GetRandomAppearance()

    return appearance
end

    --- Возвращает префикс с шансом.
    --- @return string | nil
    function hg.PlayerClass:GetPrefix(parameters)
    parameters = __AddDefault(parameters, {
        prefixes = self.prefixes
    })
    if not parameters.prefixes or not next(parameters.prefixes) then
        return error("Class " .. self.name .. " doesn't have any prefixes")
    end

    local chance = 0
    for _, value in pairs(parameters.prefixes) do
        chance = chance + (value)
    end

    local roll = math.random() * chance
    local currentChance = 0

    for key, value in pairs(parameters.prefixes) do
        currentChance = currentChance + value
        if roll <= currentChance then
            local prefix = key
            return prefix
        end
    end
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
function hg.PlayerClass:SetColor(ply)
    ply:SetPlayerColor(Color(self.color.red, self.color.green, self.color.blue):ToVector())
end

    --- Устанавливает модель игрока, выбирая подходящую из списка доступных.
    --- @protected
    --- @param ply Player
    --- @param parameters? { skin: number }
function hg.PlayerClass:SetMdl(ply, parameters)
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

    --- Устанавливает имя игрока с префексами и позывными.
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

    for _, data in pairs(self.subclasses) do
        currentChance = currentChance + (data.chance)

        if roll <= currentChance then
            self.subclass = data
            return data --
        end
    end
end

    ---Устанавливает бодигруппы для опредленного класса. Использовать, если бодигруппы случайные.
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
    --- @alias name string # Название (например, "body")
    --- @alias value number # Индекс (например, 1)
    --- @param parameters { bodygroups: table<name, value> }
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
