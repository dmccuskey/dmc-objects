# API Reference

Everything dmc-objects provides, as of version 2.1.2. [Writing Classes](writing-classes.md) explains how the pieces are used together.

| name | what it is |
|---|---|
| [`newClass()`](#newclass) | creates a class |
| [Class members](#class-members) | what every class and instance has: `new()`, `removeSelf()`, `superCall()`, `isa()`, ... |
| [`ObjectBase`](#objectbase) | base class without a view, with events |
| [`ComponentBase`](#componentbase) | base class backed by a display group |
| [`PhysicsComponentBase`](#physicscomponentbase) | `ComponentBase` plus the physics body API |
| [`getDMCObject()`](#getdmcobject) | from a display object to the instance it belongs to |
| [Configuration](#configuration) | the `[DMC_OBJECTS]` section of `dmc_corona.cfg` |
| [Known issues](#known-issues) | what doesn't work under Solar2D |

## The Module

```lua
local Objects = require 'dmc_corona.dmc_objects'
```

| field | |
|---|---|
| `Objects.newClass` | [`newClass()`](#newclass) |
| `Objects.Class` | the root class every class inherits from |
| `Objects.ObjectBase`, `Objects.ComponentBase`, `Objects.PhysicsComponentBase` | the base classes below |
| `Objects.registerCtorName( name, class )`, `Objects.registerDtorName( name, class )` | add another name for the constructor (`new`) or destructor (`destroy`) on `class` (default: the root class) |
| `Objects.inheritsFrom( class )` | the 1.x way to create a class; same as `newClass( class )` |
| `Objects.setNewClassGlobal()` | see [newClass](#newclass) |

Loading the module also defines two globals: `newClass` and [`getDMCObject`](#getdmcobject).

`newClass()` and the class model come from [lua-class](https://github.com/dmccuskey/lua-class) and `ObjectBase` from [lua-objects](https://github.com/dmccuskey/lua-objects) (`lib/dmc_lua/lua_class.lua` and `lua_objects.lua` in `dmc_corona/`); dmc-objects adds the two component classes.

## newClass

```lua
local MyClass = newClass( parents, { name="My Class" } )
```

- `parents`: one class, a list of classes (`{ ComponentBase, SomeMixin }`, searched in that order), or `nil` for a class whose only parent is the root class.
- `name`: what `obj.NAME` returns and `print( obj )` shows. Default `<unnamed class>`.

Creating a class runs the parents' `__init__()` on the new class, without parameters (see [Construction and Teardown](writing-classes.md#construction-and-teardown)).

`newClass` is also set as a global when the module first loads. If a global `newClass` already exists, it prints `WARNING: newClass exists in global namespace` and leaves it; use `Objects.newClass` in that case.

## Class Members

Every class and instance has these.

| member | |
|---|---|
| `MyClass:new( ... )` | creates an instance; the arguments go to `__init__()`. `MyClass( ... )` does the same. |
| `obj:removeSelf()`, `obj:destroy()` | runs the teardown hooks |
| `obj:superCall( 'method', ... )` | calls the parent classes' version of `method` ([Methods From Parent Classes](writing-classes.md#methods-from-parent-classes)) |
| `obj:superCall( Parent, 'method', ... )` | the same, searching only `Parent` |
| `obj:isa( SomeClass )` | `true` if `obj` is `SomeClass` or inherits from it |
| `obj:optimize()`, `obj:deoptimize()` | copy inherited methods onto `obj`, or remove every function stored on it ([Making Lookups Faster](writing-classes.md#making-lookups-faster)) |
| `obj.NAME` | the class name given to `newClass()` |
| `obj.class` | the class of an instance (a class returns itself) |
| `obj.supers` | the list of parent classes |
| `obj.is_class`, `obj.is_instance` | which of the two `obj` is |
| `MyClass.__getters`, `MyClass.__setters` | where to define [getters and setters](writing-classes.md#getters-and-setters) |

`print( obj )` shows the name and the table address: `Badge (table: 0x600001a2c040)`.

## ObjectBase

A base class without a view, for objects in plain Lua. It has the hooks `__init__()`, `__initComplete__()` and their undo hooks (not `__createView__()`), and events:

| method | |
|---|---|
| `obj:addEventListener( name, listener )` | `listener` is a function, or a table with a method named `name` |
| `obj:removeEventListener( name, listener )` | |
| `obj:dispatchEvent( type, data, params )` | sends `{ name=obj.EVENT, type=type, data=data, target=obj }`. With `params.merge = true` and a table `data`, the fields of `data` go into the event itself instead. |
| `obj:dispatchRawEvent( event )` | sends `event` unchanged; it needs a `name` |
| `obj:createCallback( method )` | returns a function that calls `method( obj, ... )`, for timers and transitions: `timer.performWithDelay( 100, self:createCallback( self._tick ) )` |
| `obj:setEventFunc( func )` | replaces the function that builds events for `dispatchEvent()` |
| `MyClass.EVENT` | the event name used by `dispatchEvent()`; default `event_mix_event` |

## ComponentBase

`ComponentBase` inherits from `ObjectBase`. Each instance has a display group, `obj.view`, created in `__init__()` and removed with everything in it by `__undoInit__()`. Use `obj.view` where Solar2D needs a real display object. (`obj.display` is an older name for it.)

It adds the hooks `__createView__()` and `__undoCreateView__()`, and forwards these to the view, so an instance can be used like a display group:

| | forwarded to `obj.view` |
|---|---|
| properties | `alpha`, `height`, `isHitTestMasked`, `isHitTestable`, `isVisible`, `maskRotation`, `maskScaleX`, `maskScaleY`, `maskX`, `maskY`, `rotation`, `width`, `x`, `xScale`, `y`, `yScale` |
| read-only | `contentBounds`, `contentHeight`, `contentWidth`, `numChildren`, `parent` |
| methods | `insert()`, `remove()`, `addEventListener()`, `removeEventListener()`, `dispatchEvent()`, `contentToLocal()`, `localToContent()`, `rotate()`, `scale()`, `translate()`, `toBack()`, `toFront()`, `setMask()` (untested) |

Anything else, such as `anchorX`, `anchorY` or `anchorChildren`, isn't forwarded: set it on `obj.view`. Setting `obj.anchorX` stores a value on the instance and changes nothing on screen.

The events methods go to the view, not to `ObjectBase`'s listener list, so Solar2D events (`tap`, `touch`) and your own events share one set of listeners. `dispatchEvent()` takes a Solar2D event table (`{ name='...' }`) or the `( type, data, params )` form above. `dispatchRawEvent()` and `setEventFunc()` still work on `ObjectBase`'s list, so on a component their events never reach a listener (see [Known Issues](#known-issues)).

It also adds:

| method | |
|---|---|
| `obj:show()`, `obj:hide()` | set `isVisible` |
| `obj:setTouchBlock( displayObject )` | makes `displayObject` swallow touches, so they don't reach objects behind it |
| `obj:unsetTouchBlock( displayObject )` | undoes it |

## PhysicsComponentBase

`PhysicsComponentBase` inherits from `ComponentBase` and also forwards the physics body API to the view. Add the body to the view:

```lua
physics.addBody( crate.view, 'dynamic', { density=1, friction=0.3 } )
crate:setLinearVelocity( 0, -200 )
```

| | forwarded to `obj.view` |
|---|---|
| properties | `angularDamping`, `angularVelocity`, `bodyType`, `isAwake`, `isBodyActive`, `isBullet`, `isFixedRotation`, `isSensor`, `isSleepingAllowed`, `linearDamping` |
| methods | `applyAngularImpulse()`, `applyForce()`, `applyLinearImpulse()`, `applyTorque()`, `getLinearVelocity()`, `resetMassData()`, `setLinearVelocity()` |

## getDMCObject

```lua
local obj = getDMCObject( displayObject )
```

Returns the dmc-objects instance whose view is `displayObject`, or `displayObject` itself if it isn't a view. It's a global.

## Configuration

dmc-objects has no settings. Its `dmc_corona.cfg` section, `[DMC_OBJECTS]`, can be left out or left empty. The file's format, and the `[DMC_CORONA]` section every DMC library uses, are described in [dmc-corona-boot's Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md).

## Known Issues

- **Graphics 1.0 leftovers.** `ComponentBase` still has `setReferencePoint()`, the `*ReferencePoint` constants, `xReference`, `yReference`, `xOrigin`, `yOrigin` and `stageBounds`, from Corona's old graphics engine. Don't use them: `setReferencePoint()` makes the Solar2D Simulator quit, and `xReference` and `yReference` return `nil`. Set `anchorX` and `anchorY` on `obj.view` instead.
- **`dispatchRawEvent()` and `setEventFunc()` don't work on components.** Use `dispatchEvent()` with an event table (`obj:dispatchEvent{ name='my_event', ... }`) to send an event of your own making.
- **`setAnchor()` does nothing** when called as `obj:setAnchor( obj.TopLeftReferencePoint )` or `obj:setAnchor( 0, 1 )`: it reads the wrong arguments. Set `obj.view.anchorX` and `anchorY`.
- **Each `ComponentBase` class has its own empty display group**, created when the class is. After `obj:removeSelf()`, `obj.view` finds the class's group instead of returning `nil`.
- `Objects.__version` is lua-class's version, not dmc-objects'. dmc-objects doesn't export its own.
- `Objects.setNewClassGlobal( false )` doesn't remove the global `newClass`.
