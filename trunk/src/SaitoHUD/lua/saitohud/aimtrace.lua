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

local traceAims = CreateClientConVar("trace_aims", "0", true, false)

--- Actually draws the trace aim lines and endpoint boxes.
local function DrawTraceAimsHelper()
    for _, ply in pairs(player.GetAll()) do
        local doDraw = true
        
        if SaitoHUD.ShouldDrawAimTraceHook and not SaitoHUD.ShouldIgnoreHook() then
            if not SaitoHUD.ShouldDrawAimTraceHook(ply) then
                doDraw = false
            end
        end
        
        if ply ~= LocalPlayer() and ply:Alive() and doDraw then
            local shootPos = ply:GetShootPos()
            local eyeAngles = ply:EyeAngles()
            
            local data = {}
            data.start = shootPos
            data.endpos = shootPos + eyeAngles:Forward() * 10000
            data.filter = ply
            local tr = util.TraceLine(data)
            local distance = tr.HitPos:Distance(shootPos)
            
            -- Draw the end point
            cam.Start3D2D(tr.HitPos + tr.HitNormal * 0.2,
                          tr.HitNormal:Angle() + Angle(90, 0, 0), 1)
            if ValidEntity(tr.Entity) and tr.Entity:IsPlayer() then
                surface.SetDrawColor(255, 255, 0, 200)
            else
                surface.SetDrawColor(0, 0, 255, 150)
            end
            surface.DrawRect(-5, -5, 10, 10)
            cam.End3D2D()
            
            -- Draw the line
            cam.Start3D2D(shootPos, eyeAngles, 1)
            if ValidEntity(tr.Entity) and tr.Entity:IsPlayer() then
                surface.SetDrawColor(255, 255, 0, 255)
            else
                surface.SetDrawColor(0, 0, 255, 200)
            end
            surface.DrawLine(0, 0, distance, 0)
            cam.End3D2D()
        end
    end
end

--- RenderScreenspaceEffects hook that calls DrawTraceAimsHelper. We separate the
-- actual drawing function away because, for whatever reason, if it creates an
-- error, the game will be put in an undefined state that only a restart of the
-- game can fix.
local function DrawTraceAims()
    if traceAims:GetBool() then
        cam.Start3D(EyePos(), EyeAngles())
        -- Wrap the call in pcall() because an error here causes mayhem, so it
        -- is best if any errors are caught
        pcall(DrawTraceAimsHelper)
        cam.End3D()
    end
end

hook.Add("RenderScreenspaceEffects", "SaitoHUD.AimTrace", DrawTraceAims)