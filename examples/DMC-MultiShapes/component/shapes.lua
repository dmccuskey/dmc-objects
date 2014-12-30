--====================================================================--
-- Shapes 1 Class - Lines
--
-- by David McCuskey
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_corona.dmc_objects'



--====================================================================--
--== Setup, Constants


-- aliases to make code cleaner
local newClass = Objects.newClass
local CoronaBase = Objects.CoronaBase

-- save local copy of math.random
local mfloor = math.floor
local mrand = math.random



--====================================================================--
--== Base Shapes Class (lines)
--====================================================================--


local Shape = newClass( CoronaBase, { name="Shape Base" } )

--== Class Constants ==--

-- basic view params

Shape.TRANSPARENT = { 0, 0, 0, 0 }
Shape.STROKE_WIDTH = 5

-- list of points

Shape.P_LIST1 = nil
Shape.P_LIST2 = nil


--======================================================--
-- Start: Setup DMC Objects

function Shape:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	self.color = params.color or { mrand(255), mrand(255), mrand(255) }

end

-- reverse init() setup
function Shape:__undoInit__()
	self.color = nil
	--==--
	self:superCall( '__undoInit__' )
end

-- this method works for point-base shapes
-- we will override for general functions
function Shape:__createView__()
	self:superCall( '__createView__' )
	--==--

	local p_list1 = self.P_LIST1
	local p_list2 = self.P_LIST2

	local o -- object tmp

	-- create a display element
	o = display.newLine( unpack( p_list1 ) )
	o:append( unpack( p_list2 ) )
	o:setStrokeColor( unpack( self.color ) )
	o.strokeWidth = self.STROKE_WIDTH

	-- save in our object view, which is a display group
	self:insert( o )

end

function Shape:__undoCreateView__()
	local o = self.view[1]
	o:removeSelf()
	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


-- none

--== Event Handlers
-- none



--====================================================================--
--== Circle class
--====================================================================--


local Circle = newClass( Shape, { name="Circle" } )

--== Class Constants ==--

Circle.P_LIST1 = { 0, 0, 20 }


--======================================================--
-- Start: Setup DMC Objects

-- using Corona native circle method
function Circle:__createView__()

	local o -- object tmp

	-- create a display element
	o = display.newCircle( unpack( self.P_LIST1 ) )
	o:setFillColor( unpack( Shape.TRANSPARENT ) )
	o:setStrokeColor( unpack( self.color ) )
	o.strokeWidth = self.STROKE_WIDTH

	-- save in our object view, display group
	self:insert( o )
end

-- End: Setup DMC Objects
--======================================================--



--====================================================================--
--== Diamond class
--====================================================================--


local Diamond = newClass( Shape, { name="Diamond" } )

--== Class Constants ==--

Diamond.P_LIST1 = { 0, -40, 20, 0 }
Diamond.P_LIST2 = { 0, 40, -20, 0, 0, -40 }



--====================================================================--
--== Hexagon class
--====================================================================--


local Hexagon = newClass( Shape, { name="Hexagon" } )

Hexagon.P_LIST1 = { 0, 17.2, 10, 0 }
Hexagon.P_LIST2 = { 30, 0, 40, 17.2, 30, 34.4, 10, 34.4, 0, 17.2 }



--====================================================================--
--== Square class
--====================================================================--


local Square = newClass( Shape, { name="Square" } )

--== Class Constants ==--

Square.P_LIST1 = { 0, 0, 40, 40 }


--======================================================--
-- Start: Setup DMC Objects

-- we could make this from points,
-- but just showing an override
--
function Square:__createView__()

	local o -- object tmp

	-- create a display element
	o = display.newRect( unpack( self.P_LIST1 ) )
	o:setStrokeColor( unpack( self.color ) )
	o:setFillColor( unpack( Shape.TRANSPARENT ) )
	o.strokeWidth = self.STROKE_WIDTH

	-- save in our object view, display group
	self:insert( o )
end

-- End: Setup DMC Objects
--======================================================--



--====================================================================--
--== Triangle class
--====================================================================--


local Triangle = newClass( Shape, { name="Triangle" } )

Triangle.P_LIST1 = { -30, 0, 0, 50 }
Triangle.P_LIST2 = { 30, 0, -30, 0 }




--====================================================================--
--== Shape Factory
--====================================================================--


--======================================================--
-- Support Functions

local SHAPES_LIST = { "circle", "diamond", "hexagon", "square", "triangle" }

local function selectRandomShape()
	local randRange = 100
	local randNum = mrand( randRange )

	local shapeDivisor = randRange / #SHAPES_LIST
	local shapeIdx = mfloor( randNum / shapeDivisor )
	if randNum ~= 100 then shapeIdx = shapeIdx + 1 end

	return SHAPES_LIST[ shapeIdx ]
end


--======================================================--
-- Factory

local ShapeFactory = {}

function ShapeFactory.create( shape, params )

	local shapeType = shape or selectRandomShape()
	local params = params or {}
	local s

	if ( shapeType == "square" ) then
		s = Square:new( params )

	elseif ( shapeType == "diamond" ) then
		s = Diamond:new( params )

	elseif ( shapeType == "circle" ) then
		s = Circle:new( params )

	elseif ( shapeType == "hexagon" ) then
		s = Hexagon:new( params )

	elseif ( shapeType == "triangle" ) then
		s = Triangle:new( params )

	else
		print ( "Shape Factory, unknown shape!! " .. tostring( shapeType ) )
	end

	return s
end


return ShapeFactory
