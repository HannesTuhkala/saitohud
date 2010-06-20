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
-- $Id: core.lua 153 2010-06-14 04:40:25Z the.sk89q $

-- Geometry library.

local GEOM = {}
SaitoHUD.GEOM = GEOM

GEOM.Points = {}
GEOM.Lines = {}
GEOM.Planes = {}
GEOM.Angles = {}

--- Makes a dynamic vector class that will update its value every tick
-- (if needed). This is used for vectors local to an entity, so that they can
-- stay up to date.
-- @param constructorFunc Function to construct the object with
-- @param updateFunc Function that should return a new Vector or nil
-- @return Class table (with a __call)
function GEOM.MakeDynamicVectorType()
    local v = {
        _CachedVector = Vector(0, 0, 0),
        _LastUpdate = 0,
    }
    local mt = {
        __call = function(t, ...)
            local instance = {}
            local arg = {...}
            v.Initialize(instance, unpack(arg))
            setmetatable(instance, v)
            return instance
        end,
        __index = function(t, key)
            if CurTime() - t._LastUpdate ~= 0 then
                local v = t:Update()
                if v then t._CachedVector = v end
            end
            return t._CachedVector.__index(t, key)
        end
    }
    setmetatable(v, mt)
    return v
end

GEOM.EntityRelVector = GEOM.MakeDynamicVectorType()

--- Construct a vector that is relative to an entity.
-- @param x
-- @param y
-- @param z
-- @param ent Entity
function GEOM.EntityRelVector:Initialize(x, y, z, ent)
    self.LocalVector = ent:WorldToLocal(Vector(x, y, z))
    self.Entity = ent
end

--- Updates the vector.
-- @return Vector
function GEOM.EntityRelVector:Update()
    if ValidEntity(self.Entity) then
        return self.Entity:LocalToWorld(self.LocalVector)
    end
end

GEOM.Ray = SaitoHUD.MakeClass()

--- Creates a ray (point and direction).
-- @param 
function GEOM.Ray:Initialize(pt1, pt2)
    self.pt1 = pt1
    self.pt2 = pt2
end

GEOM.Line = SaitoHUD.MakeClass()

--- Creates a line.
-- @param 
function GEOM.Line:Initialize(pt1, pt2)
    self.pt1 = pt1
    self.pt2 = pt2
end

function GEOM.Line:__tostring()
    return tostring(self.pt1) .. " -> " .. tostring(self.pt2)
end

--- Used to get a built-in point.
-- @param key Key
-- @return Vector or nil
function GEOM.GetBuiltInPoint(key)
    key = key:lower()
    if key == "me" then
        return SaitoHUD.GetRefPos()
    elseif key == "trace" then
        local tr = SaitoHUD.GetRefTrace()
        return tr.HitPos
    end
end

function GEOM.SetPoint(key, v)
    GEOM.Points[key] = v
end

function GEOM.SetLine(key, v)
    GEOM.Lines[key] = v
end

function GEOM.SetPlane(key, v)
    GEOM.Planes[key] = v
end

function GEOM.SetAngle(key, v)
    if type(v) == "Angle" then v = v:Forward() end
    GEOM.Angles[key] = v
end

--- Returns the projection of a point onto a line segment in 3D space.
-- @param line
-- @param point
-- @return Distance
function GEOM.PointLineSegmentProjection(pt, line)
    local a = line.pt1:Distance(line.pt1)^2
    if a == 0 then return line.pt1 end
    local b = (pt - line.pt1):Dot(line.pt2 - line.pt1) / a
    if b < 0 then return line.pt1 end
    if b > 1 then return line.pt2 end
    return line.pt1 + b * (line.pt2 - line.pt1)
end