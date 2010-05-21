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

-- This module implements free spectating.

local spectateLock = CreateClientConVar("free_spectate_lock", "1", true, false)
local spectateRate = CreateClientConVar("free_spectate_rate", "1000", true, false)
local spectateNotice = CreateClientConVar("free_spectate_notice", "1", true, false)

local viewPos = Vector()
local viewAng = Angle()
local spectating = false
local origViewAngle = Angle()
local listenPresses = {"+forward", "+back", "+moveleft", "+moveright", "+jump", "+speed", "+duck", "+walk"}
local keyPressed = {}
local lastTrace = nil
local lastTraceTime = 0

--- Handle movements.
-- @param usercmd
local function CreateMove(usercmd)
    viewAng.p = math.Clamp(viewAng.p + usercmd:GetMouseY() * 0.025, -90, 90)
    viewAng.y = viewAng.y - usercmd:GetMouseX() * 0.025
    if spectateLock:GetBool() then
        usercmd:SetViewAngles(origViewAngle)
    else
        local data = {}
        data.start = viewPos
        data.endpos = viewPos + viewAng:Forward() * 50000
        data.filter = LocalPlayer()
        local tr = util.TraceLine(data)
        usercmd:SetViewAngles((tr.HitPos - LocalPlayer():GetShootPos()):Angle())
    end
end

--- Handle key presses.
-- @param ply
-- @param bind
-- @param pressed
local function PlayerBindPress(ply, bind, pressed)
    for _, key in pairs(listenPresses) do
        if bind:find(key) then
            keyPressed[key] = pressed
            return true
        end
    end
    
    if spectateLock:GetBool() and bind:find("+attack") or 
        bind:find("+attack2") or bind:find("+use") or bind:find("+reload") then
        return true
    end
end

--- Set the view.
-- @param ply
-- @param origin
-- @param angles
-- @param fov
local function CalcView(ply, origin, angles, fov)
    local view = {}
    view.origin = viewPos
    view.angles = viewAng
    view.fov = fov
    return view
end

--- Spectate think function.
local function Think()
    local rate = keyPressed["+speed"] and spectateRate:GetFloat() * 2 or spectateRate:GetFloat()
    if keyPressed["+walk"] then rate = rate / 4 end
    
    if keyPressed["+forward"] then viewPos = viewPos + viewAng:Forward() * rate * RealFrameTime() end
    if keyPressed["+back"] then viewPos = viewPos - viewAng:Forward() * rate * RealFrameTime() end
    if keyPressed["+moveleft"] then viewPos = viewPos - viewAng:Right() * rate * RealFrameTime() end
    if keyPressed["+moveright"] then viewPos = viewPos + viewAng:Right() * rate * RealFrameTime() end
    if keyPressed["+jump"] then viewPos = viewPos + viewAng:Up() * rate * RealFrameTime() end
    if keyPressed["+duck"] then viewPos = viewPos - viewAng:Up() * rate * RealFrameTime() end
end

--- HUDPaint function.
local function HUDPaint()
    if spectateNotice:GetBool() then
        draw.SimpleText("Free Spectating", "Trebuchet22", ScrW() / 2 + 1, ScrH() * .8 + 1,
                        Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Free Spectating", "Trebuchet22", ScrW() / 2, ScrH() * .8,
                        Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

--- Start spectating.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function ToggleSpectate(ply, cmd, args)
    spectating = not spectating
    
    if spectating and not SaitoHUD.AntiUnfairTriggered() then
        origViewAngle = LocalPlayer():EyeAngles()
        viewPos = LocalPlayer():GetShootPos()
        viewAng = LocalPlayer():EyeAngles() -- Need to make a copy
        
        hook.Add("CreateMove", "SaitoHUD.Spectate", CreateMove)
        hook.Add("PlayerBindPress", "SaitoHUD.Spectate", PlayerBindPress)
        hook.Add("CalcView", "SaitoHUD.Spectate", CalcView)
        hook.Add("Think", "SaitoHUD.Spectate", Think)
        hook.Add("ShouldDrawLocalPlayer", "SaitoHUD.Spectate", function() return true end)
        hook.Add("HUDPaint", "SaitoHUD.Spectate", HUDPaint)
    else
        keyPressed = {}
        hook.Remove("PlayerBindPress", "SaitoHUD.Spectate")
        hook.Remove("CreateMove", "SaitoHUD.Spectate")
        hook.Remove("CalcView", "SaitoHUD.Spectate")
        hook.Remove("Think", "SaitoHUD.Spectate")
        hook.Remove("ShouldDrawLocalPlayer", "SaitoHUD.Spectate")
        hook.Remove("HUDPaint", "SaitoHUD.Spectate")
    end
end

--- Override trace functions.
local function OverrideTraceFunctions()
    function SaitoHUD.GetRefTrace()
        if spectating then
            if lastTraceTime == CurTime() then
                return lastTrace
            end
            
            local data = {}
            data.start = viewPos
            data.endpos = viewPos + viewAng:Forward() * 16384 
            data.filter = LocalPlayer()
            lastTrace = util.TraceLine(data)
            return lastTrace
        else
            return util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
        end
    end

    function SaitoHUD.GetRefPos()
        return spectating and viewPos or LocalPlayer():GetPos()
    end

    local playerMt = FindMetaTable("Player")
    if not _SH_OldEyeTrace then _SH_OldEyeTrace = playerMt.GetEyeTrace end
    if not _SH_OldGetPlayerTrace then _SH_OldGetPlayerTrace = util.GetPlayerTrace end

    function util.GetPlayerTrace(ply)
        if spectating and ply == LocalPlayer() then
            local data = {}
            data.start = viewPos
            data.endpos = viewPos + viewAng:Forward() * 16384 
            data.filter = LocalPlayer()
            return util.TraceLine(data)
        else
            return _SH_OldGetPlayerTrace(ply)
        end
    end

    function playerMt:GetEyeTrace()
        if spectating then
            if lastTraceTime == CurTime() then
                return lastTrace
            end
            
            local data = {}
            data.start = viewPos
            data.endpos = viewPos + viewAng:Forward() * 16384 
            data.filter = LocalPlayer()
            lastTrace = util.TraceLine(data)
            return lastTrace
        else
            return _SH_OldEyeTrace(self)
        end
    end
end

concommand.Add("toggle_spectate", ToggleSpectate)
hook.Remove("PlayerBindPress", "SaitoHUD.Spectate")
hook.Remove("CreateMove", "SaitoHUD.Spectate")
hook.Remove("CalcView", "SaitoHUD.Spectate")
hook.Remove("Think", "SaitoHUD.Spectate")
hook.Remove("ShouldDrawLocalPlayer", "SaitoHUD.Spectate")
hook.Remove("HUDPaint", "SaitoHUD.Spectate")
OverrideTraceFunctions()