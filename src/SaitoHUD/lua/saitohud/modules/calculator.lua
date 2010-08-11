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
function SaitoHUD.CalcExpr(str)
    local ret, err = pcall(CompileString, "_result = " .. str, "calc")
    if not ret or type(err) ~= 'function' then
        return false, "Parsing error"
    end
    
    local f = err
    
    setfenv(f, {
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
    })
    
    for i = 1, 3 do -- Workaround for coroutine issues
        local co = coroutine.create(f)
        debug.sethook(co, MakeHook(f, 100, 5, 0.01), "crl")
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

local function ChatProcessor(ply, text, teamChat, isDead)
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
end

hook.Add("OnPlayerChat", "SaitoHUD.Calculator", ChatProcessor)