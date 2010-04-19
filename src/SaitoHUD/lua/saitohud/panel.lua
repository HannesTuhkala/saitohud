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
        Label = "Resolution (ms)",
        Command = "sample_resolution",
        Type = "integer",
        min = "1",
        max = "500"
    })
    
    panel:AddControl("Slider", {
        Label = "Data Point History Size",
        Command = "sample_size",
        Type = "integer",
        min = "1",
        max = "500"
    })
    
    panel:AddControl("Label", {Text = "Sample"})
    local SampleEntry = panel:AddControl("DTextEntry",{})
    SampleEntry:SetTall(20)
    SampleEntry:SetWide(100)
    SampleEntry:SetEnterAllowed(true)
    SampleEntry.OnEnter = function()
        LocalPlayer():ConCommand("sample " .. SampleEntry:GetValue())
    end
    
    panel:AddControl("Label", {Text = "Remove Sample"})
    local RemoveEntry = panel:AddControl("DTextEntry",{})
    RemoveEntry:SetTall(20)
    RemoveEntry:SetWide(100)
    RemoveEntry:SetEnterAllowed(true)
    RemoveEntry.OnEnter = function()
        LocalPlayer():ConCommand("sample_remove " .. RemoveEntry:GetValue())
    end
    
end

local function OverlayPanel(panel)
    panel:ClearControls()
    panel:AddHeader()
    
    panel:AddControl("CheckBox", {
        Label = "Entity Info",
        Command = "entity_info"
    })
    
    panel:AddControl("CheckBox", {
        Label = "Player Info on Entity Info",
        Command = "entity_info_player"
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
    
    panel:AddControl("Label", {Text = "Triads Filter"})
    local TriadsEntry = panel:AddControl("DTextEntry",{})
    TriadsEntry:SetTall(20)
    TriadsEntry:SetWide(100)
    TriadsEntry:SetEnterAllowed(true)
    TriadsEntry.OnEnter = function()
        LocalPlayer():ConCommand("triads_filter " .. TriadsEntry:GetValue())
    end
    
    panel:AddControl("Label", {Text = "Overlay Filter"})
    local OverlayEntry = panel:AddControl("DTextEntry",{})
    OverlayEntry:SetTall(20)
    OverlayEntry:SetWide(100)
    OverlayEntry:SetEnterAllowed(true)
    OverlayEntry.OnEnter = function()
        LocalPlayer():ConCommand("overlay_filter " .. OverlayEntry:GetValue())
    end
    
    panel:AddControl("Label", {Text = "BBox Filter"})
    local BBoxEntry = panel:AddControl("DTextEntry",{})
    BBoxEntry:SetTall(20)
    BBoxEntry:SetWide(100)
    BBoxEntry:SetEnterAllowed(true)
    BBoxEntry.OnEnter = function()
        LocalPlayer():ConCommand("bbox_filter " .. BBoxEntry:GetValue())
    end
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