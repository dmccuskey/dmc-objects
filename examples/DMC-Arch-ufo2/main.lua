--====================================================================--
-- UFO2 OOP Example
--
-- by David McCuskey
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011 David McCuskey. All Rights Reserved.
--====================================================================--



print( '\n\n##############################################\n\n' )



--====================================================================--
--== Imports


local widget = require 'widget'
local UFOFactory = require 'component.ufo'



--====================================================================--
--== Setup, Constants


local mrand = math.random

local MAX_UFOS = 5
local W, H = display.viewableContentWidth, display.viewableContentHeight
local H_CENTER, V_CENTER = W*0.5, H*0.5


-- display groups, this order
local bg_group
local ufo_group
local ui_group

local ufo_dict

local createUFO, deleteUFO
local ufoTouch_handler -- forward declare function

display.setStatusBar( display.HiddenStatusBar )



--====================================================================--
--== Support Functions


-- a better random seed
local function seedRandom()
	local seed = tostring( os.time() ) .. tostring( system.getTimer() )
	seed = string.sub( seed, 5 )
	math.randomseed( seed )
end



--== Event Handlers


ufoTouch_handler = function( event )
	-- print( "ufoTouch_handler" )
	deleteUFO( event.target )
end



--== Setup App Layers


createUFO = function()
	-- print( "createUFO" )

	local ufo, key

	-- object
	ufo = UFOFactory:new()
	ufo_group:insert( ufo.view )

	-- event listener
	ufo:addEventListener( ufo.EVENT, ufoTouch_handler )

	-- storage
	key = tostring( ufo )
	ufo_dict[ key ] = ufo

end

deleteUFO = function( ufo )
	-- print( "deleteUFO" )

	local key

	-- storage
	key = tostring( ufo )
	ufo_dict[ key ] = nil

	-- event listener
	ufo:removeEventListener( ufo.EVENT, ufoTouch_handler )

	-- object
	ufo:removeSelf()

end



local function setupBackgroundLayer()

	bg_group = display.newGroup()

	-- create space background
	local o = display.newImageRect( 'asset/space_bg.png', W, H )
	o.x, o.y = H_CENTER, V_CENTER

	bg_group:insert( o )

end


local function setupUFOLayer()
	ufo_group = display.newGroup()
end


local function setupUILayer()

	local PADDING = 15

	-- button constants
	local w, h = 120, 45
	local y = H-h-PADDING

	local o 


	ui_group = display.newGroup()


	local createButtonTouch_handler = function( event )
		createUFO()
		return true
	end

	local moveButtonTouch_handler = function( event )

		local speeds = { UFOFactory.FAST, UFOFactory.MEDIUM, UFOFactory.SLOW }

		-- loop through all ufo objects,
		-- get random speed and ask ufo to move()
		-- with that speed
		for k, ufo in pairs( ufo_dict ) do 
			local idx = mrand(#speeds)
			ufo:move( speeds[ idx ] )
		end

		return true
	end



	-- move button
	o = widget.newButton
	{
		left = H_CENTER-w-PADDING,
		top = y,
		width = w,
		height = h,
		label = "Create",
		font=system.nativeFontBold,
		fontSize=24,
		onRelease = createButtonTouch_handler,
	}
	ui_group:insert( o )

	-- create button
	o = widget.newButton
	{
		left = H_CENTER+PADDING,
		top = y,
		width = w,
		height = h,
		label = "Move",
		font=system.nativeFontBold,
		fontSize=24,
		onRelease = moveButtonTouch_handler,
	}
	ui_group:insert( o )

end



--====================================================================--
--== Main
--====================================================================--


local function main()

	ufo_dict = {}

	-- in this order to properly layer display groups
	setupBackgroundLayer()
	setupUFOLayer()
	setupUILayer()

end


main()

