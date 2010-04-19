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

-- local function GeneralPanel(panel)
    -- panel:ClearControls()
    -- panel:AddHeader()
    
    -- local text = "The following option disables some features on non-Sandbox " ..
        -- "game modes, and it is merely meant as a deterrent from impulsive cheating."
    -- panel:AddControl("Label", {Text = text})
    
    -- panel:AddControl("CheckBox", {
        -- Label = "Unfair Usage Deterrent",
        -- Command = "saitohud_anti_unfair"
    -- })
-- end

local function SamplingPanel(panel)
    panel:ClearControls()
    panel:AddHeader()
    
    panel:AddControl("CheckBox", {
        Label = "Draw Sampled Data",
        Command = "sample_draw"
    })
    
    panel:AddControl("CheckBox", {
        Label = "Draw Nodes",
        Command = "sample_nodes"
    })
    
    panel:AddControl("CheckBox", {
        Label = "Draw Thick Lines",
        Command = "sample_thick"
    })
    
    
    panel:AddControl("CheckBox", {
        Label = "Fade Samples",
        Command = "sample_fade"
    })
    
    panel:AddControl("CheckBox", {
        Label = "Use Random Colors",
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
        Label = "Show Entity Information",
        Command = "entity_info"
    })
    
    panel:AddControl("CheckBox", {
        Label = "Show Player Info on Entity Information",
        Command = "entity_info_player"
    })
    
    panel:AddControl("Label", {Text = "Enter your filters below and press ENTER. The textboxes below will not show the last filter."})
    
    panel:AddControl("Label", {Text = "Triads Filter"})
    local triadsEntry = panel:AddControl("DTextEntry",{})
    triadsEntry:SetTall(20)
    triadsEntry:SetWide(100)
    triadsEntry:SetEnterAllowed(true)
    triadsEntry.OnEnter = function()
        LocalPlayer():ConCommand("triads_filter " .. triadsEntry:GetValue())
    end
    
    panel:AddControl("Label", {Text = "Overlay Filter"})
    local overlayEntry = panel:AddControl("DTextEntry",{})
    overlayEntry:SetTall(20)
    overlayEntry:SetWide(100)
    overlayEntry:SetEnterAllowed(true)
    overlayEntry.OnEnter = function()
        LocalPlayer():ConCommand("overlay_filter " .. overlayEntry:GetValue())
    end
    
    panel:AddControl("Label", {Text = "BBox Filter"})
    local bboxEntry = panel:AddControl("DTextEntry",{})
    bboxEntry:SetTall(20)
    bboxEntry:SetWide(100)
    bboxEntry:SetEnterAllowed(true)
    bboxEntry.OnEnter = function()
        LocalPlayer():ConCommand("bbox_filter " .. bboxEntry:GetValue())
    end
    
    if SaitoHUD.AntiUnfairTriggered() then
        panel:AddControl("Label", {Text = "WARNING: A non-sandbox game mode has been detected and the following options do not take effect."})
    else
        panel:AddControl("Label", {Text = "WARNING: The following options will get you BANNED on most non-Sandbox game modes."})
    end
    
    panel:AddControl("CheckBox", {
        Label = "Show Name Tags",
        Command = "name_tags"
    })
    
    panel:AddControl("CheckBox", {
        Label = "Show Player Bounding Boxes",
        Command = "player_boxes"
    })
    
    panel:AddControl("CheckBox", {
        Label = "Show Player Orientation Markers",
        Command = "player_markers"
    })
    
    panel:AddControl("CheckBox", {
        Label = "Show Player Line of Sights",
        Command = "trace_aims"
    })
end

--- PopulateToolMenu hook.
local function PopulateToolMenu()
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDHelp", "Help", "", "", HelpPanel)
    --spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDGeneral", "General", "", "", GeneralPanel)
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDSampling", "Sampling", "", "", SamplingPanel, {SwitchConVar="sample_draw"})
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDOverlays", "Overlay", "", "", OverlayPanel)
end

function SaitoHUD.UpdatePanels()
    HelpPanel(GetControlPanel("SaitoHUDHelp"))
    --GeneralPanel(GetControlPanel("SaitoHUDGeneral"))
    SamplingPanel(GetControlPanel("SaitoHUDSampling"))
    OverlayPanel(GetControlPanel("SaitoHUDOverlays"))
end

hook.Add("PopulateToolMenu", "SaitoHUD.PopulateToolMenu", PopulateToolMenu)