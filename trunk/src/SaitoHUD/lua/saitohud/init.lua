-- SaitoHUD
-- Copyright (c) 2009-2010 sk89q <http://www.sk89q.com>
-- Copyright (c) 2010 BoJaN
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

local postModules = CreateClientConVar("saitohud_modules", "", true, false):GetString()
local preModules = CreateClientConVar("saitohud_modules_pre", "", true, false):GetString()
local profile = CreateClientConVar("saitohud_profile", "0", true, false):GetBool()

local reloading = false
if SaitoHUD ~= nil then reloading = true end

SaitoHUD = {}
SaitoHUD.Reloading = reloading

include("saitohud/saitohud.lua")
include("saitohud/functions.lua")
include("saitohud/concmd.lua")
include("saitohud/filters.lua")
include("saitohud/friends.lua")
include("saitohud/geom.lua")
include("saitohud/overlays.lua")
include("saitohud/vgui/DCustomListView.lua")
include("saitohud/vgui/DListView_CheckboxLine.lua")

--- Load a module.
local function Load(module)
    path = "saitohud/modules/" .. module .. ".lua"
    if profile then
        MsgN("Loading: " .. path .. "...")
    end
    local start = SysTime()
    pcall(include, path)
    
    -- Profiling
    if profile then
        local t = SysTime() - start
        print(string.format(" >>> %.3fms", t * 1000))
    end
end

--- Load a modules from a comma-delimited list.
local function LoadList(str)
    local modules = string.Explode(",", str)
    for _, module in pairs(modules) do
        local module = string.Trim(module)
        if module ~= "" then
            Load(module)
        end
    end
end

--- Remove existing SaitoHUD hooks.
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
Load("util")
Load("listgest")
Load("geom")
Load("overlays") 
Load("player_tags") 
Load("sampling")
Load("stranded")
Load("sandbox")
Load("survey")
Load("measure")
Load("resbrowser")
Load("spectate")
Load("e2_extensions")
Load("entity_info") 
Load("umsg")
Load("calculator")
Load("hook_manager")
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