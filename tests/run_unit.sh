#!/bin/sh
#
# Run the lunatest unit specs with plain Lua 5.1.
#
# usage: tests/run_unit.sh
#   override the interpreter with LUA=

set -e

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
LUA=${LUA:-$ROOT/../tools/lua51/bin/lua}

cd "$ROOT"
LUA_PATH="$ROOT/?.lua;$HERE/?.lua;$($LUA -e 'io.write(package.path)')"
LUA_CPATH="$($LUA -e 'io.write(package.cpath)')"
export LUA_PATH LUA_CPATH

# stand-ins for the Solar2D globals the library touches: dmc_corona_boot
# needs json and system.pathForFile; a component needs display.newGroup(),
# here a table that keeps its properties and delivers events to listeners
"$LUA" -e "
package.preload.json = package.preload.json or function() return require 'dkjson' end
system = { pathForFile=function( f ) return f end, ResourceDirectory='.' }
display = { newGroup=function()
	local g = { numChildren=0, anchorX=0.5, anchorY=0.5, _listeners={} }
	function g:removeSelf() end
	function g:addEventListener( name, f ) self._listeners[ name ] = f end
	function g:removeEventListener( name ) self._listeners[ name ] = nil end
	function g:dispatchEvent( e )
		local f = self._listeners[ e.name ]
		if f then f( e ) end
	end
	return g
end }
local lunatest = require 'lunatest'
lunatest.suite( 'dmc_objects_spec' )
lunatest.run()
"
