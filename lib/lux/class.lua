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

--- A class-based implementation object oriented programming.
--  Ironically, this is actually a prototype, which means it inherits from
--  @{lux.prototype}, but otherwise provides its own mechanism for OOP.
--  Be sure to check @{instance}, @{inherit} and @{super} usages.
--
--  ***This module requires macro takeover in order to work properly***
--
--  @usage
--  local MyClass = require 'lux.class' :new{}
--  @prototype lux.class
local class = require 'lux.prototype' :new {}

--- Defines how an instance of the class should be constructed.
--  This function is supposed to only be overriden, not called from the user's
--  side. By populating the `_ENV` parameter provided in this factory-like
--  strategy method is what creates class instances in this OOP feature.
--  This is actually done automatically: every "global" variable or function
--  you define inside this function is instead stored as a corresponding object
--  field.
--
--  @tparam object obj
--  The to-be-constructed object. On Lua5.2+, you may name it _ENV if you know
--  what you are doing.
--
--  @param ...
--  Arguments required by the construction of objects from the current class
--
--  @see some.lua
--
--  @usage
--  local MyClass = require 'lux.class' :new{}
--  local print = print -- must explicitly enclosure dependencies
--  function MyClass:instance (obj, x)
--    -- public field
--    obj.y = 1337
--    -- private field
--    local a_number = 42
--    -- public method
--    function obj.show ()
--      print(a_number + x)
--    end
--  end
--
--  myobj = MyClass(8001)
--  -- call without colons!
--  myobj.show()
function class:instance (_ENV, ...)
  -- Does nothing
end

--- Makes this class inherit from another.
--  This guarantess that instances from the former are also instances from the
--  latter. The semantics differs from that of inheritance through prototyping!
--  Also, it is necessary to call @{super} inside the current class'
--  @{instance} definition method since there is no way of guessing how the
--  parent class' constructor should be called.
--
--  @tparam class another_class
--  The class being inherited from
--
--  @see class:super
--
--  @usage
--  local class = require 'lux.class'
--  local ParentClass = class:new{}
--  local ChildClass = class:new{}
--  ChildClass:inherit(ParentClass)
function class:inherit (another_class)
  assert(not self.__parent, "Multiple inheritance not allowed!")
  assert(another_class:__super() == class, "Must inherit a class!")
  self.__parent = another_class
end

local makeInstance

function makeInstance (ofclass, obj, ...)
  ofclass:instance(obj, ...)
end

local operator_meta = {}

function operator_meta:__newindex (key, value)
  rawset(self, "__"..key, value)
end

--- The class constructor.
--  This is how someone actually instantiates objects from this class system.
--  After having created a new class and defined its @{instance} method, calling
--  the class itself behaves as expected by calling the constructor that will
--  use the @{instance} method to create the object.
--
--  @param ...
--  The constructor parameters as specified in the @{instance}
--
--  @treturn object
--  A new instance from the current class.
function class:__call (...)
  local obj = {
    __class = self,
    __extended = not self.__parent,
    __operator = setmetatable({}, operator_meta)
  }
  makeInstance(self, obj, ...)
  assert(obj.__extended, "Missing call to parent constructor!")
  return setmetatable(obj, obj.__operator)
end

class.__init = {
  __call = class.__call
}

--- Calls the parent class' constructor.
--  Should only be called inside this class' @{instance} definition method when
--  it inherits from another class.
--
--  @tparam object obj
--  The object being constructed by the child class, that is, the `_ENV`
--  parameter passed to @{instance}
--
--  @param ...
--  The parent class' constructor parameters
--
--  @see class:inherit
--
--  @usage
--  -- After ChildClass inherited ParentClass
--  function ChildClass:instance (obj, x, y)
--    self:super(obj, x + y) -- parent's constructor parameters
--    -- Finish instancing
--  end
function class:super (obj, ...)
  assert(not obj.__extended, "Already called parent constructor!")
  makeInstance(self.__parent, obj, ...)
  obj.__extended = true
end

return class
