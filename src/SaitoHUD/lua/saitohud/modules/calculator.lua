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

--- Calculator functions.

local clCmd = CreateClientConVar("calc_cl_cmd", "", true, false)
local othersCmd = CreateClientConVar("calc_others_cmd", "", true, false)

------------------------------------------------------------
-- SaitoHUDCalculator
------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
    self.LastAnswer = 0
    self.LastExpr = nil
    
    self:SetTitle("SaitoHUD Calculator")
    self:SetSizable(true)
    self:SetSize(300, 400)
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    
    -- Make list view
    self.Log = vgui.Create("DPanelList", self)
    self.Log:SetPadding(3)
    self.Log:SetSpacing(3)
    self.Log:SetBottomUp(true)
    self.Log:EnableVerticalScrollbar(true)
    self.Log.Paint = function(self)
        draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(),
                        Color(255, 255, 255, 255))
    end
    
    local operators = {"*", "+", "+", "/", "%"}
    
    self.InputEntry = vgui.Create("DTextEntry", self)
    self.InputEntry:SetText("")
    self.InputEntry:SizeToContents()
    self.InputEntry:RequestFocus()
    self.InputEntry.OnTextChanged = function(panel, text)
        local val = panel:GetValue()
        if string.len(val) == 1 and table.HasValue(operators, val) then
            panel:SetText("ans" .. val)
            panel:SetCaretPos(4)
        end
    end
    self.InputEntry.OnEnter = function()
        self:Evaluate()
    end
    
    self.CalcBtn = vgui.Create("DButton", self)
    self.CalcBtn:SetText(">")
    self.CalcBtn:SetWide(20)
    self.CalcBtn.DoClick = function()
        self:Evaluate()
    end
    
    self.Log:AddItem(vgui.Create("SaitoHUDCalculatorInfo", self))
end

function PANEL:Evaluate()
    local text = self.InputEntry:GetValue():Trim()
    if text == "clear" then
        self.Log:Clear()
        self.InputEntry:SetText("")
        self.InputEntry:RequestFocus()
        
        self.Log:AddItem(vgui.Create("SaitoHUDCalculatorInfo", self))
    elseif text == "copy" then
        SetClipboardText(tostring(self.LastAnswer))
        self.InputEntry:SetText("")
        self:Close()
    elseif text == "qc" then
        SetClipboardText(tostring(self.LastAnswer))
        self.InputEntry:SetText("")
        self:Close()
    elseif text == "q" then
        self.InputEntry:SetText("")
        self:Close()
    elseif text ~= "" then
        self.InputEntry:SetText("")
        local ret, val = SaitoHUD.CalcExpr(text, {
            ans = self.LastAnswer,
        })
        self:AddEvaluation(text, tostring(val))
        if ret then
            self.LastExpr = text
            self.LastAnswer = val
        end
        self.InputEntry:RequestFocus()
    elseif text == "" and self.LastExpr then
        local ret, val = SaitoHUD.CalcExpr(self.LastExpr, {
            ans = self.LastAnswer,
        })
        self:AddEvaluation(self.LastExpr, tostring(val))
        if ret then
            self.LastAnswer = val
        end
        self.InputEntry:RequestFocus()
    end
end

function PANEL:AddEvaluation(input, output)
    local line = vgui.Create("SaitoHUDCalculatorLine", self)
    line:Setup(input, output)
    self.Log:AddItem(line)
end

function PANEL:PerformLayout()
    DFrame.PerformLayout(self)
    
    local wide = self:GetWide()
    local tall = self:GetTall()
    
    self.Log:StretchToParent(10, 28, 10, 43)
    
    self.InputEntry:SetPos(10, tall - self.CalcBtn:GetTall() - 10)
    self.InputEntry:SetWide(wide - self.CalcBtn:GetWide() - 25)
    
    self.CalcBtn:SetPos(wide - self.CalcBtn:GetWide() - 10,
                        tall - self.CalcBtn:GetTall() - 10)
end

vgui.Register("SaitoHUDCalculator", PANEL, "DFrame")

------------------------------------------------------------
-- SaitoHUDCalculatorTextEntry
------------------------------------------------------------

local PANEL = {}

function PANEL:Paint(panel)
    self:DrawTextEntryText(self.m_colText, self.m_colHighlight, self.m_colCursor)
end

function PANEL:ApplySchemeSettings()
    self:SetTextColor(Color(0, 0, 0, 255))
    self:SetHighlightColor(Color(100, 100, 100, 255))
    self:SetCursorColor(Color(0, 0, 0, 255))
end

vgui.Register("SaitoHUDCalculatorTextEntry", PANEL, "DTextEntry")

------------------------------------------------------------
-- SaitoHUDCalculatorLine
------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
    self.CreateTime = CurTime()
end

function PANEL:Setup(input, output)    
    self.Input = vgui.Create("SaitoHUDCalculatorTextEntry", self)
    self.Input:SetPos(3, 2)
    self.Input:SetText(input)
    self.Input:SizeToContents()
    
    self.Output = vgui.Create("SaitoHUDCalculatorTextEntry", self)
    self.Output:SetText(output)
    self.Output:SizeToContents()
    
    self:SetTall(self.Input:GetTall() + self.Output:GetTall() + 5)
    
    self.RemoveBtn = vgui.Create("DButton", self)
    self.RemoveBtn:SetSize(6, self:GetTall())
    self.RemoveBtn:SetText("")
    self.RemoveBtn:SetTooltip("Remove this line.")
    self.RemoveBtn.DoClick = function()
        self:Remove()
        self:GetParent().InvalidateLayout()
    end
end

function PANEL:Paint()
    local elapsed = CurTime() - self.CreateTime
    local c = math.max(200, (0.7 - elapsed / 0.7) * 55 + 200)
    
    draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(),
                    Color(200, 200, c, 255))
    draw.RoundedBox(0, 1, self:GetTall() / 2,
                    self:GetWide() - 2, self:GetTall() / 2 - 2,
                    Color(255, 255, 255, 255))
end

function PANEL:PerformLayout()
    local wide = self:GetWide()
    
    self.RemoveBtn:SetPos(wide - self.RemoveBtn:GetWide(), 0)
    self.Output:SetPos(3, self.Input:GetTall() + 3)
    self.Input:SetWide(wide - 8)
    self.Output:SetWide(wide - 8)
end

vgui.Register("SaitoHUDCalculatorLine", PANEL, "DPanel")

------------------------------------------------------------
-- SaitoHUDCalculatorInfo
------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
    local lines = {
        "clear - Clear the log",
        "q - Close",
        "qc - Close and copy to clipboard",
        "copy - Copy to clipboard",
    }
    
    self.Labels = {}
    
    local height = 3
    
    for i, text in pairs(lines) do
        local label = vgui.Create("SaitoHUDCalculatorTextEntry", self)
        label:SetPos(3, height)
        label:SetText(text)
        label:SetWide(200)
        table.insert(self.Labels, label)
        height = height + label:GetTall() - 5
    end
    
    self:SetTall(height + 3 + 8)
end

function PANEL:Paint()
    draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(),
                    Color(200, 200, 255, 255))
end

function PANEL:PerformLayout()
    local wide = self:GetWide()
    
    for _, lbl in pairs(self.Labels) do
        lbl:SetWide(wide - 6)
    end
end

vgui.Register("SaitoHUDCalculatorInfo", PANEL, "DPanel")

------------------------------------------------------------

local function SetError(f, err)
    setfenv(f, { _err = err })
    error("Exception occurred")
    -- Cannot use Error()!
end

local function MakeHook(f, maxLines, recursionLimit, maxTime)
    local lines = 0
    local calls = 0
    local start = 0

    return function(evt)
        if start == 0 then start = os.clock() end
        if os.clock() - start > maxTime then SetError(f, "Time limit hit") end
        if evt == "line" then
            lines = lines + 1
            if lines > maxLines then SetError(f, "Line limit hit") end
        elseif evt == "call" then
            calls = calls + 1
            if calls > recursionLimit then SetError(f, "Recursion limit hit") end
        elseif evt == "return" then
            calls = calls - 1
        end
    end
end

--- Calculates a mathematical expression securely.
-- @param str Expression
-- @return Success or not
-- @return Error message or result
function SaitoHUD.CalcExpr(str, vars)
    local ret, err = pcall(CompileString, "_result = " .. str, "calc")
    if not ret or type(err) ~= 'function' then
        return false, "Parsing error"
    end
    
    local f = err
    
    local env = {
        abs = math.abs,
        acos = math.acos,
        asin = math.asin,
        atan = math.atan,
        ceil = math.ceil,
        cos = math.cos,
        cosh = math.cosh,
        deg = math.deg,
        exp = math.exp,
        floor = math.floor,
        fmod = math.fmod,
        ln = math.log,
        log = math.log,
        log10 = math.log10,
        max = math.max,
        min = math.min,
        pow = math.pow,
        rad = math.rad,
        rand = math.random,
        sin = math.sin,
        sinh = math.sinh,
        sqrt = math.sqrt,
        tanh = math.tanh,
        tan = math.tan,
        
        pi = math.pi,
        inf = math.huge,
        e = 2.718281828459,
        gr = 1.618033988749,
    }
    
    if vars then
        for k, v in pairs(vars) do
            env[k] = v
        end
    end
    
    setfenv(f, env)
    
    for i = 1, 3 do -- Workaround for coroutine issues
        local co = coroutine.create(f)
        debug.sethook(co, MakeHook(f, 100, 5, 0.1), "crl")
        local ret, done, err = pcall(coroutine.resume, co) -- Gmod has issues
        
        if ret then
            if done then
                return true, tonumber(getfenv(f)._result) or 0
            else
                return false, getfenv(f)._err
            end
        end
    end
    
    -- Failure
    return false, "Internal error 1"
end

------------------------------------------------------------

concommand.Add("calculator", function()
    if g_SaitoHUDCalculator and g_SaitoHUDCalculator:IsValid() then
        local frame = g_SaitoHUDCalculator
        -- Reload protection
        if frame.SaitoHUDRef ~= SaitoHUD then
            frame:Remove()
        else
            frame:SetVisible(true)
            frame.InputEntry:RequestFocus()
            return
        end
    end
    
    local frame = vgui.Create("SaitoHUDCalculator")
    frame:GetDeleteOnClose(false)
    frame:Center()
    frame:MakePopup()
    frame.SaitoHUDRef = SaitoHUD
    frame.Close = function()
        frame:SetVisible(false)
    end
    g_SaitoHUDCalculator = frame
    
end)

hook.Add("OnPlayerChat", "SaitoHUD.Calculator", function(ply, text, teamChat, isDead)
    local clCmd = clCmd:GetString()
    local othersCmd = othersCmd:GetString()
    
    if clCmd ~= "" and ply == LocalPlayer() then
        if text:sub(1, string.len(clCmd)) == clCmd then
            local expr = text:sub(string.len(clCmd) + 1)
            local ret, val = SaitoHUD.CalcExpr(expr)
            timer.Simple(0.01, function()
                if ret then
                    chat.AddText(Color(255, 255, 255), "= ", tostring(val))
                else
                    chat.AddText(Color(255, 255, 0), "Error: " .. val)
                end
            end)
            
            return false
        end
    elseif othersCmd ~= "" and ply ~= LocalPlayer() then
        if text:sub(1, string.len(othersCmd)) == othersCmd then
            if not ply.SHLastCalc then ply.SHLastCalc = 0 end
            
            -- Anti-spam
            if RealTime() - ply.SHLastCalc < 1 then
                return
            end
            
            ply.SHLastCalc = RealTime()
            
            local expr = text:sub(string.len(othersCmd) + 1)
            local ret, val = SaitoHUD.CalcExpr(expr)
        
            if ret then
                RunConsoleCommand("say", "= " .. val)
            else
                RunConsoleCommand("say", "Error: " .. val)
            end
        end
    end
end)