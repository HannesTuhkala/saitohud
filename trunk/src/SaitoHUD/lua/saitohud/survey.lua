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

-- This module implements surveying tools.

local orthogonalTraces = {}

local Rehook = nil

--- Console commands to do an ortho trace.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function OrthoTrace(ply, cmd, args)
    local start = SaitoHUD.GetRefTrace()
    
    local data = {}
    data.start = start.HitPos
    data.endpos = start.HitNormal * 10000 + start.HitPos
    data.filter = LocalPlayer()
    local final = util.TraceLine(data)
    
    table.insert(orthogonalTraces, {start.HitPos, final.HitPos})
    
    Rehook()
end

--- Console commands clear the list of ortho traces.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function OrthoTraceClear(ply, cmd, args)
    orthogonalTraces = {}
    
    Rehook()
end

--- Draw orthogonal traces.
local function DrawOrthoTraces()
    for _, v in pairs(orthogonalTraces) do
        surface.SetDrawColor(255, 0, 0, 255)
        SaitoHUD.Draw3D2DLine(v[1], v[2])
    end
end

--- Hook to draw survey stuff in RenderScreenspaceEffects.
local function DrawSurveyScreenspace()
    cam.Start3D(EyePos(), EyeAngles())
    -- Wrap the call in pcall() because an error here causes mayhem, so it
    -- is best if any errors are caught
    err, x = pcall(DrawOrthoTraces)
    cam.End3D()
end

Rehook = function()
    if #orthogonalTraces > 0 then
        hook.Add("RenderScreenspaceEffects", "SaitoHUD.Survey", DrawSurveyScreenspace)
    else
        hook.Remove("RenderScreenspaceEffects", "SaitoHUD.Survey")
    end
end

Rehook()

concommand.Add("ortho_trace", OrthoTrace)
concommand.Add("ortho_trace_clear", OrthoTraceClear)