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

SaitoHUD.MeasurePoints = {}
SaitoHUD.MeasureLength = 0

local orthoTraceText = CreateClientConVar("ortho_trace_text", "1", true, false)
local reflectTraceNodes = CreateClientConVar("reflect_trace_nodes", "1", true, false)
local reflectTraceMultiple = CreateClientConVar("reflect_trace_multiple", "0", true, false)
local reflectTraceColorProgression = CreateClientConVar("reflect_trace_color_progression", "0", true, false)

local orthogonalTraces = {}
local reflectionLines = {}

local Rehook = nil

--- Console commands to do an ortho trace.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function OrthoTrace(ply, cmd, args)
    local start = SaitoHUD.GetRefTrace()
    
    local data = {}
    data.start = start.HitPos
    data.endpos = start.HitNormal * 100000 + start.HitPos
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

--- Console commands to do reflection analysis.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function ReflectAnalysis(ply, cmd, args)
    local numReflects = tonumber(args[1])
    
    if #args ~= 1 then
        Msg("Invalid number of arguments\n")
        return
    elseif numReflects < 2 then
        Msg("Minimum number of reflections: 1\n")
        return
    end
    
    if not reflectTraceMultiple:GetBool() then
        -- if #reflectionLines > 0 then
            -- LocalPlayer():ChatPrint("Note: Multiple reflection analyses is disabled")
        -- end
        reflectionLines = {}
    end
    
    local lines = {}
    
    local tr = SaitoHUD.GetRefTrace()
    local vec = tr.HitPos - tr.StartPos
    table.insert(lines, {tr.StartPos, tr.HitPos})
    
    for i = 1, numReflects do
        local v = vec - 2 * vec:DotProduct(tr.HitNormal) * tr.HitNormal
        local lastPoint = tr.HitPos
        tr = util.QuickTrace(tr.HitPos, v:GetNormal() * 100000, LocalPlayer())
        vec = tr.HitPos - tr.StartPos
        table.insert(lines, {lastPoint, tr.HitPos})
    end
    
    table.insert(reflectionLines, lines)
    
    Rehook()
end

--- Recalculate the measured total.
local function RecalcMeasuredTotal()
    SaitoHUD.MeasureLength = 0
    
    if #SaitoHUD.MeasurePoints > 1 then
        local last = SaitoHUD.MeasurePoints[1]
        
        for i = 2, #SaitoHUD.MeasurePoints do
            local pt = SaitoHUD.MeasurePoints[i]
            SaitoHUD.MeasureLength = SaitoHUD.MeasureLength + pt:Distance(last)
            last = pt
        end
    end
end

--- Console commands to add a point to the path measurement tool.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function AddMeasuredPoint(ply, cmd, args)
    local vec = nil
    
    if #args == 1 or #args == 3 then
        vec = SaitoHUD.ParseConcmdVector(args)
    elseif #args ~= 0 then
        Msg("Invalid number of arguments\n")
        return
    else
        local tr = SaitoHUD.GetRefTrace()
        vec = tr.HitPos
    end
    
    if vec == nil then
        Msg("Invalid arguments\n")
        return
    end
    
    local last = SaitoHUD.MeasurePoints[#SaitoHUD.MeasurePoints]
    
    table.insert(SaitoHUD.MeasurePoints, vec)
    RecalcMeasuredTotal()
    
    if #SaitoHUD.MeasurePoints > 1 then
        print("Added point #" .. #SaitoHUD.MeasurePoints + 1)
        print(string.format("Incremental distance: %f",
                            last:Distance(vec)))
        print(string.format("Total distance: %f", SaitoHUD.MeasureLength))
    end
    
    
    SaitoHUD.UpdateMeasuringPanel()
    Rehook()
end

--- Console command to insert a point in the path measurement tool.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function InsertMeasuredPoint(ply, cmd, args)
    local vec = nil
    
    if #args == 2 or #args == 4 then
        vec = SaitoHUD.ParseConcmdVector(args, 1)
    elseif #args ~= 1 then
        Msg("Invalid number of arguments\n")
        return
    else
        local tr = SaitoHUD.GetRefTrace()
        vec = tr.HitPos
    end
    
    if vec == nil then
        Msg("Invalid arguments\n")
        return
    end
    
    local index = tonumber(args[1])
    
    if not index then
        Msg("Invalid index\n")
    end
    
    index = math.floor(index)
    
    if index < 1 or index > #SaitoHUD.MeasurePoints + 1 then
        Msg("Invalid index\n")
        return
    end
    
    table.insert(SaitoHUD.MeasurePoints, index, vec)
    print("Inserted point at #" .. index)
    
    RecalcMeasuredTotal()
    SaitoHUD.UpdateMeasuringPanel()
    Rehook()
end

--- Console command to replace a point in the path measurement tool.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function ReplaceMeasuredPoint(ply, cmd, args)
    local vec = nil
    
    if #args == 2 or #args == 4 then
        vec = SaitoHUD.ParseConcmdVector(args, 1)
    elseif #args ~= 1 then
        Msg("Invalid number of arguments\n")
        return
    else
        local tr = SaitoHUD.GetRefTrace()
        vec = tr.HitPos
    end
    
    if vec == nil then
        Msg("Invalid arguments\n")
        return
    end
    
    local index = tonumber(args[1])
    
    if not SaitoHUD.MeasurePoints[index] then
        Msg("No such index\n")
        return
    end
    
    SaitoHUD.MeasurePoints[index] = vec
    print("Replaced point #" .. index)
    
    RecalcMeasuredTotal()
    SaitoHUD.UpdateMeasuringPanel()
    Rehook()
end

--- Console command to remove a point in the path measurement tool.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function RemoveMeasuredPoint(ply, cmd, args)
    local vec = nil
    
    if #args == 2 or #args == 4 then
        vec = SaitoHUD.ParseConcmdVector(args, 1)
    elseif #args ~= 1 then
        Msg("Invalid number of arguments\n")
        return
    else
        local tr = SaitoHUD.GetRefTrace()
        vec = tr.HitPos
    end
    
    if vec == nil then
        Msg("Invalid arguments\n")
        return
    end
    
    local index = tonumber(args[1])
    
    if not SaitoHUD.MeasurePoints[index] then
        Msg("No such index\n")
        return
    end
    
    table.remove(SaitoHUD.MeasurePoints, index)
    print("Removed point #" .. index)
    
    RecalcMeasuredTotal()
    SaitoHUD.UpdateMeasuringPanel()
    Rehook()
end

--- Console command to remove the last point in the path measurement tool.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function RemoveLastMeasuredPoint(ply, cmd, args)
    RemoveMeasuredPoint(ply, cmd, {#SaitoHUD.MeasurePoints})
end

--- Console command to list points added in the measurement tool.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function ListMeasuredPoints(ply, cmd, args)
    if #args ~= 0 then
        Msg("Invalid number of arguments\n")
        return
    end
    
    if #SaitoHUD.MeasurePoints > 0 then
        for k, pt in pairs(SaitoHUD.MeasurePoints) do
            if k == 1 then
                print(string.format("#%d (%s)",k, tostring(pt)))
            else
                print(string.format("#%d (%s) incr. dist.: %f",
                                    k, tostring(pt), pt:Distance(SaitoHUD.MeasurePoints[k - 1])))
            end
        end
        
        print(string.format("Total distance: %f", SaitoHUD.MeasureLength))
    else
        print("No points!")
    end
end

--- Console command to sum point distances in the measurement tool.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function SumMeasuredPoints(ply, cmd, args)
    if #args ~= 2 then
        Msg("Invalid number of arguments\n")
        return
    end
    
    local index1 = tonumber(args[1])
    local index2 = tonumber(args[2])
    
    if not index1 or not index2 or index1 >= index2 then
        Msg("Invalid arguments\n")
        return
    end
    
    index1 = math.floor(index1)
    index2 = math.floor(index2)
    
    if index1 < 1 or index2 > #SaitoHUD.MeasurePoints then
        Msg("Indexes out of range\n")
        return
    end
    
    local last = SaitoHUD.MeasurePoints[index1]
    local total = 0
    
    for i = index1 + 1, index2 do
        local pt = SaitoHUD.MeasurePoints[i]
        total = total + pt:Distance(last)
        last = pt
    end
    
    print(string.format("Total distance from #%d -> #%d: %f", index1, index2, total))
end

--- Console command to get the distance between two points
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function BetweenMeasuredPoints(ply, cmd, args)
    if #args ~= 2 then
        Msg("Invalid number of arguments\n")
        return
    end
    
    local index1 = tonumber(args[1])
    local index2 = tonumber(args[2])
    
    if not index1 or not index2 or index1 >= index2 then
        Msg("Invalid arguments\n")
        return
    end
    
    index1 = math.floor(index1)
    index2 = math.floor(index2)
    
    if index1 == index2 then
        Msg("Both indexes are the same\n")
        return
    end
    
    local distance = SaitoHUD.MeasurePoints[index1]:Distance(SaitoHUD.MeasurePoints[index2])
    
    print(string.format("Direct distance between #%d and #%d: %f", index1, index2, distance))
end

--- Console commands to clear the list of points.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function ClearMeasuredPoints(ply, cmd, args)
    if #args ~= 0 then
        Msg("Invalid number of arguments\n")
        return
    end
    
    SaitoHUD.MeasurePoints = {}
    
    print("Cleared")
    
    SaitoHUD.UpdateMeasuringPanel()
    Rehook()
end

--- Console commands clear the list of reflection traces.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function ReflectAnalysisClear(ply, cmd, args)
    reflectionLines = {}
    
    Rehook()
end

--- Draw RenderScreenspaceEffects.
local function DoDrawSurveyScreenspace()
    surface.SetDrawColor(255, 255, 0, 255)
    for _, v in pairs(orthogonalTraces) do
        SaitoHUD.Draw3D2DLine(v[1], v[2])
    end
    
    surface.SetDrawColor(255, 255, 0, 255)
    for _, lines in pairs(reflectionLines) do
        for k, v in pairs(lines) do
            if reflectTraceColorProgression:GetBool() then
                surface.SetDrawColor(255 * k / #lines, 255 * (1 - k / #lines),
                                     255 * (1 - k / #lines), 255)
            end
            SaitoHUD.Draw3D2DLine(v[1], v[2])
        end
    end
    
    -- Since the lines are long, we cannot draw on the HUD because lines with
    -- end points that are off screen may not appear right
    surface.SetDrawColor(255, 0, 255, 255)
    if #SaitoHUD.MeasurePoints > 1 then
        local last = SaitoHUD.MeasurePoints[1]
        
        for i = 2, #SaitoHUD.MeasurePoints do
            local pt = SaitoHUD.MeasurePoints[i]
            
            SaitoHUD.Draw3D2DLine(last, pt)
            
            last = pt
        end
    end
end

--- Draw orthogonal trace text.
local function DrawOrthoTraceText()
    for _, v in pairs(orthogonalTraces) do
		local dist = math.Round(v[1]:Distance(v[2]))
        local screenPos = v[1]:ToScreen()
        draw.SimpleText(tostring(v[1]),
                        "DefaultSmallDropShadow", screenPos.x, screenPos.y,
                        Color(255, 255, 255, 255), 1, ALIGN_TOP)
                        
        draw.SimpleText(tostring(dist),
                        "DefaultSmallDropShadow", screenPos.x, screenPos.y+10,
                        Color(255, 255, 255, 255), 1, ALIGN_TOP)
        
        local screenPos = v[2]:ToScreen()
        draw.SimpleText(tostring(v[2]),
                        "DefaultSmallDropShadow", screenPos.x, screenPos.y,
                        Color(255, 255, 255, 255), 1, ALIGN_TOP)
                        
        draw.SimpleText(tostring(dist),
                        "DefaultSmallDropShadow", screenPos.x, screenPos.y+10,
                        Color(255, 255, 255, 255), 1, ALIGN_TOP)
    end
end

--- Draw reflection analysis text.
local function DrawReflectAnalysisText()
    local dim = 5
    
    surface.SetDrawColor(255, 255, 0, 255)
    
    for _, lines in pairs(reflectionLines) do
        for k, v in pairs(lines) do
            if reflectTraceColorProgression:GetBool() then
                surface.SetDrawColor(255 * k / #lines, 255 * (1 - k / #lines),
                                     255 * (1 - k / #lines), 255)
            end
            
            local screenPos = v[1]:ToScreen()
            surface.DrawOutlinedRect(screenPos.x - dim / 2, screenPos.y - dim / 2, dim, dim)
            
            if k == #lines then
                local screenPos = v[2]:ToScreen()
                surface.DrawOutlinedRect(screenPos.x - dim / 2, screenPos.y - dim / 2, dim, dim)
            end
        end
    end
end

--- Draw measured path.
local function DrawMeasuringLines()
    local dim = 5
    surface.SetDrawColor(255, 0, 255, 255)
    
    if #SaitoHUD.MeasurePoints > 1 then
        local last = SaitoHUD.MeasurePoints[1]
        local lastScreen = last:ToScreen()
        
        if lastScreen.visible then
            draw.SimpleText(tostring(1),
                            "DefaultSmallDropShadow", lastScreen.x, lastScreen.y,
                            Color(255, 255, 255, 255), 1, ALIGN_TOP)
        end
        
        for i = 2, #SaitoHUD.MeasurePoints do
            local pt = SaitoHUD.MeasurePoints[i]
            local midPt = (pt - last) / 2 + last
            local ptScreen = pt:ToScreen()
            local midPtScreen = midPt:ToScreen()
            
            if ptScreen.visible and lastScreen.visible then
                surface.DrawLine(lastScreen.x, lastScreen.y, ptScreen.x, ptScreen.y)
            end
            
            if midPtScreen.visible then
                draw.SimpleText(string.format("%0.2f", last:Distance(pt)),
                                "DefaultSmallDropShadow",
                                midPtScreen.x, midPtScreen.y,
                                Color(255, 200, 255, 255), 1, ALIGN_TOP)
            end
            
            if ptScreen.visible then
                draw.SimpleText(tostring(i), "DefaultSmallDropShadow",
                                ptScreen.x - 2, ptScreen.y - 5,
                                Color(255, 255, 255, 255), 1, ALIGN_TOP)
            end
            
            last = pt
            lastScreen = last:ToScreen()
        end

        local yOffset = ScrH() * 0.3 - 50
        local color = Color(255, 200, 255, 255)
        draw.SimpleText("Measured Total: " .. SaitoHUD.MeasureLength,
                        "TabLarge", ScrW() - 16, yOffset, color, 2, ALIGN_TOP)
    elseif #SaitoHUD.MeasurePoints == 1 then
        local dim = 5
        local last = SaitoHUD.MeasurePoints[1]
        local lastScreen = last:ToScreen()
        surface.DrawOutlinedRect(lastScreen.x - dim / 2,
                                 lastScreen.y - dim / 2,
                                 dim, dim)
        draw.SimpleText(tostring(1),
                        "DefaultSmallDropShadow", lastScreen.x, lastScreen.y,
                        Color(255, 255, 255, 255), 1, ALIGN_TOP)
    end
end

--- Hook to draw survey stuff in RenderScreenspaceEffects.
local function DrawSurveyScreenspace()
    cam.Start3D(EyePos(), EyeAngles())
    -- Wrap the call in pcall() because an error here causes mayhem, so it
    -- is best if any errors are caught
    err, x = pcall(DoDrawSurveyScreenspace)
    cam.End3D()
end

--- Draw survey HUDPaint stuff.
local function DrawSurvey()
    if orthoTraceText:GetBool() then
        DrawOrthoTraceText()
    end
    
    if reflectTraceNodes:GetBool() then
        DrawReflectAnalysisText()
    end
    
    DrawMeasuringLines()
end

Rehook = function()
    if #orthogonalTraces > 0 or #reflectionLines > 0 or #SaitoHUD.MeasurePoints > 0 then
        hook.Add("RenderScreenspaceEffects", "SaitoHUD.Survey", DrawSurveyScreenspace)
        hook.Add("HUDPaint", "SaitoHUD.Survey", DrawSurvey)
    else
        hook.Remove("RenderScreenspaceEffects", "SaitoHUD.Survey")
        hook.Remove("HUDPaint", "SaitoHUD.Survey")
    end
end

Rehook()

concommand.Add("ortho_trace", OrthoTrace)
concommand.Add("ortho_trace_clear", OrthoTraceClear)
concommand.Add("reflect_trace", ReflectAnalysis)
concommand.Add("reflect_trace_clear", ReflectAnalysisClear)
concommand.Add("measure_add", AddMeasuredPoint)
concommand.Add("measure_insert", InsertMeasuredPoint)
concommand.Add("measure_list", ListMeasuredPoints)
concommand.Add("measure_clear", ClearMeasuredPoints)
concommand.Add("measure_sum", SumMeasuredPoints)
concommand.Add("measure_between", BetweenMeasuredPoints)
concommand.Add("measure_remove", RemoveMeasuredPoint)
concommand.Add("measure_remove_last", RemoveLastMeasuredPoint)
concommand.Add("measure_replace", ReplaceMeasuredPoint)