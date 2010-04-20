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

-- Sandbox related functions.

local menu = {}

--- Loads the sandbox menu from file.
-- A default one will be used if the file does not exist.
function SaitoHUD.LoadSandboxMenu()
    local data = file.Read("saitohud/sandbox/menu.csv")
    
    if data ~= "" then
        data = SaitoHUD.ParseCSV(data)
        
        if #data > 0 then
            -- Remove the header
            if data[1][1] == "Title" then
                table.remove(data, 1)
            end
            
            for _, v in pairs(data) do
                table.insert(menu, {text = v[1], action = v[2]})
            end
        end
    else
        -- Default menu
        table.insert(menu, {text = "Easy Precision Tool", action = "tool_easy_precision"})
        table.insert(menu, {text = "Weld Tool", action = "tool_weld"})
        table.insert(menu, {text = "Remover Tool", action = "tool_remover"})
        table.insert(menu, {text = "No Collide Tool", action = "tool_nocollide"})
        table.insert(menu, {text = "Adv. Duplicator Tool", action = "tool_adv_duplicator"})
        table.insert(menu, {text = "Expression 2 Tool", action = "tool_wire_expression2"})
        table.insert(menu, {text = "Improved Wire Tool", action = "tool_wire_improved"})    
        table.insert(menu, {text = "Wire Debugger Tool", action = "tool_wire_debugger"})
    end
end

-- Hook for the menu
local function SandboxMenu(numItems)
     -- We only want this gesture menu to appear if there's nothing else
    if numItems > 1 then
        return {}
    end
    
    return menu
end

hook.Add("SaitoHUDProvideMenu", "SaitoHUD.Sandbox", SandboxMenu)

-- Load the menu!
SaitoHUD.LoadSandboxMenu()