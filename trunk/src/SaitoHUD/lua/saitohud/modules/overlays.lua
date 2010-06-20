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
-- $Id: overlays.lua 155 2010-06-18 19:37:23Z the.sk89q $

--- This file is responsible for a lot of the HUD overlays.

local drawEntityInfo = CreateClientConVar("entity_info", "1", true, false)
local showPlayerInfo = CreateClientConVar("entity_info_player", "0", true, false)
local alwaysDrawFriendTags = CreateClientConVar("friend_tags_always", "0", true, false)
local drawNameTags = CreateClientConVar("name_tags", "0", true, false)
local simpleNameTags = CreateClientConVar("name_tags_simple", "0", true, false)
local rainbowFriends = CreateClientConVar("name_tags_rainbow_friends", "0", true, false)
local boldFriends = CreateClientConVar("name_tags_bold_friends", "1", true, false)
local playerDistances = CreateClientConVar("name_tags_distances", "1", true, false)
local playerBoxes = CreateClientConVar("player_boxes", "0", true, false)
local playerMarkers = CreateClientConVar("player_markers", "0", true, false)
local overlayFilterText = CreateClientConVar("overlay_filter_text", "class", true, false)
local overlayFilterPrint = CreateClientConVar("overlay_filter_print_removed", "0", true, false)
local evaluateOnEveryDraw = CreateClientConVar("overlays_continuous_eval", "0", true, false)

local lastTriadsFilter = nil -- Legacy support
local lastOverlayMatch = 0
local triadsFilter = nil
local overlayFilter = nil
local bboxFilter = nil
-- These are used to cache the filter results for short periods of time
local triadsMatches = {}
local overlayMatches = {}
local bboxMatches = {}
-- Used for temporary storage
local peakSpeeds = {}
local peakEntityInfo = {}

local Rehook = function() end

--- Draw a triad.
-- @param p1 Point
-- @param ang Angle
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

--- Builds the cache of matched of entities. This is to significantly increase
-- performance, as evaluating the filter is a fairly resource intensive task.
local function EvaluateFilters()
    -- Check to make sure that we even have a filter to update
    if not triadsFilter and not overlayFilter and
       not bboxFilter then
        return
    end
    
    triadsMatches = {}
    overlayMatches = {}
    bboxMatches = {}
    
    local refPos = SaitoHUD.GetRefPos()
    
    for _, ent in pairs(ents.GetAll()) do
        if ValidEntity(ent) then
            local cls = ent:GetClass()
            local pos = ent:GetPos()
            
            --- Class may be empty
            if cls == "" or not cls then
                cls = "<?>"
            end
            
            if cls != "viewmodel" and -- cls:sub(1, 7) != "weapon_" and cls != "player" and 
               cls != "physgun_beam" and cls != "gmod_tool" and
               cls != "gmod_camera" and cls != "worldspawn" then
                if triadsFilter and triadsFilter.f(ent, refPos) then
                    table.insert(triadsMatches, ent)
                end
                
                if overlayFilter and overlayFilter.f(ent, refPos) then
                    table.insert(overlayMatches, ent)
                end
                
                if bboxFilter and bboxFilter.f(ent, refPos) then
                    table.insert(bboxMatches, ent)
                end
            end
        end
    end
    
    -- Clear dead entities from caches
    for k, _ in pairs(peakSpeeds) do
        local ent = ents.GetByIndex(k)
        if not ValidEntity(ent) then
            if overlayFilterPrint:GetBool() then
                print(string.format("%s removed, peak speed was %f",
                                    peakEntityInfo[k],
                                    peakSpeeds[k]))
            end
            
            peakSpeeds[k] = nil
        end
    end
end

--- Console command to clear overlay caches.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function ClearOverlayCaches(ply, cmd, args)
    peakSpeeds = {}
    peakEntityInfo = {}
end

--- Draw the overlays.
local function OverlaysPaint()
    -- Check to make sure that we even have a filter to draw
    if not triadsFilter and not overlayFilter and
       not bboxFilter then
        return
    end
    
    if CurTime() - lastOverlayMatch > 1 or evaluateOnEveryDraw:GetBool() then
        EvaluateFilters()
        lastOverlayMatch = CurTime()
    end
    
    local refPos = SaitoHUD.GetRefPos()
    
    for _, ent in pairs(triadsMatches) do
        if ValidEntity(ent) then
            local pos = ent:GetPos()
            DrawTriad(pos, ent:GetAngles())
        end
    end
    
    local ot = overlayFilterText:GetString()
    
    for _, ent in pairs(overlayMatches) do
        if ValidEntity(ent) then
            local text = "<INVALID>"
            local pos = ent:GetPos()
            local screenPos = pos:ToScreen()
            
            if ot == "class" then
                text = ent:GetClass()
            elseif ot == "model" then
                text = ent:GetModel()
            elseif ot == "id" then
                text = tostring(ent:EntIndex())
            elseif ot == "material" then
                text = ent:GetMaterial()
            elseif ot == "speed" then
                local speed = ent:GetVelocity():Length()
                if speed == 0 then
                    text = "Z"
                else
                    text = string.format("%0.1f", speed)
                end
            elseif ot == "peakspeed" then
                local index = ent:EntIndex()
                local speed = ent:GetVelocity():Length()
                if not peakSpeeds[index] then
                    peakSpeeds[index] = speed
                    peakEntityInfo[index] = string.format("%s [%s]",
                                            ent:GetClass(),
                                            ent:GetModel())
                else
                    if speed > peakSpeeds[index] then
                        peakSpeeds[index] = speed
                    end
                end
                if peakSpeeds[index] == 0 then
                    text = "Z"
                else
                    text = string.format("%0.1f", peakSpeeds[index])
                end
            end
            
            if text == nil then text = "" end
            
            draw.SimpleText(text, "TabLarge", screenPos.x, screenPos.y,
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

--- Draws the entity information on screen.
local function EntityInfoPaint()
    if SaitoHUD.Gesturing then return end
    
    local lines = SaitoHUD.GetEntityInfoLines(showPlayerInfo:GetBool(), 
                                               drawEntityInfo:GetBool())
    
    if table.Count(lines) > 0 then
        local color = Color(255, 255, 255, 255)
        
        local yOffset = ScrH() * 0.3
        for _, s in pairs(lines) do
            draw.SimpleText(s, "TabLarge", ScrW() - 16, yOffset, color, 2, ALIGN_TOP)
            yOffset = yOffset + 14
        end
    end
end

--- Draw the name tags.
local function NameTagsPaint()
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
            local bold = false
            
            local isFriend = SaitoHUD.IsFriend(ply)
            
            if drawNameTags:GetBool() or (alwaysDrawFriendTags:GetBool() and isFriend) then       
                if SaitoHUD.NameTagsColorHook and not SaitoHUD.ShouldIgnoreHook() then
                    color, shadowColor = SaitoHUD.NameTagsColorHook(ply)
                else
                    if isFriend then
                        bold = boldFriends:GetBool()
                        
                        if rainbowFriends:GetBool() then
                            color = HSVToColor(math.sin(CurTime() * 360 / 500) * 360, 1, 1)
                        else
                            color = SaitoHUD.GetFriendColor(ply)
                        end
                    end
                end
                
                local text = name
                if playerDistances:GetBool() then
                    text = text .. "[" .. tostring(distance) .. "]"
                end
                
                if simpleNameTags:GetBool() then
                    if bold then
                        draw.SimpleText(text,
                                        "DefaultBold", screenPos.x + 1, screenPos.y + 1,
                                        shadowColor, 1, ALIGN_TOP)
                        draw.SimpleText(text,
                                        "DefaultBold", screenPos.x, screenPos.y,
                                        color, 1, ALIGN_TOP)
                    else
                        draw.SimpleText(text,
                                        "DefaultSmallDropShadow", screenPos.x + 1, screenPos.y + 1,
                                        color, 1, ALIGN_TOP)
                    end
                else
                    if bold then
                        draw.SimpleTextOutlined(text,
                                                "DefaultBold", screenPos.x, screenPos.y,
                                                color, 1, ALIGN_TOP, 1, shadowColor)
                    else
                        draw.SimpleTextOutlined(text,
                                                "DefaultSmall", screenPos.x, screenPos.y,
                                                color, 1, ALIGN_TOP, 1, shadowColor)
                    end
                end
            end
        end
    end
end

--- Draw player bounding boxes.
local function PlayerBBoxesPaint()
    local refPos = SaitoHUD.GetRefPos()
    
    for _, ply in pairs(player.GetAll()) do
        local doDraw = ply ~= LocalPlayer()
        
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
                Vector(obbMin.x, obbMin.y, obbMin.z),
                Vector(obbMin.x, obbMax.y, obbMin.z),
                Vector(obbMax.x, obbMax.y, obbMin.z),
                Vector(obbMax.x, obbMin.y, obbMin.z),
                Vector(obbMin.x, obbMin.y, obbMax.z),
                Vector(obbMin.x, obbMax.y, obbMax.z),
                Vector(obbMax.x, obbMax.y, obbMax.z),
                Vector(obbMax.x, obbMin.y, obbMax.z),
            }
            
            local front = Vector(0, 0, 40)
            front:Rotate(Angle(0, ply:EyeAngles().y, 0))
            front = ply:LocalToWorld(front):ToScreen()
            local front2 = Vector(50, 0, 40)
            front2:Rotate(Angle(0, ply:EyeAngles().y, 0))
            front2 = ply:LocalToWorld(front2):ToScreen()
            
            local visible = true
            for i = 1, 8 do
                p[i]:Rotate(Angle(0, ply:EyeAngles().y, 0))
                p[i] = ply:LocalToWorld(p[i])
                p[i] = p[i]:ToScreen()
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

--- Draw player orientation markers.
local function PlayerMarkersPaint()
    for _, ply in pairs(player.GetAll()) do
        local doDraw = ply ~= LocalPlayer()
        
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
                Vector(0, 10, 0),
                Vector(0, -10, 0),
                Vector(10, 0, 0),
            }
            
            local visible = true
            for i = 1, 3 do
                p[i]:Rotate(Angle(0, ply:EyeAngles().y, 0))
                p[i] = ply:LocalToWorld(p[i])
                p[i] = p[i]:ToScreen()
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

--- Console command to change the triads filter.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function SetTriadsFilter(ply, cmd, args)
    triadsFilter = SaitoHUD.entityFilter.Build(args, true)
    
    Rehook()
end

--- Console command to set the overlay filter.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function SetOverlayFilter(ply, cmd, args)
    overlayFilter = SaitoHUD.entityFilter.Build(args, true)
    
    Rehook()
end

--- Console command to set the bounding box filter.
-- @param ply Player
-- @param cmd Command
-- @param args Arguments
local function SetBBoxFilter(ply, cmd, args)
    bboxFilter = SaitoHUD.entityFilter.Build(args, true)
    
    Rehook()
end

--- Legacy console command to "toggle" the triads filter.
local function ToggleTriads(ply, cmd, args)
    if triadsFilter then
        lastTriadsFilter = triadsFilter
        triadsFilter = nil
    else
        if lastTriadsFilter then
            triadsFilter = lastTriadsFilter
        else
            triadsFilter = SaitoHUD.entityFilter.Build({"*"}, true)
        end
    end
    
    Rehook()
end

--- Adjusts hooks as necessary.
Rehook = function()
    -- Entity info
    if showPlayerInfo:GetBool() or drawEntityInfo:GetBool() then
        hook.Add("HUDPaint", "SaitoHUD.EntityInfo", EntityInfoPaint)
    else
        SaitoHUD.RemoveHook("HUDPaint", "SaitoHUD.EntityInfo")
    end
    
    -- Filters
    if (triadsFilter or overlayFilter or bboxFilter) and not
        SaitoHUD.AntiUnfairTriggered() then
        hook.Add("HUDPaint", "SaitoHUD.Overlays", OverlaysPaint)
    else
        SaitoHUD.RemoveHook("HUDPaint", "SaitoHUD.Overlays")
    end
    
    -- Name tags
    if (drawNameTags:GetBool() or alwaysDrawFriendTags:GetBool()) and not SaitoHUD.AntiUnfairTriggered() then
        hook.Add("HUDPaint", "SaitoHUD.NameTags", NameTagsPaint)
    else
        SaitoHUD.RemoveHook("HUDPaint", "SaitoHUD.NameTags")
    end
    
    -- Player bounding boxes
    if playerBoxes:GetBool() and not SaitoHUD.AntiUnfairTriggered() then
        hook.Add("HUDPaint", "SaitoHUD.PlayerBBoxes", PlayerBBoxesPaint)
    else
        SaitoHUD.RemoveHook("HUDPaint", "SaitoHUD.PlayerBBoxes")
    end
    
    -- Player orientation markers
    if playerMarkers:GetBool() and not SaitoHUD.AntiUnfairTriggered() then
        hook.Add("HUDPaint", "SaitoHUD.PlayerMarkers", PlayerMarkersPaint)
    else
        SaitoHUD.RemoveHook("HUDPaint", "SaitoHUD.PlayerMarkers")
    end
end

concommand.Add("triads_filter", SetTriadsFilter)
concommand.Add("overlay_filter", SetOverlayFilter)
concommand.Add("overlay_filter_clear_cache", ClearOverlayCaches)
concommand.Add("bbox_filter", SetBBoxFilter)
concommand.Add("toggle_triads", ToggleTriads)
concommand.Add("dump_info", function() SaitoHUD.DumpEntityInfo() end)

-- Need to rehook
cvars.AddChangeCallback("entity_info", Rehook)
cvars.AddChangeCallback("entity_info_player", Rehook)
cvars.AddChangeCallback("name_tags", Rehook)
cvars.AddChangeCallback("friend_tags_always", Rehook)
cvars.AddChangeCallback("player_boxes", Rehook)
cvars.AddChangeCallback("player_markers", Rehook)
cvars.AddChangeCallback("overlay_filter_text", ClearOverlayCaches)

Rehook()