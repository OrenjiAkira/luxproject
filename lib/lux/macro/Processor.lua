--[[
--
-- Copyright (c) 2013-2014 Wilson Kazuo Mizutani
--
-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
--
--    1. The origin of this software must not be misrepresented; you must not
--       claim that you wrote the original software. If you use this software
--       in a product, an acknowledgment in the product documentation would be
--       appreciated but is not required.
--
--    2. Altered source versions must be plainly marked as such, and must not be
--       misrepresented as being the original software.
--
--    3. This notice may not be removed or altered from any source
--       distribution.
--
--]]

--- This class process files using a macro configuration.
module ('lux.macro', package.seeall)

require 'lux.object'
require 'lux.functional'
require 'lux.macro.Configuration'

Processor = lux.object.new {}

Processor.__init = {
  config = Configuration:new{}
}

local function makeDirectiveEnvironment ()
  return setmetatable({}, { __index = getfenv(0) })
end

function Processor:handleDirective (env, str)
  local chunk = assert(loadstring(str))
  setfenv(chunk, env) ()
  return ''
end

function Processor:processString (str)
  local env = makeDirectiveEnvironment()
  return string.gsub(
    str,
    self.config.open_directive..'(.-)'..self.config.close_directive,
    lux.functional.bindleft(self.handleDirective, self, env)
  )
end

