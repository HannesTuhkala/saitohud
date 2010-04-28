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

local additionalModules = CreateClientConVar("saitohud_modules", "", true, false)
local earlyAdditionalModules = CreateClientConVar("saitohud_modules_pre", "", true, false)

local function Load(module)
    path = "saitohud/" .. module .. ".lua"
    Msg("Loading: " .. path .. "...\n")
    include(path)
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

Msg("====== Loading SaitoHUD ======\n")

if reloading then
    Msg("Reloading detected!\n")
end

Msg("Loading early modules...\n")
LoadList(earlyAdditionalModules:GetString())

Msg("Loading built-in modules...\n")
Load("filters") -- Entity filtering engine
Load("lib")
Load("core")
Load("drawing")
Load("light")
Load("listgest")
Load("overlays") -- Entity overlay information
Load("sampling") -- Entity path tracking
Load("aimtrace")
Load("stranded")
Load("sandbox")
Load("cinematography")
Load("survey")
Load("resbrowser")
Load("panel")

Msg("Loading additional modules...\n")
LoadList(additionalModules:GetString())

Msg("==============================\n")