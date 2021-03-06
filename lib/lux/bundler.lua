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

local port = require 'lux.portable'

local bundler = {}

local lpath = "rocktree/share/lua/5.3/?.lua;rocktree/share/lua/5.3/?/init.lua;"
local lcpath = "rocktree/lib/lua/5.3/?.so;"
local config_path = "rocktree/config.lua"
local bin_path = "rocktree/bin/"

local exec_code = [[
lua -e 'package.path="%s"' \
    -e 'package.cpath="%s"' \
    %%s
]]

exec_code = exec_code:format(lpath, lcpath)

local install_code = [[
export LUAROCKS_CONFIG=%s; luarocks --local --tree=rocktree install %%s
]]

install_code = install_code:format(config_path)

function bundler.run (name, ...)
  local ok, status, v = false, "File not found", -1
  local script = io.open(name, 'r') if script then
    script:close()
    ok, status, v = os.execute(exec_code:format(table.concat({name, ...}, ' ')))
  else
    local path = "./" .. bin_path .. name
    script = io.open(path, 'r') if script then
      script:close()
      ok, status, v = os.execute(table.concat({path, ...}, ' '))
    end
  end
  if ok == nil then
    return false, "Bundled script "..status.."ed with "..tostring(v)
  else
    return ok, status
  end
end

function bundler.install (spec_file)
  -- Check if this directory has a local rocktree
  local rocktree = io.open("rocktree", "r")
  if not rocktree then
    return false, "There is no local rocktree directory"
  end
  rocktree:close()
  local config_file = io.open(config_path, "r")
  if not config_file then
    print "[warning] No config file found, creating a new one."
    config_file = io.open(config_path, "w")
    config_file:write [[rocks_trees = { { name="user", root="./rocktree" } }]]
  end
  config_file:close()
  -- Load dependencies from rockspec
  local spec = {}
  assert(loadfile(spec_file, 't', spec)) ()
  for _,depstr in ipairs(spec.dependencies) do
    local rockname = depstr:match("^([^ ]+)")
    local code = install_code:format(rockname)
    io.write(code)
    local ok = os.execute(code)
    if not ok then
      return false, "Failed to install rock '"..rockname.."'"
    end
  end
  return true
end

return bundler
