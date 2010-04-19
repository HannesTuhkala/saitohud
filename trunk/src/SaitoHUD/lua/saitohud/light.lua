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

local lightEnabled = false

local function RenderFlashlight()
	local light = DynamicLight(123120000) 
    
	if light then 
		light.Pos = LocalPlayer():GetEyeTrace().HitPos
		light.r = 255
		light.g = 255 
		light.b = 255
		light.Brightness = 1
		light.Size = 2000
		light.Decay = 0 
		light.DieTime = CurTime() + 0.3
	end 
	local light = DynamicLight(123120001) 
    
	if light then 
		light.Pos = LocalPlayer():GetPos()
		light.r = 255
		light.g = 255 
		light.b = 255
		light.Brightness = 1
		light.Size = 2000
		light.Decay = 0 
		light.DieTime = CurTime() + 0.3
	end 
end  

concommand.Add("super_flashlight", function()
	lightEnabled = not lightEnabled
    
	surface.PlaySound("items/flashlight1.wav")
    
	if lightEnabled then
		hook.Add("Think", "SaitoHUD.Super.Flashlight", RenderFlashlight)
	else
		hook.Remove("Think", "SaitoHUD.Super.Flashlight")
	end
end)