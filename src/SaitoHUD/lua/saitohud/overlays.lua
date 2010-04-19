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

local drawEntityInfo = CreateClientConVar("entity_info", "1", true, false)
local showPlayerInfo = CreateClientConVar("entity_info_player", "0", true, false)
local drawNameTags = CreateClientConVar("name_tags", "0", true, false)
local playerBoxes = CreateClientConVar("player_boxes", "0", true, false)
local playerMarkers = CreateClientConVar("player_markers", "0", true, false)

SaitoHUD.triadsFilter = nil
SaitoHUD.overlayFilter = nil
SaitoHUD.bboxFilter = nil

local function DrawTriad(p1, ang)
    local p2 = p1 + ang:Forward() * 16
    local p3 = p1 - ang:Right() * 16
    local p4 = p1 + ang:Up() * 16
    
    p1, p2, p3, p4 = p1:ToScreen(), p2:ToScreen(), p3:ToScreen(), p4:ToScreen()
    
    surface.SetDrawColor(255, 0, 0, 255)
    surface.DrawLine(p1.x, p1.y, p2.x, p2.y)
    surface.SetDrawColor(0, 255, 0, 255)
    surface.DrawLine(p1.x, p1.y, p3.x, p3.y)
    surface.SetDrawColor(0, 0, 255, 255)
    surface.DrawLine(p1.x, p1.y, p4.x, p4.y)
end

function SaitoHUD.DrawEntityInfo()
    if SaitoHUD.Gesturing then
        return
    end
    
    local lines = SaitoHUD.GetEntityInfoLines(showPlayerInfo:GetBool())
    
    if table.Count(lines) > 0 then
        local color = Color(255, 255, 255, 255)
        
        local yOffset = ScrH() * 0.3
        for _, s in pairs(lines) do
            draw.SimpleText(s, "TabLarge", ScrW() - 16, yOffset, color, 2, ALIGN_TOP)
            yOffset = yOffset + 14
        end
    end
end

local lastOverlayMatch = 0
local triadsMatches = {}
local overlayMatches = {}
local bboxMatches = {}

local function UpdateOverlayMatches()
    if not SaitoHUD.triadsFilter and not SaitoHUD.overlayFilter and
       not SaitoHUD.bboxFilter then
        return
    end
    
    triadsMatches = {}
    overlayMatches = {}
    bboxMatches = {}
    
    local refPos = SaitoHUD.GetRefPos()
    
    for _, ent in pairs(ents.GetAll()) do
        if ValidEntity(ent) then
            local cls = ent:GetClass()
            if cls == "" or not cls then
                cls = "<?>"
            end
            local pos = ent:GetPos()
            
            if cls != "viewmodel" and -- cls:sub(1, 7) != "weapon_" and cls != "player" and 
               cls != "physgun_beam" and cls != "gmod_tool" and
               cls != "gmod_camera" and cls != "worldspawn" then
                if SaitoHUD.triadsFilter and SaitoHUD.triadsFilter.f(ent, refPos) then
                    table.insert(triadsMatches, ent)
                end
                
                if SaitoHUD.overlayFilter and SaitoHUD.overlayFilter.f(ent, refPos) then
                    table.insert(overlayMatches, ent)
                end
                
                if SaitoHUD.bboxFilter and SaitoHUD.bboxFilter.f(ent, refPos) then
                    table.insert(bboxMatches, ent)
                end
            end
        end
    end
end

function SaitoHUD.DrawOverlays()
    if not SaitoHUD.triadsFilter and not SaitoHUD.overlayFilter and
       not SaitoHUD.bboxFilter then
        return
    end
    
    if CurTime() - lastOverlayMatch > 1 then
        UpdateOverlayMatches()
        lastOverlayMatch = CurTime()
    end
    
    local refPos = SaitoHUD.GetRefPos()
    
    for _, ent in pairs(triadsMatches) do
        if ValidEntity(ent) then
            local pos = ent:GetPos()
            DrawTriad(pos, ent:GetAngles())
        end
    end
    
    for _, ent in pairs(overlayMatches) do
        if ValidEntity(ent) then
            local cls = ent:GetClass()
            local pos = ent:GetPos()
            local screenPos = pos:ToScreen()
            
            draw.SimpleText(cls, "TabLarge", screenPos.x, screenPos.y,
                            Color(255, 255, 255, 255), 1, ALIGN_TOP) 
        end
    end
    
    for _, ent in pairs(bboxMatches) do
        if ValidEntity(ent) then
            local pos = ent:GetPos()
            
            local obbMin = ent:OBBMins()
            local obbMax = ent:OBBMaxs()
            
            local p = {
                ent:LocalToWorld(Vector(obbMin.x, obbMin.y, obbMin.z)):ToScreen(),
                ent:LocalToWorld(Vector(obbMin.x, obbMax.y, obbMin.z)):ToScreen(),
                ent:LocalToWorld(Vector(obbMax.x, obbMax.y, obbMin.z)):ToScreen(),
                ent:LocalToWorld(Vector(obbMax.x, obbMin.y, obbMin.z)):ToScreen(),
                ent:LocalToWorld(Vector(obbMin.x, obbMin.y, obbMax.z)):ToScreen(),
                ent:LocalToWorld(Vector(obbMin.x, obbMax.y, obbMax.z)):ToScreen(),
                ent:LocalToWorld(Vector(obbMax.x, obbMax.y, obbMax.z)):ToScreen(),
                ent:LocalToWorld(Vector(obbMax.x, obbMin.y, obbMax.z)):ToScreen(),
            }
            
            local visible = true
            for i = 1, 8 do
                if not p[i].visible then
                    visible = false
                    break
                end
            end
            
            if visible then
                if ent:IsPlayer() then
                    if ent:Alive() then
                        surface.SetDrawColor(0, 255, 0, 255)
                    else
                        surface.SetDrawColor(0, 0, 255, 255)
                    end
                else
                    surface.SetDrawColor(255, 0, 0, 255)
                end
                -- Bottom
                surface.DrawLine(p[1].x, p[1].y, p[2].x, p[2].y)
                surface.DrawLine(p[2].x, p[2].y, p[3].x, p[3].y)
                surface.DrawLine(p[3].x, p[3].y, p[4].x, p[4].y)
                surface.DrawLine(p[4].x, p[4].y, p[1].x, p[1].y)
                -- Top
                surface.DrawLine(p[5].x, p[5].y, p[6].x, p[6].y)
                surface.DrawLine(p[6].x, p[6].y, p[7].x, p[7].y)
                surface.DrawLine(p[7].x, p[7].y, p[8].x, p[8].y)
                surface.DrawLine(p[8].x, p[8].y, p[5].x, p[5].y)
                -- Sides
                surface.DrawLine(p[1].x, p[1].y, p[5].x, p[5].y)
                surface.DrawLine(p[2].x, p[2].y, p[6].x, p[6].y)
                surface.DrawLine(p[3].x, p[3].y, p[7].x, p[7].y)
                surface.DrawLine(p[4].x, p[4].y, p[8].x, p[8].y)
                -- Bottom
                --surface.DrawLine(p[1].x, p[1].y, p[3].x, p[3].y)
            end
        end
    end
end

function SaitoHUD.DrawNameTags()
    local refPos = SaitoHUD.GetRefPos()
    
    for _, ply in pairs(player.GetAll()) do
        local doDraw = true
        
        if SaitoHUD.ShouldDrawPlayerOverlayHook and not SaitoHUD.ShouldIgnoreHook() then
            if not SaitoHUD.ShouldDrawPlayerOverlayHook(ply) then
                doDraw = false
            end
        end
        
        if doDraw then
            local name = ply:GetName()
            local screenPos = (ply:GetPos() + Vector(0, 0, 50)):ToScreen()
            local distance = math.Round(ply:GetPos():Distance(refPos))
            
            local color = Color(255, 255, 255, 255)
            local shadowColor = Color(0, 0, 0, 255)
            
            if SaitoHUD.NameTagsColorHook and not SaitoHUD.ShouldIgnoreHook() then
                color, shadowColor = SaitoHUD.NameTagsColorHook(ply)
            else
                if distance < 500 then
                    shadowColor = Color(255, 0, 0, 255)
                elseif distance < 800 then
                    color = Color(255, 100, 100, 255)
                elseif distance < 1200 then
                    color = Color(255, 255, 100, 255)
                end
                
                if name:find("sk89q") then
                    color = HSVToColor(math.sin(CurTime() * 360 / 500) * 360, 1, 1)
                end
            end
            
            draw.SimpleTextOutlined(string.format("%s [%s]", name, distance),
                                    "DefaultSmall", screenPos.x, screenPos.y,
                                    color, 1, ALIGN_TOP, 1, shadowColor)
        end
    end
end

function SaitoHUD.DrawPlayerBoxes()
    local refPos = SaitoHUD.GetRefPos()
    
    for _, ply in pairs(player.GetAll()) do
        local doDraw = true
        
        if SaitoHUD.ShouldDrawPlayerOverlayHook and not SaitoHUD.ShouldIgnoreHook() then
            if not SaitoHUD.ShouldDrawPlayerOverlayHook(ply) then
                doDraw = false
            end
        end
        
        if doDraw then
            local pos = ply:GetPos()
            
            local obbMin = ply:OBBMins()
            local obbMax = ply:OBBMaxs()
            
            local p = {
                ply:LocalToWorld(Vector(obbMin.x, obbMin.y, obbMin.z)):ToScreen(),
                ply:LocalToWorld(Vector(obbMin.x, obbMax.y, obbMin.z)):ToScreen(),
                ply:LocalToWorld(Vector(obbMax.x, obbMax.y, obbMin.z)):ToScreen(),
                ply:LocalToWorld(Vector(obbMax.x, obbMin.y, obbMin.z)):ToScreen(),
                ply:LocalToWorld(Vector(obbMin.x, obbMin.y, obbMax.z)):ToScreen(),
                ply:LocalToWorld(Vector(obbMin.x, obbMax.y, obbMax.z)):ToScreen(),
                ply:LocalToWorld(Vector(obbMax.x, obbMax.y, obbMax.z)):ToScreen(),
                ply:LocalToWorld(Vector(obbMax.x, obbMin.y, obbMax.z)):ToScreen(),
            }
            
            local front = ply:LocalToWorld(Vector(0, 0, 40)):ToScreen()
            local front2 = ply:LocalToWorld(Vector(50, 0, 40)):ToScreen()
            
            local visible = true
            for i = 1, 8 do
                if not p[i].visible then
                    visible = false
                    break
                end
            end
            
            if visible then
                if SaitoHUD.PlayerOverlayColorHook and not SaitoHUD.ShouldIgnoreHook() then
                    local r, g, b, a = SaitoHUD.PlayerOverlayColorHook(ply)
                    surface.SetDrawColor(r, g, b, a)
                else
                    if ply:Alive() then
                        surface.SetDrawColor(0, 255, 0, 255)
                    else
                        surface.SetDrawColor(0, 0, 255, 255)
                    end
                end
                
                -- Bottom
                surface.DrawLine(p[1].x, p[1].y, p[2].x, p[2].y)
                surface.DrawLine(p[2].x, p[2].y, p[3].x, p[3].y)
                surface.DrawLine(p[3].x, p[3].y, p[4].x, p[4].y)
                surface.DrawLine(p[4].x, p[4].y, p[1].x, p[1].y)
                -- Top
                surface.DrawLine(p[5].x, p[5].y, p[6].x, p[6].y)
                surface.DrawLine(p[6].x, p[6].y, p[7].x, p[7].y)
                surface.DrawLine(p[7].x, p[7].y, p[8].x, p[8].y)
                surface.DrawLine(p[8].x, p[8].y, p[5].x, p[5].y)
                -- Sides
                surface.DrawLine(p[1].x, p[1].y, p[5].x, p[5].y)
                surface.DrawLine(p[2].x, p[2].y, p[6].x, p[6].y)
                surface.DrawLine(p[3].x, p[3].y, p[7].x, p[7].y)
                surface.DrawLine(p[4].x, p[4].y, p[8].x, p[8].y)
                -- Bottom
                --surface.DrawLine(p[1].x, p[1].y, p[3].x, p[3].y)
                
                surface.DrawLine(front.x, front.y, front2.x, front2.y)
            end
        end
    end
end

function SaitoHUD.DrawPlayerMarkers()
    for _, ply in pairs(player.GetAll()) do
        local doDraw = true
        
        if SaitoHUD.ShouldDrawPlayerOverlayHook and not SaitoHUD.ShouldIgnoreHook() then
            if not SaitoHUD.ShouldDrawPlayerOverlayHook(ply) then
                doDraw = false
            end
        end
        
        if doDraw then
            local pos = ply:GetPos()
            
            local obbMin = ply:OBBMins()
            local obbMax = ply:OBBMaxs()
            
            local p = {
                ply:LocalToWorld(Vector(0, 10, 0)):ToScreen(),
                ply:LocalToWorld(Vector(0, -10, 0)):ToScreen(),
                ply:LocalToWorld(Vector(10, 0, 0)):ToScreen(),
            }
            
            local visible = true
            for i = 1, 3 do
                if not p[i].visible then
                    visible = false
                    break
                end
            end
            
            if visible then
                if SaitoHUD.PlayerOverlayColorHook and not SaitoHUD.ShouldIgnoreHook() then
                    local r, g, b, a = SaitoHUD.PlayerOverlayColorHook(ply)
                    surface.SetDrawColor(r, g, b, a)
                else
                    if ply:Alive() then
                        surface.SetDrawColor(0, 255, 0, 255)
                    else
                        surface.SetDrawColor(0, 0, 255, 255)
                    end
                end
                
                -- Bottom
                surface.DrawLine(p[1].x, p[1].y, p[2].x, p[2].y)
                surface.DrawLine(p[2].x, p[2].y, p[3].x, p[3].y)
                surface.DrawLine(p[3].x, p[3].y, p[1].x, p[1].y)
            end
        end
    end
end

local lastTriadsFilter = nil

concommand.Add("triads_filter", function(ply, cmd, args)
    SaitoHUD.triadsFilter = SaitoHUD.entityFilter.Build(args, true)
end)

concommand.Add("overlay_filter", function(ply, cmd, args)
    SaitoHUD.overlayFilter = SaitoHUD.entityFilter.Build(args, true)
end)

concommand.Add("bbox_filter", function(ply, cmd, args)
    SaitoHUD.bboxFilter = SaitoHUD.entityFilter.Build(args, true)
end)

concommand.Add("toggle_triads", function(ply, cmd, args)
    if SaitoHUD.triadsFilter then
        lastTriadsFilter = SaitoHUD.triadsFilter
        SaitoHUD.triadsFilter = nil
    else
        if lastTriadsFilter then
            SaitoHUD.triadsFilter = lastTriadsFilter
        else
            SaitoHUD.triadsFilter = SaitoHUD.entityFilter.Build({"*"}, true)
        end
    end
end)

concommand.Add("dump_info", function(ply, cmd, args)
    SaitoHUD.DumpEntityInfo()
end)

hook.Add("HUDPaint", "SaitoHUDOverlays", function()
    if drawEntityInfo:GetBool() then
        SaitoHUD.DrawEntityInfo()
    end
    if not SaitoHUD.AntiUnfairTriggered() then
        SaitoHUD.DrawOverlays()
        if drawNameTags:GetBool() then
            SaitoHUD.DrawNameTags()
        end
        if playerBoxes:GetBool() then
            SaitoHUD.DrawPlayerBoxes()
        end
        if playerMarkers:GetBool() then
            SaitoHUD.DrawPlayerMarkers()
        end
    end
end)