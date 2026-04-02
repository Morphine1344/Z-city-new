player.classList = player.classList or {}
local classList = player.classList
local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:GetPlayerClass()
    return classList[self.PlayerClassName or ""]
end

function PlayerMeta:PlayerClassEvent(name, ...)
    local class = self:GetPlayerClass()
    if not class then return end

    local func = class[name]
    if isfunction(func) then
        return func(class, self, ...)
    end
end

function player.RegClass(name)
    classList[name] = classList[name] or {}
    return classList[name]
end

function player.EventPoint(pos, name, radius, ...)
    for _, ply in ipairs(player.Iterator()) do
        if ply:GetPos():Distance(pos) > radius then continue end
        ply:PlayerClassEvent("EventPoint", name, pos, radius, ...)
    end
end

function player.Event(ply, name, ...)
    if not IsValid(ply) then return end
    ply:PlayerClassEvent("Event", name, ...)
end

--------------------------------------------------------------------------------
-- Networking
--------------------------------------------------------------------------------

if SERVER then
    util.AddNetworkString("setupclass")
else
    net.Receive("setupclass", function()
        local ply = net.ReadEntity()
        if not IsValid(ply) then return end

        local newClassName = net.ReadString()
        local oldClassName = net.ReadString()
        local data = net.ReadTable()

        local oldClass = classList[oldClassName]
        if oldClass and isfunction(oldClass.Off) then
            oldClass.Off(oldClass, ply)
        end


        ply.PlayerClassName = newClassName
        ply.PlayerClassNameOld = oldClassName

        ply:PlayerClassEvent("On", data)
    end)
end