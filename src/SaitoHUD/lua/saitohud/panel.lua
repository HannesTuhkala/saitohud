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

local function HelpPanel(panel)
    panel:ClearControls()
    panel:AddHeader()
    
    local button = panel:AddControl("DButton", {})
	button:SetText("Help")
	button.DoClick = function(button)
		SaitoHUD.OpenHelp()
	end
end

local function SamplingPanel(panel)
	panel:ClearControls()
    panel:AddHeader()
	
	panel:AddControl("CheckBox", {
		Label = "Enabled",
		Command = "sample_draw"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Draw Nodes",
		Command = "sample_nodes"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Draw Thick",
		Command = "sample_thick"
	})
	
	
	panel:AddControl("CheckBox", {
		Label = "Fade Sample",
		Command = "sample_fade"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Random Color",
		Command = "sample_randomcolor"
	})
	
	
	panel:AddControl("CheckBox", {
		Label = "Allow Multiple",
		Command = "sample_multiple"
	})
	
	panel:AddControl("Slider", {
		Label = "Resolution",
		Command = "sample_resolution",
		Type = "integer",
		min = "1",
		max = "500"
	})
	
	panel:AddControl("Slider", {
		Label = "Length",
		Command = "sample_size",
		Type = "integer",
		min = "1",
		max = "500"
	})
	
	panel:AddControl("TextBox", {
		Label = "Sample",
		Command = "sample",
		WaitForEnter = true
	})
	panel:AddControl("TextBox", {
		Label = "Remove Sample",
		Command = "sample_remove",
		WaitForEnter = true
	})
end

local function OverlayPanel(panel)
	panel:ClearControls()
    panel:AddHeader()
	
	panel:AddControl("CheckBox", {
		Label = "Entity Info",
		Command = "entity_info"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Name Tags",
		Command = "name_tags"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Player Boxes",
		Command = "player_boxes"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Player Arrows",
		Command = "player_markers"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Player Line of Sight",
		Command = "trace_aims"
	})
	
	panel:AddControl("TextBox", {
		Label = "Triads Filter",
		Command = "triads_filter",
		WaitForEnter = true
	})
	panel:AddControl("TextBox", {
		Label = "Overlay Filter",
		Command = "overlay_filter",
		WaitForEnter = true
	})
	panel:AddControl("TextBox", {
		Label = "BBox Filter",
		Command = "bbox_filter",
		WaitForEnter = true
	})
end

--- PopulateToolMenu hook.
local function PopulateToolMenu()
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDHelp", "Help", "", "", HelpPanel)
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDSampling", "Sampling", "", "", SamplingPanel, {SwitchConVar="sample_draw"})
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDOverlays", "Overlay", "", "", OverlayPanel)
end

function SaitoHUD.UpdatePanels()
    HelpPanel(GetControlPanel("SaitoHUDHelp"))
    SamplingPanel(GetControlPanel("SaitoHUDSampling"))
    OverlayPanel(GetControlPanel("SaitoHUDOverlays"))
end

hook.Add("PopulateToolMenu", "SaitoHUD.PopulateToolMenu", PopulateToolMenu)