# Changelog

## 2.2.0 (2026-10-01)

### Fixed

- `setAnchor()` works: `obj:setAnchor( obj.TopLeftReferencePoint )`, `obj:setAnchor( 0, 1 )` or `obj:setAnchor( 0.25 )` (it read the wrong arguments and did nothing).
- `dispatchRawEvent()` and `setEventFunc()` work on components: the raw event goes through the view, and `dispatchEvent()` builds its event with the function `setEventFunc()` sets (both used `ObjectBase`'s own listener list, which a component doesn't use).
- A component class no longer creates a display group for itself, so `obj.view` is `nil` after `obj:removeSelf()` (it found the class's group).
- `Objects.__version` is dmc-objects' version (it was lua-class's). The module is a copy of lua-objects' table with the component classes added, instead of adding them to lua-objects' own table.
- The module uses `Objects.newClass`, not the global, so it loads after `Objects.setNewClassGlobal( false )`.
- Rebuilt with dmc-corona-boot 1.6.0 and the current DMC-Lua-Library (lua-class 0.2.0, lua-objects 1.4.1); `setNewClassGlobal( false )` now removes the global `newClass`.

### Added

- `anchorX`, `anchorY` and `anchorChildren` are forwarded to the view.
- A component whose `__init__()` skips `self:superCall( '__init__', ... )` raises an error when created, as an `ObjectBase` does.
- Unit tests for the component classes, and `tests/run_unit.sh` to run the tests with plain Lua 5.1.

### Removed

- The Graphics 1.0 members of `ComponentBase`: `setReferencePoint()` (it made the Solar2D Simulator quit), `xReference`, `yReference`, `xOrigin`, `yOrigin` and `stageBounds`. Set `anchorX` and `anchorY` instead. The `*ReferencePoint` constants stay, as anchor points for `setAnchor()`.
- The copy of `Utils.extend()`, which set the global `_extend`; the module uses DMC-Lua-Library's `lua_utils`.
