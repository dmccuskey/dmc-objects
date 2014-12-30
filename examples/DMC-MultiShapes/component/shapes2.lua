--====================================================================--
-- Shapes 1 Class
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
--== Base Shapes Class (images)
--====================================================================--


local Shape = newClass( CoronaBase, { name="Shape Base" } )

--== Class Constants ==--

-- basic view params

Shape.IMAGE = ""
Shape.IMAGE_W = 0
Shape.IMAGE_H = 0


--======================================================--
-- Start: Setup DMC Objects

function Shape:__init__( params )
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	self.rotation = 0

end

function Shape:__undoInit__()
	self.rotation = nil 
	--==--
	self:superCall( '__undoInit__' )
end


function Shape:__createView__()
	self:superCall( '__createView__' )
	--==--

	local o -- object tmp

	o = display.newImageRect( self.IMAGE, self.IMAGE_W, self.IMAGE_H )
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
--== Circle class
--====================================================================--


local Circle = newClass( Shape, { name="Circle" } )
Circle.IMAGE = 'asset/shape_circle.png'
Circle.IMAGE_W = 86
Circle.IMAGE_H = 86



--====================================================================--
--== Diamond class
--====================================================================--


local Diamond = newClass( Shape, { name="Diamond" } )
Diamond.IMAGE = 'asset/shape_diamond.png'
Diamond.IMAGE_W = 77
Diamond.IMAGE_H = 117



--====================================================================--
--== Hexagon class
--====================================================================--


local Hexagon = newClass( Shape, { name="Hexagon" } )
Hexagon.IMAGE = 'asset/shape_hexagon.png'
Hexagon.IMAGE_W = 86
Hexagon.IMAGE_H = 86



--====================================================================--
--== Square class
--====================================================================--


local Square = newClass( Shape, { name="Square" } )
Square.NAME = "Square"
Square.IMAGE = 'asset/shape_square.png'
Square.IMAGE_W = 86
Square.IMAGE_H = 86



--====================================================================--
--== Triangle class
--====================================================================--


local Triangle = newClass( Shape, { name="Triangle" } )
Triangle.IMAGE = 'asset/shape_triangle.png'
Triangle.IMAGE_W = 96
Triangle.IMAGE_H = 87





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

