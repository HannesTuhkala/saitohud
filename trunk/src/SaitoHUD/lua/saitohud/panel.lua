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
local function AddInput(panel, text, unfair)
    panel:AddControl("Label", {Text = text})
    local entry = panel:AddControl("DTextEntry",{})
    entry:SetTall(20)
    entry:SetWide(100)
    entry:SetEnterAllowed(true)
  
    if unfair==1 then
        entry:SetEditable(not SaitoHUD.AntiUnfairTriggered())
        entry:SetDrawBackground(false)
    end
    return entry
end

local function AddToggle(panel, text, command, unfair)
    local c = panel:AddControl("CheckBox", {
        Label = text,
        Command = command
    })
    if unfair==1 then
        c:SetDisabled(SaitoHUD.AntiUnfairTriggered())
    end
    return c
end


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
    
    AddToggle(panel,"Draw Sampled Data","sample_draw",1)
    AddToggle(panel,"Draw Nodes","sample_nodes",0)
    AddToggle(panel,"Draw Thick Lines","sample_thick",0)
    AddToggle(panel,"Fade Samples","sample_fade",0)
    AddToggle(panel,"Use Random Colors","sample_random_color",0)
    AddToggle(panel,"Allow Multiple","sample_multiple",0)
    
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
    
    local entry = AddInput(panel,"Sample Player Name:",1)
    entry.OnEnter = function()
        LocalPlayer():ConCommand("sample " .. entry:GetValue())
    end
    
    local entry = AddInput(panel,"Remove Player by Name:",1)
    entry.OnEnter = function()
        LocalPlayer():ConCommand("sample_remove " .. entry:GetValue())
    end
    
    local entry = AddInput(panel,"Sample by Filter:",1)
    entry.OnEnter = function()
        LocalPlayer():ConCommand("sample_filter " .. entry:GetValue())
    end
    
    local entry = AddInput(panel,"Remove by Filter:",1)
    entry.OnEnter = function()
        LocalPlayer():ConCommand("sample_remove_filter " .. entry:GetValue())
    end
    
    local button = panel:AddControl("Button", {
        Label = "Remove All Samplers",
        Command = "sample_clear",
    })
     button:SetDisabled(SaitoHUD.AntiUnfairTriggered())
end

local function OverlayPanel(panel)
    panel:ClearControls()
    panel:AddHeader()
    
    AddToggle(panel,"Show Entity Information","entity_info",0)
    AddToggle(panel,"Show Player Info on Entity Information","entity_info_player",0)
    
    if SaitoHUD.AntiUnfairTriggered() then
        panel:AddControl("Label", {Text = "WARNING: A non-sandbox game mode has been detected and the following options do not take effect."})
    end
    
    AddToggle(panel,"Show Name Tags","name_tags",1)
    AddToggle(panel,"Show Player Bounding Boxes","player_boxes",1)
    AddToggle(panel,"Show Player Orientation Markers","player_markers",1)
    AddToggle(panel,"Show Player Line of Sights","trace_aims",1)
    
    local entry = AddInput(panel,"Triads Filter:",1)
    entry.OnEnter = function()
        LocalPlayer():ConCommand("triads_filter " .. entry:GetValue())
    end
    
    local entry = AddInput(panel,"Overlay Filter:",1)
    entry.OnEnter = function()
        LocalPlayer():ConCommand("triads_filter " .. entry:GetValue())
    end
    
    local entry = AddInput(panel,"Bounding Box Filter:",1)
    entry.OnEnter = function()
        LocalPlayer():ConCommand("overlay_filter " .. entry:GetValue())
    end
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