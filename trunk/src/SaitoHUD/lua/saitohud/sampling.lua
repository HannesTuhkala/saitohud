-- SaitoHUD
-- Copyright (c) 2009 sk89q <http://www.sk89q.com>
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

local sampleDraw = CreateClientConVar("sample_draw", "1", false, false)
local sampleResolution = CreateClientConVar("sample_resolution", "0.1", true, false)
local sampleSize = CreateClientConVar("sample_size", "100", true, false)
local sampleNodes = CreateClientConVar("sample_nodes", "1", true, false)
local sampleMultiple = CreateClientConVar("sample_multiple", "0", true, false)

cvars.AddChangeCallback("sample_resolution", function(cv, old, new)
	SaitoHUD.sampleResolution = sampleResolution:GetFloat()
end)

cvars.AddChangeCallback("sample_size", function(cv, old, new)
	SaitoHUD.sampleSize = sampleSize:GetFloat()
end)

cvars.AddChangeCallback("sample_nodes", function(cv, old, new)
	SaitoHUD.drawSampleNodes = sampleNodes:GetBool()
end)

SaitoHUD.samplers = {}
SaitoHUD.sampleResolution = sampleResolution:GetFloat()
SaitoHUD.sampleSize = sampleSize:GetFloat()
SaitoHUD.drawSampleNodes = sampleNodes:GetBool()

local SamplingContext = {}

function SamplingContext:new(ent)
    local instance = {
        ["ent"] = ent,
        ["points"] = {},
    }
    
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function SamplingContext:Log(sampleSize)
    if not self.ent or not ValidEntity(self.ent) then
        self.Log = function() end
        self.Draw = function() end
        return false
    end
    
    table.insert(self.points, self.ent:GetPos())
    while #self.points > SaitoHUD.sampleSize do
        table.remove(self.points, 1)
    end
    
    return true
end

function SamplingContext:Draw(drawNodes)
    if not self.ent or not ValidEntity(self.ent) then
        self.Log = function() end
        self.Draw = function() end
        return false
    end
    
    local dim = 5
    local currentPos = self.ent:GetPos()
    local lastPt = nil
    
    surface.SetDrawColor(0, 255, 255, 255)
    
    for _, pt in pairs(self.points) do
        if lastPt != nil and lastPt != pt then 
            local from = lastPt:ToScreen()
            local to = pt:ToScreen()
            
            if from.visible and to.visible then
                surface.DrawLine(from.x, from.y, to.x, to.y)
                
                if SaitoHUD.drawSampleNodes then
                    surface.DrawOutlinedRect(to.x - dim / 2, to.y - dim / 2, dim, dim)
                end
            end
        end
        
        lastPt = pt
    end
    
    if lastPt != nil and lastPt != currentPos then 
        local from = lastPt:ToScreen()
        local to = currentPos:ToScreen()
        if from.visible and to.visible then
            surface.DrawLine(from.x, from.y, to.x, to.y)
        end
    end
    
    return true
end

function SaitoHUD.RemoveSample(ent)
    for k, ctx in pairs(SaitoHUD.samplers) do
        if ctx.ent == ent then
            table.remove(SaitoHUD.samplers, k)
        end
    end
end

function SaitoHUD.AddSample(ent)
    for k, ctx in pairs(SaitoHUD.samplers) do
        if ctx.ent == ent then
            return
        end
    end
    
    local ctx = SamplingContext:new(ent)
    table.insert(SaitoHUD.samplers, ctx)
end

function SaitoHUD.SetSample(ent)
    local ctx = SamplingContext:new(ent)
    SaitoHUD.samplers = {ctx}
end

function SaitoHUD.LogSamples()
    for k, ctx in pairs(SaitoHUD.samplers) do
        if not ctx:Log() then
            table.remove(SaitoHUD.samplers, k)
        end
    end
end

function SaitoHUD.DrawSamples()
    for k, ctx in pairs(SaitoHUD.samplers) do
        if not ctx:Draw() then
            table.remove(SaitoHUD.samplers, k)
        end
    end
end

concommand.Add("sample", function(ply, cmd, args)
    if not sampleMultiple:GetBool() then
        if table.Count(SaitoHUD.samplers) > 0 then
            LocalPlayer():ChatPrint("Note: Multiple entity sampling is disabled")
        end
        SaitoHUD.samplers = {}
    end
    
    if table.Count(args) == 0 then
        local tr = SaitoHUD.GetRefTrace()
        
        if ValidEntity(tr.Entity) then
            SaitoHUD.AddSample(tr.Entity)
            LocalPlayer():ChatPrint("Sampling entity #" ..  tr.Entity:EntIndex() .. ".")
        else
            LocalPlayer():ChatPrint("Nothing was found in an eye trace!")
        end
    elseif table.Count(args) == 1 then
        local m = SaitoHUD.MatchPlayerString(args[1])
        if m then
            SaitoHUD.AddSample(m)
            LocalPlayer():ChatPrint("Sampling player named " .. m:GetName() .. ".")
        else
            LocalPlayer():ChatPrint("No player was found by that name.")
        end
    else
        Msg("Invalid number of arguments")
    end
end, ConsoleAutocompletePlayer)

concommand.Add("sample_id", function(ply, cmd, args)
    if not sampleMultiple:GetBool() then
        if table.Count(SaitoHUD.samplers) > 0 then
            LocalPlayer():ChatPrint("Note: Multiple entity sampling is disabled")
        end
        SaitoHUD.samplers = {}
    end
    
    if table.Count(args) == 1 then
        local idx = tonumber(args[1])
        local m = ents.GetByIndex(idx)
        if ValidEntity(m) then
            SaitoHUD.AddSample(m)
            LocalPlayer():ChatPrint("Sampling entity of class " .. m:GetClass() .. ".")
        else
            LocalPlayer():ChatPrint("No entity was found by that index.")
        end
    else
        Msg("Invalid number of arguments")
    end
end)
 
concommand.Add("sample_remove", function(ply, cmd, args)
    if table.Count(args) == 0 then
        local tr = SaitoHUD.GetRefTrace()
        
        if ValidEntity(tr.Entity) then
            SaitoHUD.RemoveSample(tr.Entity)
            LocalPlayer():ChatPrint("No longer sampling entity #" ..  tr.Entity:EntIndex() .. ".")
        else
            LocalPlayer():ChatPrint("Nothing was found in an eye trace!")
        end
    elseif table.Count(args) == 1 then
        local m = SaitoHUD.MatchPlayerString(args[1])
        if m then
            SaitoHUD.RemoveSample(m)
            LocalPlayer():ChatPrint("No longer sampling player named " .. m:GetName() .. ".")
        else
            LocalPlayer():ChatPrint("No player was found by that name.")
        end
    else
        Msg("Invalid number of arguments")
    end
end, ConsoleAutocompletePlayer)
 
concommand.Add("sample_remove_id", function(ply, cmd, args)
    if table.Count(args) == 1 then
        local idx = tonumber(args[1])
        local m = ents.GetByIndex(idx)
        if ValidEntity(m) then
            SaitoHUD.RemoveSample(m)
            LocalPlayer():ChatPrint("No longer sampling entity of class " .. m:GetClass() .. ".")
        else
            LocalPlayer():ChatPrint("No entity was found by that index.")
        end
    else
        Msg("Invalid number of arguments")
    end
end, ConsoleAutocompletePlayer)
 
concommand.Add("sample_clear", function(ply, cmd, args)
    if table.Count(SaitoHUD.samplers) == 0 then
        LocalPlayer():ChatPrint("No samplers are active.")
    else
        LocalPlayer():ChatPrint(table.Count(SaitoHUD.samplers) .. " sampler(s) removed.")
        SaitoHUD.samplers = {}
    end
end)
 
concommand.Add("sample_list", function(ply, cmd, args)
    if #SaitoHUD.samplers > 0 then
        for k, ctx in pairs(SaitoHUD.samplers) do
            if ValidEntity(ctx.ent) then
                print(string.format("#%d %s (%s)", ctx.ent:EntIndex(), ctx.ent:GetClass(), 
                                    ctx.ent:GetModel()))
            end
        end
    else
        print("Nothing is being sampled.")
    end
end)

local lastSample = 0

hook.Add("HUDPaint", "SaitoHUDSampling", function()
    if CurTime() - lastSample > SaitoHUD.sampleResolution then
        SaitoHUD.LogSamples()
        lastSample = CurTime()
    end
    if sampleDraw:GetBool() then
        SaitoHUD.DrawSamples(true)
    end
end)