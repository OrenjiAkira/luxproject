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

local class     = require 'lux.Feature' :new {}
local BaseClass = require 'lux.Object' :new {
  name = "BaseClass",
  constructor = function (...) end
}

function BaseClass:__call (...)
  local new_instance = self:new{}
  self.constructor (new_instance, ...)
  return new_instance
end

setmetatable(class.helper, { __index = _G })

function class:onDefinition (name, definition)
  local NewClass = BaseClass:new {
    name = name,
    --constructor = definition.methods
  }
  --NewClass.__init = definition.members
  self.context[name] = NewClass
end

function class:onRequest (name)
  return self.context[name]
end

return class

