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

IONET_TOGGLE_OFF = 1
IONET_TOGGLE_ON = 2

local sensors = {}
local outputs = {}

function SaitoHUD.RegisterOutput(name, key, mode)
    local initial = mode == IONET_TOGGLE_ON
    outputs[name] = {key, mode, initial}
    if initial then
        LocalPlayer():ConCommand("+gm_special " .. key)
    else
        LocalPlayer():ConCommand("-gm_special " .. key)
    end
end

function SaitoHUD.TriggerOutput(name)
    if not outputs[name] then return end
    
    outputs[name][3] = not outputs[name][3]
    if outputs[name][3] then
        LocalPlayer():ConCommand("+gm_special " .. key)
    else
        LocalPlayer():ConCommand("-gm_special " .. key)
    end
end

function SaitoHUD.SetOutput(name, state)
    if not outputs[name] then return end
    local key = outputs[name][1]
    local initial = (outputs[name][2] == IONET_TOGGLE_ON) == state
    if outputs[name][3] == initial then return end
    outputs[name][3] = initial
    if outputs[name][3] then
        LocalPlayer():ChatPrint("on")
        LocalPlayer():ConCommand("-gm_special " .. key)
        LocalPlayer():ConCommand("+gm_special " .. key)
    else
        LocalPlayer():ChatPrint("off")
        LocalPlayer():ConCommand("+gm_special " .. key)
        LocalPlayer():ConCommand("-gm_special " .. key)
    end
end

function SaitoHUD.RegisterProximitySensor(name, pos, distance, output)
    sensors[name] = {
        ["pos"] = pos,
        ["distance"] = distance,
        ["output"] = output,
    }
end

--SaitoHUD.RegisterOutput("test", "1", IONET_TOGGLE_ON)
--SaitoHUD.RegisterProximitySensor("test", Vector(4730.4199, 409.9189, 64.0000), 300, "test")

function Think()
    for _, sensor in pairs(sensors) do
        local found = false
        
        for _, ply in pairs(player.GetAll()) do
            if sensor.pos:Distance(ply:GetPos()) < sensor.distance then
                SaitoHUD.SetOutput(sensor.output, true)
                found = true
                break
            end
        end
    
        if not found then
            SaitoHUD.SetOutput(sensor.output, false)
        end
    end
end
hook.Add("Think", "SaitoHUD.IONet.Think", Think)
