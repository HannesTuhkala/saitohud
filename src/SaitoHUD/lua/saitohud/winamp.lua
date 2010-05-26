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

-- This module implements Winamp-related functions.

require("WinAmp_Interface")

local foundWinamp = winamp.SetupWinAmp()

local updateNowPlaying = CreateClientConVar("winamp_now_playing", "0", true, false)
local nowPlayingField = CreateClientConVar("winamp_now_playing_field", "cl_xfire", true, false)

local lastUpdate = 0

local function Think()
    if CurTime() - lastUpdate < (foundWinamp and 1 or 10) then
        return
    end
    
    if not foundWinamp then
        foundWinamp = winamp.SetupWinAmp()
        if not foundWinamp then return end
    end
    
    local field = nowPlayingField:GetString()
    local current = GetConVar(field):GetString()
    local text
    
    if winamp.CurrentPlayMode() == 1 then
        text = "Now Playing: " .. winamp.GetCurrentTrack()
    else
        text = ""
    end
    
    if text ~= current then
        RunConsoleCommand(field, text)
    end
    
    lastUpdate = CurTime()
end

local function Rehook()
    if updateNowPlaying:GetBool() then
        hook.Add("Think", "SaitoHUD.Winamp", Think)
    else
        SaitoHUD.RemoveHook("Think", "SaitoHUD.Winamp")
    end
end

cvars.AddChangeCallback("winamp_now_playing", Rehook)

if updateNowPlaying:GetBool() then
    hook.Add("Think", "SaitoHUD.Winamp", Think)
end