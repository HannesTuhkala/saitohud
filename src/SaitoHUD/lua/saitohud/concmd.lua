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

-- This module implements console commands.

local toggledCommands = {}

--- Console command toggle a concommand.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function ToggleConCmd(ply, cmd, args)
    if #args ~= 1 then
        Msg("Invalid number of arguments\n")
        return
    end
    
    local cmd = args[1]
    
    if toggledCommands[cmd] then
        RunConsoleCommand("-" .. cmd)
        toggledCommands[cmd] = nil
        chat.AddText(Color(255, 0, 0), "-" .. cmd)
    else
        RunConsoleCommand("+" .. cmd)
        toggledCommands[cmd] = true
        chat.AddText(Color(0, 255, 0), "+" .. cmd)
    end
end

concommand.Add("toggle_concmd", ToggleConCmd)