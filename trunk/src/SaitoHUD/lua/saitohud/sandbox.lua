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

local function SandboxListGest(item)
    local menu = {}
    
    table.insert(menu, {["text"] = "Easy Precision Tool", ["action"] = "tool_easy_precision"})
    table.insert(menu, {["text"] = "Weld Tool", ["action"] = "tool_weld"})
    table.insert(menu, {["text"] = "No Collide Tool", ["action"] = "tool_nocollide"})
    table.insert(menu, {["text"] = "Adv. Duplicator Tool", ["action"] = "tool_adv_duplicator"})
    table.insert(menu, {["text"] = "Expression 2 Tool", ["action"] = "tool_wire_expression2"})
    table.insert(menu, {["text"] = "Wire Debugger Tool", ["action"] = "tool_wire_debugger"})
    table.insert(menu, {["text"] = "Improved Wire Tool", ["action"] = "tool_wire_improved"})
    
    return menu
end

SaitoHUD.RegisterListGest(SandboxListGest, true)