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

--- LUX's object-oriented feature module.
--  This module provides some basic functionalities for object-oriented
--  programming in Lua. It is divided in two parts, which you can @{require}
--  separately.
--
--  <h2><code>lux.oo.prototype</code></h2>
--
--  This part provides a prototype-based implementation. It returns the root
--  prototype object, with which you can create new objects using
--  @{prototype:new}. Objects created this way automatically inherit fields and
--  methods from their parent, but may override them. It is not possible to
--  inherit from multiple objects. For usage instructions, refer to
--  @{prototype}.
--
--  <h2><code>lux.oo.class</code></h2>
--
--  This part provides a class-based implementation. It returns a special table
--  @{class} through which you can define classes. As of the current version of
--  LUX, there is no support for inheritance.
--
--  @module lux.oo

--- A special table for defining classes.
--  By defining a named method in it, a new class is created. It uses the given
--  method to create its instances. Once defined, the class can be retrieved by
--  using accessing the @{class} table with its name.
--
--  Since the fields are declared in a scope of
--  their own, local variables are kept their closures. Thus, it is
--  possible to have private members. Public member can be created by not using
--  the <code>local</code> keyword or explicitly referring to <code>self</code>
--  within the class definition.
--
--  Inheritance is possible through the <code>my_class:inherit()</code> method.
--  You use it inside the class definition passing self as the first parameter.
--
--  @feature class
--  @usage
--  local class = require 'lux.oo.class'
--  function class:MyClass()
--    local a_number = 42
--    function show ()
--      print(a_number)
--    end
--  end
--  local MyClass = class:forName 'MyClass'
--  function MyChildClass()
--    MyClass:inherit(self)
--    local a_string = "foo"
--    function show_twice ()
--      show()
--      show()
--    end
--  end
--
local class = {}

local lambda            = require 'lux.functional'
local packages          = {}
local obj_metatable     = {}
local no_op             = function () end

local function makeEmptyObject (the_class)
  return {
    __inherit = class,
    __class = the_class,
    __meta = {},
  }
end

local function construct (the_class, obj, ...)
  assert(the_class.definition) (obj, ...)
  return obj
end

local function createAndConstruct (the_class, ...)
  local obj = makeEmptyObject(the_class)
  construct(the_class, obj, ...)
  return setmetatable(obj, obj.__meta);
end

local redef_err = "Redefinition of class '%s' in package '%s'"

local function define (pack, name, definition)
  assert(not rawget(pack, name), redef_err:format(name, current_package))
  local new_class = {
    name = name,
    definition = definition,
    inherit = construct
  }
  setmetatable(new_class, { __call = createAndConstruct })
  rawset(pack, name, new_class)
end

local function import (pack, name)
  local result = rawget(pack, name)
  return result or require(pack.__name.."."..name)
end

local package_mttab = {
  __index = import,
  __newindex = define
}

function class:package (name)
  local pack = packages[name]
  if not pack then
    pack = setmetatable({ __name = name }, package_mttab)
    packages[name] = pack
  end
  return pack
end

class:package 'std'

return class

