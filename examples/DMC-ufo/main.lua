--====================================================================--
-- UFO OOP Example
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


-- our custom class
local UFOFactory = require 'component.ufo'



--====================================================================--
--== Setup, Constants


if system.getInfo('environment') ~= 'simulator' then
	display.setStatusBar( display.HiddenStatusBar )
end

local seed = os.time()
math.randomseed( seed )
local rand = math.random

local W, H = display.viewableContentWidth, display.viewableContentHeight

-- setup our space background
local OFFSET = 10 
local BG, Space = nil, nil 



--====================================================================--
--== Main
--====================================================================--


--== setup the Space Image and Bounding Area ==--

print( "Creating Space" )

BG = display.newImageRect( 'asset/space_bg.png', W, H )
BG.x, BG.y = W/2, H/2

Space = display.newRect( 0, 0, W, H )
Space:setFillColor( 0, 0, 0, 0 )
Space.anchorX, Space.anchorY = 0, 0

-- set Bounds in UFO class
UFOFactory.setSpace( Space )


--== Create UFOs ==--

print( "Creating UFOs" )

local ufo = UFOFactory.create()
ufo.x, ufo.y = rand(0+OFFSET, W-OFFSET), rand(0+OFFSET, H-OFFSET)
 
local ufo2 = UFOFactory.create()
ufo2.x, ufo2.y = rand(0+OFFSET, W-OFFSET), rand(0+OFFSET, H-OFFSET)


--== Destroy UFOs ==--

timer.performWithDelay( 20000, function()
	print( "Destroying UFOs" )
	ufo:removeSelf()
	ufo2:removeSelf()
end)

