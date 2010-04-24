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

-- Basic drawing functions.

--- Draws the bounding box of an entity.
-- @param ent Entity to draw bounding box for
-- @param color Color to draw the bounding box in
function SaitoHUD.DrawBBox(ent, color)
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
    
    local front = ent:LocalToWorld(Vector(0, 0, 40)):ToScreen()
    local front2 = ent:LocalToWorld(Vector(50, 0, 40)):ToScreen()
    
    -- Odd things happen if not all the points are visible
    local visible = true
    for i = 1, 8 do
        if not p[i].visible then
            visible = false
            break
        end
    end
    
    if visible then
        local r, g, b, a = color
        surface.SetDrawColor(r, g, b, a)
        
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

--- Draws a 2D line in 3D-space. This must be called within a cam.Start3D
-- section.
-- @param p1 Start
-- @param p2 End
function SaitoHUD.Draw3D2DLine(p1, p2)
    -- Draw the line
    cam.Start3D2D(p1, (p2 - p1):Angle(), 1)
    surface.DrawLine(0, 0, p1:Distance(p2), 0)
    cam.End3D2D()
end