-- SaitoHUD
-- Copyright (c) 2009, 2010 sk89q <http://www.sk89q.com>
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 2 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 
-- $Id$

local reloading = false

if SaitoHUD ~= nil then
    reloading = true 
end

SaitoHUD = {}
SaitoHUD.Reloading = reloading

local postModules = CreateClientConVar("saitohud_modules", "", true, false):GetString()
local preModules = CreateClientConVar("saitohud_modules_pre", "", true, false):GetString()
local profile = CreateClientConVar("saitohud_profile", "0", true, false):GetBool()

local function Load(module)
    path = "saitohud/" .. module .. ".lua"
    MsgN("Loading: " .. path .. "...")
    local start = SysTime()
    include(path)
    if profile then
        local t = SysTime() - start
        print(string.format(" >>> %.3fms", t * 1000))
    end
end

local function LoadList(str)
    local modules = string.Explode(",", str)
    for _, module in pairs(modules) do
        local module = string.Trim(module)
        if module ~= "" then
            Load(module)
        end
    end
end

local function RemoveExistingHooks()
    for name, list in pairs(hook.GetTable()) do
        for k, f in pairs(list) do
            if k:match("^SaitoHUD") then
                list[k] = nil
            end
        end
    end
end

Msg("====== Loading SaitoHUD ======\n")

if reloading then
    Msg("Reloading detected!\n")
    RemoveExistingHooks()
end

local start = SysTime()

if preModules ~= "" then
    Msg("Loading early modules...\n")
    LoadList(preModules)
end

Msg("Loading built-in modules...\n")
Load("filters") -- Entity filtering engine
Load("lib")
Load("core")
Load("util")
Load("friends")
Load("listgest")
Load("overlays") -- Entity overlay information
Load("sampling") -- Entity path tracking
Load("stranded")
Load("sandbox")
Load("survey")
Load("resbrowser")
Load("spectate")
Load("wire")
Load("umsg")
Load("panel")

if postModules ~= "" then
    MsgN("Loading additional modules...\n")
    LoadList(postModules)
end

if profile then
    local t = SysTime() - start
    print(string.format("TOTAL: %.3fms", t * 1000))
end

Msg("==============================\n")