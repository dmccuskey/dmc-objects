--====================================================================--
-- dmc_objects.lua
--
-- by David McCuskey
-- Documentation: http://docs.davidmccuskey.com/display/docs/dmc_objects.lua
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2011-2015 David McCuskey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]



--====================================================================--
--== DMC Corona Library : DMC Objects
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "2.0.1"



--====================================================================--
--== DMC Corona Library Config
--====================================================================--


--====================================================================--
--== Support Functions


local Utils = {} -- make copying from Utils easier


--== Start: copy from lua_utils ==--

-- extend()
-- Copy key/values from one table to another
-- Will deep copy any value from first table which is itself a table.
--
-- @param fromTable the table (object) from which to take key/value pairs
-- @param toTable the table (object) in which to copy key/value pairs
-- @return table the table (object) that received the copied items
--
function Utils.extend( fromTable, toTable )

	if not fromTable or not toTable then
		error( "table can't be nil" )
	end
	function _extend( fT, tT )

		for k,v in pairs( fT ) do

			if type( fT[ k ] ) == "table" and
				type( tT[ k ] ) == "table" then

				tT[ k ] = _extend( fT[ k ], tT[ k ] )

			elseif type( fT[ k ] ) == "table" then
				tT[ k ] = _extend( fT[ k ], {} )

			else
				tT[ k ] = v
			end
		end

		return tT
	end

	return _extend( fromTable, toTable )
end

--== End: copy from lua_utils ==--



--====================================================================--
--== Configuration

local dmc_lib_data, dmc_lib_info

-- boot dmc_library with boot script or
-- setup basic defaults if it doesn't exist
--
if false == pcall( function() require( 'dmc_corona_boot' ) end ) then
	_G.__dmc_corona = {
		dmc_corona={},
	}
end

dmc_lib_data = _G.__dmc_corona
dmc_lib_info = dmc_lib_data.dmc_library



--====================================================================--
--== DMC Objects
--====================================================================--


--====================================================================--
--== Configuration


dmc_lib_data.dmc_objects = dmc_lib_data.dmc_objects or {}

local DMC_OBJECTS_DEFAULTS = {
}

local dmc_objects_data = Utils.extend( dmc_lib_data.dmc_objects, DMC_OBJECTS_DEFAULTS )



--====================================================================--
--== Imports


local LuaObject = require 'lib.dmc_lua.lua_objects'
local EventsMixModule = require 'lib.dmc_lua.lua_events_mix'



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local newClass = LuaObject.newClass
local Class = LuaObject.Class
local registerCtorName = LuaObject.registerCtorName
local registerDtorName = LuaObject.registerDtorName

local EventsMix = EventsMixModule.EventsMix


-- Add new Dtor name (function references)
registerDtorName( 'removeSelf', Class )



--====================================================================--
--== Support Functions


_G.getDMCObject = function( object )
	local ref = object.__dmc_ref
	assert( ref, "No reference to DMC Object" )
	return ref
end




--====================================================================--
--== Object Base Class
--====================================================================--


local ObjectBase = newClass( { Class, EventsMix }, { name="Object Class" } )



--======================================================--
--== Constructor / Destructor


-- __new__()
-- this method drives the construction flow for DMC-style objects
-- typically, you won't override this
--
function ObjectBase:__new__( ... )

	--== Do setup sequence ==--

	self:__init__( ... )

	-- skip these if a Class object (ie, NOT an instance)
	if rawget( self, '__is_class' ) == false then
		self:__initComplete__()
	end

	return self
end


-- __destroy__()
-- this method drives the destruction flow for DMC-style objects
-- typically, you won't override this
--
function ObjectBase:__destroy__()

	--== Do teardown sequence ==--

	-- skip these if a Class object (ie, NOT an instance)
	if rawget( self, '__is_class' ) == false then
		self:__undoInitComplete__()
	end

	self:__undoInit__()
end



--======================================================--
-- Start: Setup Lua Objects

-- __init__
-- initialize the object
--
function ObjectBase:__init__( ... )
	--[[
	there is no __init__ on Class
	-- self:superCall( Class, '__init__', ... )
	--]]
	self:superCall( EventsMix, '__init__', ... )
	--==--
end

-- __undoInit__
-- remove items added during __init__
--
function ObjectBase:__undoInit__()
	self:superCall( EventsMix, '__undoInit__' )
	--[[
	there is no __undoInit__ on Class
	-- self:superCall( Class, '__undoInit__' )
	--]]
end


-- __initComplete__
-- any setup after object is done with __init__
--
function ObjectBase:__initComplete__()
end

-- __undoInitComplete__()
-- remove any items added during __initComplete__
--
function ObjectBase:__undoInitComplete__()
end

-- END: Setup Lua Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods



--====================================================================--
--== Event Handlers

-- none






--====================================================================--
--== Corona Base Class
--====================================================================--


local CoronaBase = newClass( ObjectBase, { name="Corona Class" } )


--== Class Constants ==--

--references for setAnchor()
CoronaBase.TopLeftReferencePoint = { 0, 0 }
CoronaBase.TopCenterReferencePoint = { 0.5, 0 }
CoronaBase.TopRightReferencePoint = { 1, 0 }
CoronaBase.CenterLeftReferencePoint = { 0, 0.5 }
CoronaBase.CenterReferencePoint = { 0.5, 0.5 }
CoronaBase.CenterRightReferencePoint = { 1, 0.5 }
CoronaBase.BottomLeftReferencePoint = { 0, 1 }
CoronaBase.BottomCenterReferencePoint = { 0.5, 1 }
CoronaBase.BottomRightReferencePoint = { 1, 1 }

-- style of event dispatch
CoronaBase.DMC_EVENT_DISPATCH = 'dmc_event_style_dispatch'
CoronaBase.CORONA_EVENT_DISPATCH = 'corona_event_style_dispatch'




--======================================================--
--== Constructor / Destructor



-- __new__()
-- this method drives the construction flow for DMC-style objects
-- typically, you won't override this
--
function CoronaBase:__new__( ... )

	--== Do setup sequence ==--

	self:__init__( ... )

	-- skip these if a Class object (ie, NOT an instance)
	if rawget( self, '__is_class' ) == false then
		self:__createView__()
		self:__initComplete__()
	end

	return self
end

-- __destroy__()
-- this method drives the destruction flow for DMC-style objects
-- typically, you won't override this
--
function CoronaBase:__destroy__()

	-- skip these if we're an intermediate class (eg, subclass)
	if rawget( self, '__is_class' ) == false then
		self:__undoInitComplete__()
		self:__undoCreateView__()
	end

	self:__undoInit__()
end



--======================================================--
-- Start: Setup DMC Objects

-- __init__()
-- initialize the object
--
function CoronaBase:__init__( ... )
	self:superCall( '__init__', ... )
	--==--
	self:_setView( display.newGroup() )
end

-- __undoInit__()
-- de-initialize the object
--
function CoronaBase:__undoInit__()
	self:_unsetView()
	--==--
	self:superCall( '__undoInit__' )
end


-- _createView()
-- create any visual items specific to object
--
function CoronaBase:__createView__()
	-- Subclasses should call:
	-- self:superCall( '__createView__' )
	--==--
end

-- _undoCreateView()
-- remove any items added during _createView()
--
function CoronaBase:__undoCreateView__()
	--==--
	-- Subclasses should call:
	-- self:superCall( '__undoCreateView__' )
end


--[[

-- __initComplete__()
-- do final setup after view creation
--
function CoronaBase:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
end

-- __undoInitComplete__()
-- remove final setup before view destruction
--
function CoronaBase:__undoInitComplete__()
	--==--
	self:superCall( '__undoInitComplete__' )
end

--]]

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


-- _setView( viewObject )
-- set the view property to incoming view object
-- remove current if already set, only check direct property, not hierarchy
--
function CoronaBase:_setView( viewObject )
	self:_unsetView()

	self.view = viewObject
	self.display = self.view -- deprecated
	-- save ref of our Lua object on Corona element
	-- in case we need to get back to the object
	self.view.__dmc_ref = self
end
-- _unsetView()
-- remove the view property
--
function CoronaBase:_unsetView()
	if rawget( self, 'view' ) ~= nil then
		local view = self.view

		if view.__dmc_ref then view.__dmc_ref = nil end

		if view.numChildren ~= nil then
			for i = view.numChildren, 1, -1 do
				local o = view[i]
				o.parent:remove( o )
			end
		end
		view:removeSelf()
		self.view = nil
		self.display = nil
	end
end



--====================================================================--
--== Public Methods / Corona API


function CoronaBase:setTouchBlock( o )
	assert( o, "setTouchBlock: expected object" )
	o.touch = function(e) return true end
	o:addEventListener( 'touch', o )
end
function CoronaBase:unsetTouchBlock( o )
	assert( o, "unsetTouchBlock: expected object" )
	if o and o.touch then
		o:removeEventListener( 'touch', o )
		o.touch = nil
	end
end



function CoronaBase.__setters:dispatch_type( value )
	self._dispatch_type = value
end


-- destroy()
-- remove the view object from the stage
--
function CoronaBase:destroy()
	self:removeSelf()
end

function CoronaBase:show()
	self.view.isVisible = true
end
function CoronaBase:hide()
	self.view.isVisible = false
end


--== Corona Specific Properties and Methods ==--


--= DISPLAY GROUP =--

-- Properties --

-- numChildren
--
function CoronaBase.__getters:numChildren()
	return self.view.numChildren
end


-- Methods --

-- insert( [index,] child, [, resetTransform]  )
--
function CoronaBase:insert( ... )
	self.view:insert( ... )
end
-- remove( indexOrChild )
--
function CoronaBase:remove( ... )
	self.view:remove( ... )
end


--= CORONA OBJECT =--

-- Properties

-- alpha
--
function CoronaBase.__getters:alpha()
	return self.view.alpha
end
function CoronaBase.__setters:alpha( value )
	self.view.alpha = value
end
-- contentBounds
--
function CoronaBase.__getters:contentBounds()
	return self.view.contentBounds
end
-- contentHeight
--
function CoronaBase.__getters:contentHeight()
	return self.view.contentHeight
end
-- contentWidth
--
function CoronaBase.__getters:contentWidth()
	return self.view.contentWidth
end
-- height
--
function CoronaBase.__getters:height()
	return self.view.height
end
function CoronaBase.__setters:height( value )
	self.view.height = value
end
-- isHitTestMasked
--
function CoronaBase.__getters:isHitTestMasked()
	return self.view.isHitTestMasked
end
function CoronaBase.__setters:isHitTestMasked( value )
	self.view.isHitTestMasked = value
end
-- isHitTestable
--
function CoronaBase.__getters:isHitTestable()
	return self.view.isHitTestable
end
function CoronaBase.__setters:isHitTestable( value )
	self.view.isHitTestable = value
end
-- isVisible
--
function CoronaBase.__getters:isVisible()
	return self.view.isVisible
end
function CoronaBase.__setters:isVisible( value )
	self.view.isVisible = value
end
-- maskRotation
--
function CoronaBase.__getters:maskRotation()
	return self.view.maskRotation
end
function CoronaBase.__setters:maskRotation( value )
	self.view.maskRotation = value
end
-- maskScaleX
--
function CoronaBase.__getters:maskScaleX()
	return self.view.maskScaleX
end
function CoronaBase.__setters:maskScaleX( value )
	self.view.maskScaleX = value
end
-- maskScaleY
--
function CoronaBase.__getters:maskScaleY()
	return self.view.maskScaleY
end
function CoronaBase.__setters:maskScaleY( value )
	self.view.maskScaleY = value
end
-- maskX
--
function CoronaBase.__getters:maskX()
	return self.view.maskX
end
function CoronaBase.__setters:maskX( value )
	self.view.maskX = value
end
-- maskY
--
function CoronaBase.__getters:maskY()
	return self.view.maskY
end
function CoronaBase.__setters:maskY( value )
	self.view.maskY = value
end
-- parent
--
function CoronaBase.__getters:parent()
	return self.view.parent
end
-- rotation
--
function CoronaBase.__getters:rotation()
	return self.view.rotation
end
function CoronaBase.__setters:rotation( value )
	self.view.rotation = value
end
-- stageBounds
--
function CoronaBase.__getters:stageBounds()
	print( "\nDEPRECATED: object.stageBounds - use object.contentBounds\n" )
	return self.view.stageBounds
end
-- width
--
function CoronaBase.__getters:width()
	return self.view.width
end
function CoronaBase.__setters:width( value )
	self.view.width = value
end
-- x
--
function CoronaBase.__getters:x()
	return self.view.x
end
function CoronaBase.__setters:x( value )
	self.view.x = value
end
-- xOrigin
--
function CoronaBase.__getters:xOrigin()
	return self.view.xOrigin
end
function CoronaBase.__setters:xOrigin( value )
	self.view.xOrigin = value
end
-- xReference
--
function CoronaBase.__getters:xReference()
	return self.view.xReference
end
function CoronaBase.__setters:xReference( value )
	self.view.xReference = value
end
-- xScale
--
function CoronaBase.__getters:xScale()
	return self.view.xScale
end
function CoronaBase.__setters:xScale( value )
	self.view.xScale = value
end
-- y
--
function CoronaBase.__getters:y()
	return self.view.y
end
function CoronaBase.__setters:y( value )
	self.view.y = value
end
-- yOrigin
--
function CoronaBase.__getters:yOrigin()
	return self.view.yOrigin
end
function CoronaBase.__setters:yOrigin( value )
	self.view.yOrigin = value
end
-- yReference
--
function CoronaBase.__getters:yReference()
	return self.view.yReference
end
function CoronaBase.__setters:yReference( value )
	self.view.yReference = value
end
-- yScale
--
function CoronaBase.__getters:yScale()
	return self.view.yScale
end
function CoronaBase.__setters:yScale( value )
	self.view.yScale = value
end


-- Methods --

-- contentToLocal( x_content, y_content )
--
function CoronaBase:contentToLocal( ... )
	self.view:contentToLocal( ... )
end

-- localToContent( x, y )
--
function CoronaBase:localToContent( ... )
	self.view:localToContent( ... )
end

-- rotate( deltaAngle )
--
function CoronaBase:rotate( ... )
	self.view:rotate( ... )
end
-- scale( sx, sy )
--
function CoronaBase:scale( ... )
	self.view:scale( ... )
end

-- setAnchor
--
function CoronaBase:setAnchor( ... )
	local args = {...}
	if type( args[2] ) == 'table' then
		self.view.anchorX, self.view.anchorY = unpack( args[2] )
	end
	if type( args[2] ) == 'number' then
		self.view.anchorX = args[2]
	end
	if type( args[3] ) == 'number' then
		self.view.anchorY = args[3]
	end
end
function CoronaBase:setMask( ... )
	print( "\nWARNING: setMask( mask ) not tested \n" );
	self.view:setMask( ... )
end
-- setReferencePoint( referencePoint )
--
function CoronaBase:setReferencePoint( ... )
	self.view:setReferencePoint( ... )
end
-- toBack()
--
function CoronaBase:toBack()
	self.view:toBack()
end
-- toFront()
--
function CoronaBase:toFront()
	self.view:toFront()
end
-- translate( deltaX, deltaY )
--
function CoronaBase:translate( ... )
	self.view:translate( ... )
end




--[[

--====================================================================--
--== CoronaPhysics Class
--====================================================================--


local CoronaPhysics = inheritsFrom( CoronaBase )
CoronaPhysics.NAME = "Corona Physics"


-- Properties --

-- angularDamping()
--
function CoronaPhysics.__getters:angularDamping()
	return self.view.angularDamping
end
function CoronaPhysics.__setters:angularDamping( value )
	self.view.angularDamping = value
end
-- angularVelocity()
--
function CoronaPhysics.__getters:angularVelocity()
	return self.view.angularVelocity
end
function CoronaPhysics.__setters:angularVelocity( value )
	self.view.angularVelocity = value
end
-- bodyType()
--
function CoronaPhysics.__getters:bodyType()
	return self.view.bodyType
end
function CoronaPhysics.__setters:bodyType( value )
	self.view.bodyType = value
end
-- isAwake()
--
function CoronaPhysics.__getters:isAwake()
	return self.view.isAwake
end
function CoronaPhysics.__setters:isAwake( value )
	self.view.isAwake = value
end
-- isBodyActive()
--
function CoronaPhysics.__getters:isBodyActive()
	return self.view.isBodyActive
end
function CoronaPhysics.__setters:isBodyActive( value )
	self.view.isBodyActive = value
end
-- isBullet()
--
function CoronaPhysics.__getters:isBullet()
	return self.view.isBullet
end
function CoronaPhysics.__setters:isBullet( value )
	self.view.isBullet = value
end
-- isFixedRotation()
--
function CoronaPhysics.__getters:isFixedRotation()
	return self.view.isFixedRotation
end
function CoronaPhysics.__setters:isFixedRotation( value )
	self.view.isFixedRotation = value
end
-- isSensor()
--
function CoronaPhysics.__getters:isSensor()
	return self.view.isSensor
end
function CoronaPhysics.__setters:isSensor( value )
	self.view.isSensor = value
end
-- isSleepingAllowed()
--
function CoronaPhysics.__getters:isSleepingAllowed()
	return self.view.isSleepingAllowed
end
function CoronaPhysics.__setters:isSleepingAllowed( value )
	self.view.isSleepingAllowed = value
end
-- linearDamping()
--
function CoronaPhysics.__getters:linearDamping()
	return self.view.linearDamping
end
function CoronaPhysics.__setters:linearDamping( value )
	self.view.linearDamping = value
end


-- Methods --

-- applyAngularImpulse( appliedForce )
--
function CoronaPhysics:applyAngularImpulse( ... )
	self.view:applyAngularImpulse( ... )
end
-- applyForce( xForce, yForce, bodyX, bodyY )
--
function CoronaPhysics:applyForce( ... )
	self.view:applyForce( ... )
end
-- applyLinearImpulse( xForce, yForce, bodyX, bodyY )
--
function CoronaPhysics:applyLinearImpulse( ... )
	self.view:applyLinearImpulse( ... )
end
-- applyTorque( appliedForce )
--
function CoronaPhysics:applyTorque( ... )
	self.view:applyTorque( ... )
end
-- getLinearVelocity()
--
function CoronaPhysics:getLinearVelocity()
	return self.view:getLinearVelocity()
end
-- resetMassData()
--
function CoronaPhysics:resetMassData()
	self.view:resetMassData()
end
-- setLinearVelocity( xVelocity, yVelocity )
--
function CoronaPhysics:setLinearVelocity( ... )
	self.view:setLinearVelocity( ... )
end

--]]



--====================================================================--
--== DMC Objects Exports
--====================================================================--


-- simply add to current exports
LuaObject.ObjectBase = ObjectBase
LuaObject.CoronaBase = CoronaBase



return LuaObject

