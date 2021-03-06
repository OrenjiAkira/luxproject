--[[
--
-- Copyright (c) 2013-2017 Wilson Kazuo Mizutani
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE
--
--]]

--- This module allows for portable programming in Lua.
-- It currently support versions 5.1 through 5.3.
local portable = {}

local lua_major, lua_minor = (function (a,b)
  return tonumber(a), tonumber(b)
end) (_VERSION:match "(%d+)%.(%d+)")

assert(lua_major >= 5 and lua_minor >= 1) -- for sanity

local env_stack = {}
local push = table.insert
local pop = table.remove

function portable.isVersion(major, minor)
  return major == lua_major and minor == lua_minor
end

function portable.minVersion(major, minor)
  return major <= lua_major and minor <= lua_minor
end

if lua_minor <= 1 then

  table.unpack = unpack
  table.pack = function (...) return { n = select('#', ...), ... } end

  local old_load = load
  local mode_err = "attempt to load a %s chunk (mode is %s)"
  load = function (chunk, name, mode, env)
    mode = more or "bt"
    env = env or _G
    local func
    if type(chunk) == 'string' then
      local is_binary = (string.byte(chunk) == 27)
      if is_binary and not mode:match("^b") then
        return nil, mode_err:format("text", mode)
      elseif not is_binary and not mode:match("b?t") then
        return nil, mode_err:format("binary", mode)
      end
      func = loadstring(chunk, name)
    else
      func = old_load(chunk, name)
    end
    setfenv(func, env)
    return func
  end

  local old_loadfile = loadfile
  loadfile = function (filepath, mode, env)
    local file = io.open(filepath, "r")
    if file then
      local content = file:read '*a'
      return load(content, filepath, mode, env)
    end
  end
end

return portable
