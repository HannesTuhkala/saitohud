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
    
    if SaitoHUD.AntiUnfairTriggered() then
        panel:AddControl("Label", {Text = "WARNING: A non-sandbox game mode has been detected and the following options do not take effect."})
    end
    
    local c = panel:AddControl("CheckBox", {
        Label = "Draw Sampled Data",
        Command = "sample_draw"
    })
    c:SetDisabled(SaitoHUD.AntiUnfairTriggered())
    
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
        Command = "sample_random_color"
    })
    
    panel:AddControl("CheckBox", {
        Label = "Allow Multiple",
        Command = "sample_multiple"
    })
    
    panel:AddControl("Slider", {
        Label = "Resolution (ms):",
        Command = "sample_resolution",
        Type = "integer",
        min = "1",
        max = "500"
    })
    
    panel:AddControl("Slider", {
        Label = "Data Point History Size:",
        Command = "sample_size",
        Type = "integer",
        min = "1",
        max = "500"
    })
    
    panel:AddControl("Label", {Text = "Sample Player Name:"})
    local sampleEntry = panel:AddControl("DTextEntry",{})
    sampleEntry:SetTall(20)
    sampleEntry:SetWide(100)
    sampleEntry:SetEnterAllowed(true)
    sampleEntry.OnEnter = function()
        LocalPlayer():ConCommand("sample " .. sampleEntry:GetValue())
    end
    sampleEntry:SetEditable(not SaitoHUD.AntiUnfairTriggered())
    
    panel:AddControl("Label", {Text = "Remove Player by Name:"})
    local removeEntry = panel:AddControl("DTextEntry",{})
    removeEntry:SetTall(20)
    removeEntry:SetWide(100)
    removeEntry:SetEnterAllowed(true)
    removeEntry.OnEnter = function()
        LocalPlayer():ConCommand("sample_remove " .. removeEntry:GetValue())
    end
    removeEntry:SetEditable(not SaitoHUD.AntiUnfairTriggered())
    
    panel:AddControl("Label", {Text = "Sample by Filter:"})
    local sampleFilterEntry = panel:AddControl("DTextEntry",{})
    sampleFilterEntry:SetTall(20)
    sampleFilterEntry:SetWide(100)
    sampleFilterEntry:SetEnterAllowed(true)
    sampleFilterEntry.OnEnter = function()
        LocalPlayer():ConCommand("sample_filter " .. sampleFilterEntry:GetValue())
    end
    sampleFilterEntry:SetEditable(not SaitoHUD.AntiUnfairTriggered())
    
    panel:AddControl("Label", {Text = "Remove by Filter:"})
    local removeFilterEntry = panel:AddControl("DTextEntry",{})
    removeFilterEntry:SetTall(20)
    removeFilterEntry:SetWide(100)
    removeFilterEntry:SetEnterAllowed(true)
    removeFilterEntry.OnEnter = function()
        LocalPlayer():ConCommand("sample_remove_filter " .. removeFilterEntry:GetValue())
    end
    removeFilterEntry:SetEditable(not SaitoHUD.AntiUnfairTriggered())
    
    local button = panel:AddControl("Button", {
        Label = "Remove All Samplers",
        Command = "sample_clear",
    })
     button:SetDisabled(SaitoHUD.AntiUnfairTriggered())
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
    
    if SaitoHUD.AntiUnfairTriggered() then
        panel:AddControl("Label", {Text = "WARNING: A non-sandbox game mode has been detected and the following options do not take effect."})
    end
    
    local c = panel:AddControl("CheckBox", {
        Label = "Show Name Tags",
        Command = "name_tags"
    })
    c:SetDisabled(SaitoHUD.AntiUnfairTriggered())
    
    local c = panel:AddControl("CheckBox", {
        Label = "Show Player Bounding Boxes",
        Command = "player_boxes"
    })
    c:SetDisabled(SaitoHUD.AntiUnfairTriggered())
    
    local c = panel:AddControl("CheckBox", {
        Label = "Show Player Orientation Markers",
        Command = "player_markers"
    })
    c:SetDisabled(SaitoHUD.AntiUnfairTriggered())
    
    local c = panel:AddControl("CheckBox", {
        Label = "Show Player Line of Sights",
        Command = "trace_aims"
    })
    c:SetDisabled(SaitoHUD.AntiUnfairTriggered())
    
    panel:AddControl("Label", {Text = "Triads Filter:"})
    local triadsEntry = panel:AddControl("DTextEntry",{})
    triadsEntry:SetTall(20)
    triadsEntry:SetWide(100)
    triadsEntry:SetEnterAllowed(true)
    triadsEntry.OnEnter = function()
        LocalPlayer():ConCommand("triads_filter " .. triadsEntry:GetValue())
    end
    triadsEntry:SetEditable(not SaitoHUD.AntiUnfairTriggered())
    
    panel:AddControl("Label", {Text = "Overlay Filter:"})
    local overlayEntry = panel:AddControl("DTextEntry",{})
    overlayEntry:SetTall(20)
    overlayEntry:SetWide(100)
    overlayEntry:SetEnterAllowed(true)
    overlayEntry.OnEnter = function()
        LocalPlayer():ConCommand("overlay_filter " .. overlayEntry:GetValue())
    end
    overlayEntry:SetEditable(not SaitoHUD.AntiUnfairTriggered())
    
    panel:AddControl("Label", {Text = "Bounding Box Filter:"})
    local bboxEntry = panel:AddControl("DTextEntry",{})
    bboxEntry:SetTall(20)
    bboxEntry:SetWide(100)
    bboxEntry:SetEnterAllowed(true)
    bboxEntry.OnEnter = function()
        LocalPlayer():ConCommand("bbox_filter " .. bboxEntry:GetValue())
    end
    bboxEntry:SetEditable(not SaitoHUD.AntiUnfairTriggered())
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

SaitoHUD.UpdatePanels()