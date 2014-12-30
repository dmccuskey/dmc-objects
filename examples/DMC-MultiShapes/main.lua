--====================================================================--
-- Multi-shapes OOP Example
--
-- by David McCuskey
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
--====================================================================--



print( '\n\n##############################################\n\n' )



--====================================================================--
--== Imports


local ShapeFactory
local Widget = require 'widget'

-- try shapes 1
ShapeFactory = require 'component.shapes'

-- try shapes 2
-- ShapeFactory = require 'component.shapes2'



--====================================================================--
--== Setup, Constants


local mrand = math.random
local tinsert = table.insert
local tremove = table.remove

local CONTENT_W = display.viewableContentWidth
local CONTENT_H = display.viewableContentHeight

local NUM_SHAPES = 10

display.setStatusBar( display.HiddenStatusBar )



--====================================================================--
--== Support Functions


-- a better random seed
local function seedRandom()
	local seed = tostring( os.time() ) .. tostring( system.getTimer() )
	seed = string.sub( seed, 5 )
	math.randomseed( seed )
end




--====================================================================--
--== Main
--====================================================================--


local shapeList = {}
-- create this group to maintain layering of shapes/button
local shapeGroup = display.newGroup()


local function clearShapes()

	for i=#shapeList, 1, -1 do
		local shape = tremove( shapeList, i )
		shape:destroy()
	end

end

local function drawShapes()

	seedRandom()

	for i=1, NUM_SHAPES do
		local shape = ShapeFactory.create( nil, {
				color={ mrand(), mrand(), mrand() }
			}
		)
		tinsert( shapeList, shape )
		shapeGroup:insert( shape.display )
		local x, y, rotate = mrand( CONTENT_W ), mrand( CONTENT_H-100 )
		shape.x, shape.y = x, y
	end

end


--== The Push Button

-- Function to handle button events
local function refreshShapes()
	clearShapes()
	drawShapes()
end

-- Create the widget
local button = Widget.newButton{
    x = 0,
    y = 0,
    id = "button",
    label = "Randomize",
    font=native.systemFontBold,
    fontSize=30,
    onRelease = refreshShapes
}
button.x, button.y = CONTENT_W/2, CONTENT_H-40



-- Start the initial Draw

refreshShapes()

