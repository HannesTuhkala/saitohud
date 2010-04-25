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


--ADD INPUT
local function AddInput(panel, text, command, clearOnEnter, unfair)
    panel:AddControl("Label", {Text = text})
    local entry = panel:AddControl("DTextEntry",{})
    entry:SetTall(20)
    entry:SetWide(100)
    entry:SetEnterAllowed(true)
    entry.OnEnter = function()
        LocalPlayer():ConCommand(command .." ".. entry:GetValue())
        if clearOnEnter then
            entry:SetValue("")
        end
    end
    
    if unfair then
        entry:SetEditable(not SaitoHUD.AntiUnfairTriggered())
        entry:SetDrawBackground(not SaitoHUD.AntiUnfairTriggered())
    end
    
    return entry
end

local function AddLabel(panel,text)
	panel:AddControl("Label",{Text=text})
end

--ADD TOGGLE
local function AddToggle(panel, text, command, unfair)
    local c = panel:AddControl("CheckBox", {
        Label = text,
        Command = command
    })
    if unfair then
        c:SetDisabled(SaitoHUD.AntiUnfairTriggered())
    end
    return c
end

--ADD BUTTON
local function AddButton(panel,label,command)
	button =  panel:AddControl("Button", {
        Label = label,
        Command = command
	})
		
	if(unfair) then
		button:SetDisabled(SaitoHUD.AntiUnfairTriggered())
	end
	return button
end

--HELP PANEL
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

--SAMPLING PANEL
local function SamplingPanel(panel)
    panel:ClearControls()
    panel:AddHeader()
    
    if SaitoHUD.AntiUnfairTriggered() then
        panel:AddControl("Label", {Text = "WARNING: A non-sandbox game mode has been detected and the following options do not take effect."})
    end
    
    AddToggle(panel,"Draw Sampled Data","sample_draw",true)
    AddToggle(panel,"Draw Nodes","sample_nodes",false)
    AddToggle(panel,"Draw Thick Lines","sample_thick",false)
    AddToggle(panel,"Fade Samples","sample_fade",false)
    AddToggle(panel,"Use Random Colors","sample_random_color",false)
    AddToggle(panel,"Allow Multiple","sample_multiple",false)
    
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
    
    local entry = AddInput(panel,"Sample Player Name:","sample",true,true)
    local entry = AddInput(panel,"Remove Player by Name:","sample_remove",true,true)
    local entry = AddInput(panel,"Sample by Filter:","sample_filter",true, true)
    local entry = AddInput(panel,"Remove by Filter:","sample_remove_filter",true, true)
    
	AddButton(panel,"Remove All Samplers","sample_clear",true)
end


--OVERLAY PANEL
local function OverlayPanel(panel)
    panel:ClearControls()
    panel:AddHeader()
    
	AddLabel(panel,"Debug Info")
    AddToggle(panel,"Show Entity Information","entity_info",0)
    AddToggle(panel,"Show Player Info on Entity Information","entity_info_player",0)
    
    if SaitoHUD.AntiUnfairTriggered() then
        panel:AddControl("Label", {Text = "WARNING: A non-sandbox game mode has been detected and the following options do not take effect."})
    end
    
	AddLabel(panel,"Name Tags")
    AddToggle(panel,"Show Name Tags","name_tags",true)
    AddToggle(panel,"Show Distance","name_tags_distances",true)
    AddToggle(panel,"Simple Name Tags","name_tags_simple",true)
	
	AddLabel(panel,"Friend Tags")
    AddToggle(panel,"Always Show Friend Tags","friend_tags_always",true)
    AddToggle(panel,"Rainbow Friend Tags","name_tags_rainbow_friends",true)
    AddToggle(panel,"Bold Friend Tags","name_tags_bold_friends",true)
	
	AddLabel(panel,"Players")
    AddToggle(panel,"Show Player Bounding Boxes","player_boxes",true)
    AddToggle(panel,"Show Player Orientation Markers","player_markers",true)
    AddToggle(panel,"Show Player Line of Sights","trace_aims",true)
	
	AddLabel(panel,"Filters")
	local options = {}
	options["Class"] = {overlay_filter_text = "class"}
	options["Model"] = {overlay_filter_text = "model"}
	options["Material"] = {overlay_filter_text = "material"}
	panel:AddControl("ListBox",{Label="Overlay Filter Text",MenuButton = false,Height = 66,Options = options})
    
    entry = AddInput(panel,"Triads Filter:","triads_filter",false,true)
    entry = AddInput(panel,"Overlay Filter:","overlay_filter",false,true)
    entry = AddInput(panel,"Bounding Box Filter:","bbox_filter",false,true)
end

--SURVEY PANEL
local function SurveyPanel(panel)
    panel:ClearControls()
    panel:AddHeader()
    
	AddLabel(panel,"Ortho Trace")
    AddToggle(panel,"Show Trace Text","ortho_trace_text",true)
	
	AddLabel(panel,"Reflect Trace")
    AddToggle(panel,"Show Nodes","reflect_trace_nodes",true)
    AddToggle(panel,"Trace Multiple","reflect_trace_multiple",true)
    AddToggle(panel,"Color Progression","reflect_trace_color_progression",true)
end

--CONTROLS PANEL
local function CommandsPanel(panel)
    panel:ClearControls()
    panel:AddHeader()
    
    AddLabel(panel,"Sampling")
    AddButton(panel,"Sample","sample",false)
    AddButton(panel,"Clear","sample_clear",false)
    
    AddLabel(panel,"Filtering")
    local options = {}
	options["Expression2"] = {bbox_filter = "wire_expr"}
	options["Pods/Seats"] = {bbox_filter = "pod"}
	options["Vehicles"] = {bbox_filter = "vehicle"}
	panel:AddControl("ListBox",{Label="BBox Filter",MenuButton = false,Height = 66,Options = options})
    local options = {}
	options["Expression2"] = {overlay_filter = "wire_expr"}
	options["Pods/Seats"] = {overlay_filter = "pod"}
	options["Vehicles"] = {overlay_filter = "vehicle"}
	panel:AddControl("ListBox",{Label="Overlay Filter",MenuButton = false,Height = 66,Options = options})
    local options = {}
	options["Expression2"] = {triads_filter = "wire_expr"}
	options["Pods/Seats"] = {triads_filter = "pod"}
	options["Vehicles"] = {triads_filter = "vehicle"}
	panel:AddControl("ListBox",{Label="Triads Filter",MenuButton = false,Height = 66,Options = options})
    
    AddLabel(panel,"Ortho Trace")
    AddButton(panel,"Trace","ortho_trace",false)
    AddButton(panel,"Clear","ortho_trace_clear",false)
    
    AddLabel(panel,"Reflect Trace")
    local options = {}
	options["10"] = {reflect_trace = 5}
	options["25"] = {reflect_trace = 25}
	options["50"] = {reflect_trace = 50}
	options["100"] = {reflect_trace = 100}
	options["250"] = {reflect_trace = 250}
	options["500"] = {reflect_trace = 500}
	options["750"] = {reflect_trace = 750}
	options["1000"] = {reflect_trace = 1000}
	panel:AddControl("ListBox",{Label="Reflect Trace",MenuButton = false,Height = 66,Options = options})
    AddButton(panel,"Clear","reflect_trace_clear",false)
    
	AddLabel(panel,"Measuring")
    AddButton(panel,"Add Point","measure_add",false)
    AddButton(panel,"Undo Point","measure_remove_last",false)
    AddButton(panel,"Clear","measure_clear",false)
end

--- PopulateToolMenu hook.
local function PopulateToolMenu()
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDHelp", "Help", "", "", HelpPanel)
    --spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDGeneral", "General", "", "", GeneralPanel)
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDSampling", "Sampling", "", "", SamplingPanel, {SwitchConVar="sample_draw"})
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDOverlays", "Overlay", "", "", OverlayPanel)
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDSurvey", "Surveying", "", "", SurveyPanel)
    spawnmenu.AddToolMenuOption("Options", "SaitoHUD", "SaitoHUDCommands", "Quick Commands", "", "", CommandsPanel)
end

function SaitoHUD.UpdatePanels()
    HelpPanel(GetControlPanel("SaitoHUDHelp"))
    --GeneralPanel(GetControlPanel("SaitoHUDGeneral"))
    SamplingPanel(GetControlPanel("SaitoHUDSampling"))
    OverlayPanel(GetControlPanel("SaitoHUDOverlays"))
    SurveyPanel(GetControlPanel("SaitoHUDSurvey"))
    CommandsPanel(GetControlPanel("SaitoHUDCommands"))
end

hook.Add("PopulateToolMenu", "SaitoHUD.PopulateToolMenu", PopulateToolMenu)

--SaitoHUD.UpdatePanels()