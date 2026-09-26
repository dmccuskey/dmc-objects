# Writing Classes

How to write a class with dmc-objects: which base class to start from, how to lay out the file, what goes in each construction and teardown hook, and how classes send events. The [Quick Start](../README.md#quick-start) is the short version; the [API reference](api.md) lists every method and property.

The [examples](../examples/) are complete apps written this way. `DMC-ufo` and `DMC-Arch-ufo2` follow this page most closely.

## Choosing a Base Class

| base class | use it for |
|---|---|
| `ComponentBase` | anything with a visual representation: a sprite, a button, a whole screen. It is backed by a display group. |
| `PhysicsComponentBase` | the same, placed in the physics engine: adds the body properties and methods |
| `ObjectBase` | objects without a view: models, controllers, network clients. Plain Lua, no Solar2D needed. |

Most classes inherit from `ComponentBase`. Think of an instance as a display group with your own properties and methods: it has `x`, `y`, `alpha`, `numChildren`, `insert()`, `toFront()` and the rest, and you can pass it to `transition.to()`. The group itself is `obj.view`; use it where Solar2D needs a real display object, e.g. `physics.addBody( obj.view, ... )` or `someGroup:insert( obj.view )`. The [API reference](api.md#componentbase) lists what an instance forwards to its view.

`ObjectBase` and `newClass()` come from [lua-objects](https://github.com/dmccuskey/lua-objects), which works in plain Lua. dmc-objects adds the two component classes on top.

## Layout of a Class File

Each class goes in its own file (or a few related classes share one, as in `DMC-MultiShapes`), laid out in the same order every time, so you and anyone else reading it know where to look:

```lua
--====================================================================--
--== Imports

local Objects = require 'dmc_corona.dmc_objects'


--====================================================================--
--== Setup, Constants

-- module-level values and helper functions
local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local rand = math.random


--====================================================================--
--== UFO Class

local UFO = newClass( ComponentBase, { name="Unidentified Flying Object" } )

--== Class Constants

UFO.IMG_W = 110
UFO.IMG_H = 65

UFO.EVENT = 'ufo_event'
UFO.TOUCHED = 'ufo_touched_event'


--======================================================--
-- Start: Setup DMC Objects

function UFO:__init__( params ) ... end
function UFO:__undoInit__() ... end

function UFO:__createView__() ... end
function UFO:__undoCreateView__() ... end

function UFO:__initComplete__() ... end
function UFO:__undoInitComplete__() ... end

-- END: Setup DMC Objects
--======================================================--


--====================================================================--
--== Public Methods

function UFO:move( speed ) ... end


--====================================================================--
--== Private Methods

function UFO:_updateView( speed ) ... end


--====================================================================--
--== Event Handlers

function UFO:touch( event ) ... end


return UFO
```

- **Setup, Constants**: things the module needs that aren't part of the class: local copies of globals, helper functions.
- **Class constants**: values shared by every instance, on the class table: image sizes, speeds, asset paths, event names. Put them after `newClass()`, which creates the table they go on.
- **Hooks**: see the next section. You only write the hooks you need.
- **Methods**: public ones first, then private ones (named with a leading `_`), then event handlers.

The `name` given to `newClass()` is what `obj.NAME` returns and what `print( obj )` shows.

## Construction and Teardown

You don't write a constructor. `MyClass:new( params )` creates the instance and calls three hooks, each adding one layer; `obj:removeSelf()` (or `obj:destroy()`) calls three more that take the layers off in reverse order:

| hooks | order on `new()` | order on `removeSelf()` | what goes in them |
|---|---|---|---|
| `__init__( params )`, `__undoInit__()` | 1st | 3rd | properties: save the params, list every property the class uses |
| `__createView__()`, `__undoCreateView__()` | 2nd | 2nd | display objects: images, shapes, text, child groups |
| `__initComplete__()`, `__undoInitComplete__()` | 3rd | 1st | anything else: event listeners, timers, initial position and state |

Each pair mirrors the other: whatever a creation hook adds, its undo hook removes. Reading a class, you can check the two side by side and see that nothing is left behind.

```lua
function UFO:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--
	self._speed = params.speed or UFO.SLOW
	self._transition = nil  -- running transition, set in move()
	self._bg = nil          -- background, for taps
	self._views = {}        -- one image per speed
end

function UFO:__undoInit__()
	self._views = nil
	self._bg = nil
	self._transition = nil
	--==--
	self:superCall( '__undoInit__' )
end

function UFO:__createView__()
	self:superCall( '__createView__' )
	--==--
	local o = display.newRect( 0, 0, UFO.IMG_W, UFO.IMG_H )
	o.alpha = 0.05  -- just enough to receive taps
	self:insert( o )
	self._bg = o
	-- ... the images
end

function UFO:__undoCreateView__()
	self._bg:removeSelf()
	self._bg = nil
	-- ... the images
	--==--
	self:superCall( '__undoCreateView__' )
end

function UFO:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	self._bg:addEventListener( 'touch', self )
end

function UFO:__undoInitComplete__()
	self._bg:removeEventListener( 'touch', self )
	if self._transition then transition.cancel( self._transition ) end
	--==--
	self:superCall( '__undoInitComplete__' )
end
```

The rules:

- **Call `superCall()` in every hook you write**: first in a creation hook, last in an undo hook. The parent classes set up their layers first and take them down last; `ComponentBase` creates the display group in its `__init__()` and removes it in its `__undoInit__()`.
- **Only `__init__()` receives the parameters.** Anything the other hooks need from them, save as a property in `__init__()`.
- **Start `__init__()` with `params = params or {}`.** When you subclass a class, its `__init__()` also runs once, without parameters, on the new subclass itself. A class that reads `params.label` without this check can't be subclassed: `newClass( Badge )` fails with `attempt to index local 'params' (a nil value)`.
- **List every property in `__init__()`**, even the ones that start as `nil`. It documents the class in one place, and the undo hooks can be checked against the list.

Setting the properties in `__init__()` also puts them directly on the instance, so reading them doesn't search the class hierarchy.

## Methods From Parent Classes

A class inherits every method of its parents. To call a parent's version of a method you have overridden, use `superCall()` with the method name and its arguments:

```lua
function FastUFO:move( speed )
	self:superCall( 'move', UFO.FAST )
end
```

`superCall()` finds the class that defines the method and continues the search in that class's parents, so it works at every level of a deep hierarchy. If no parent has the method, it returns `nil` instead of failing.

A class can have several parents: `newClass( { ComponentBase, SomeMixin }, { name="..." } )`. Lookups search the parents in the order listed; `self:superCall( SomeMixin, '__init__', params )` calls one parent's method. lua-objects' own `ObjectBase` is built this way, from its base class and the events mixin. See lua-class's [Multiple Inheritance](https://github.com/dmccuskey/lua-class/blob/master/docs/api.md#multiple-inheritance) for the details.

## Getters and Setters

A property can run code when it's read or written. Define functions in the class's `__getters` and `__setters` tables, under the property name:

```lua
function UFO.__getters:speed()
	return self._speed
end

function UFO.__setters:speed( value )
	assert( UFO.SPEEDS[ value ], "unknown speed" )
	self._speed = value
	self:_updateView( value )
end
```

```lua
ufo.speed = UFO.FAST   -- calls the setter
print( ufo.speed )     -- calls the getter
```

A property with a getter and no setter can still be assigned: the value is stored on the instance, and the getter keeps answering reads. Keep the value itself under another name (`_speed`), or the getter would call itself.

This is how a `ComponentBase` instance works with transitions: `x`, `y`, `alpha` and the others are getters and setters that read and write the display group.

## Events

A class can send events to listeners. `addEventListener()`, `removeEventListener()` and `dispatchEvent()` on a `ComponentBase` instance go to its display group, so Solar2D events (`tap`, `touch`, ...) and your own both work:

```lua
-- in the class
UFO.EVENT = 'ufo_event'
UFO.TOUCHED = 'ufo_touched_event'

function UFO:touch( event )
	if event.phase == 'ended' then
		self:dispatchEvent( UFO.TOUCHED, { speed=self._speed } )
	end
	return true
end
```

```lua
-- in main.lua
local function ufoHandler( event )
	if event.type == ufo.TOUCHED then
		print( 'touched', event.target, event.data.speed )
	end
end

ufo:addEventListener( ufo.EVENT, ufoHandler )
```

`dispatchEvent( type, data )` sends an event named after the class's `EVENT` constant, with `type`, `data` and `target` (the instance) set. A class that doesn't set `EVENT` sends `event_mix_event`. So a listener registers once for the class's events and branches on `event.type`. `dispatchEvent{ name='...', ... }`, with a table, sends that event unchanged, as Solar2D does.

When a Solar2D event comes from a display object inside your class, `event.target` is that display object. `getDMCObject( displayObject )` returns the dmc-objects instance whose view it is, or the object itself if it's not one.

Remove your listeners in `__undoInitComplete__()`: a listener on `Runtime` or on another object keeps the instance alive after `removeSelf()`.

## Making Lookups Faster

Lua finds an inherited method by searching the object, then its class, then each parent in turn. In a deep hierarchy called every frame, that adds up. Properties set in `__init__()` are already on the instance. For methods, call:

```lua
obj:optimize()     -- copy every inherited method onto obj
obj:deoptimize()   -- remove every function stored on obj
```

Profile first, and optimize only objects that need it: an optimized object doesn't see methods added to its classes later, and `deoptimize()` also removes functions you stored on the instance yourself.
