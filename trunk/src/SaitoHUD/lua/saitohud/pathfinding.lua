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

include("astar.lua")

local drawStartPos = Vector()
local drawEndPos = Vector()
local drawPoints = {}

local resolution = 500
local zResolution = 10

local function NormalizePos(pos)
    pos.x = math.floor(pos.x / resolution) * resolution
    pos.y = math.floor(pos.y / resolution) * resolution
    pos.z = math.floor(pos.z / zResolution) * zResolution
    return pos
end

local function Neighbors(node)
    drawPoints[node] = 1
    
    local neighbors = {
        node + Vector(resolution, 0, 0),
        node + Vector(-resolution, 0, 0),
        node + Vector(0, resolution, 0),
        node + Vector(0, -resolution, 0),
        -- node + Vector(resolution, resolution, 0),
        -- node + Vector(-resolution, resolution, 0),
        -- node + Vector(resolution, -resolution, 0),
        -- node + Vector(-resolution, -resolution, 0),
    }
    
    local selectedNeighbors = {}
    
    local testPos = LocalPlayer():GetPos()
    testPos.z = node.z
    for _, n in pairs(neighbors) do
        if n:Distance(testPos) < 1000 then
            table.insert(selectedNeighbors, n)
        end
    end
    
    return pairs(selectedNeighbors)
end

local function Walkable(currentNode, neighborNode, startNode, targetNode, heuristic)
    local data = {}
    data.start = currentNode
    data.endpos = neighborNode
    data.filter = LocalPlayer()
    local tr = util.TraceLine(data)
    return not tr.HitWorld
end

function Heuristic(nodeA, nodeB)
    return nodeA:Distance(nodeB)
end

function SaitoHUD.FindPath(startPos, endPos)
    startPos.z = endPos.z
    print(startPos, endPos)
    drawStartPos, drawEndPos = startPos, endPos
    local startNode = NormalizePos(startPos)
    local targetNode = NormalizePos(endPos)
    print(startNode, targetNode)
    --local h_a, h_b, h_c = debug.gethook()
    --debug.sethook()
    worked, path, statuses = astar.CalculatePath(startNode, targetNode, Neighbors, Walkable, Heuristic, {})
    --debug.sethook(h_a, h_b, h_c)
    LocalPlayer():ChatPrint("##########" .. tostring(worked))
    print(worked, path, statuses)
end

concommand.Add("pathfind", function(ply, cmd, args)
    SaitoHUD.FindPath(LocalPlayer():GetPos() + Vector(0, 0, 50), Vector(-521.8844,-2423.2922,204.8666))
    -- local m = SaitoHUD.MatchPlayerString(args[1])
    -- if m then
        -- SaitoHUD.FindPath(LocalPlayer():GetPos() + Vector(0, 0, 50), m:GetPos() + Vector(0, 0, 50))
        -- LocalPlayer():ChatPrint("Found player: " .. m:GetName() .. ".")
    -- else
        -- LocalPlayer():ChatPrint("No player was found by that name.")
    -- end
end, ConsoleAutocompletePlayer)

local function DrawPoint(pos, color)
    local p0 = pos:ToScreen()
    local p1 = (pos + Vector(0, 0, 100)):ToScreen()
    
    surface.SetDrawColor(color)
    surface.DrawLine(p0.x, p0.y, p1.x, p1.y)
end

hook.Add("HUDPaint", "SaitoHUDPathFind", function()
    DrawPoint(drawStartPos, Color(0, 255, 0))
    DrawPoint(drawEndPos, Color(255, 0, 0))
    
    for pos, _ in pairs(drawPoints) do
        DrawPoint(pos, Color(255, 255, 255))
    end
end)