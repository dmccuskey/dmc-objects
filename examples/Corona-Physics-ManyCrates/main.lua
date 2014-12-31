--====================================================================--
-- Corona Crates Example
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


local CrateFactory = require 'component.crates'
local Physics = require 'physics'



--====================================================================--
--== Setup, Constants


local mrand = math.random

local W, H = display.viewableContentWidth, display.viewableContentHeight
local H_CENTER, V_CENTER = W*0.5, H*0.5

Physics.start()
display.setStatusBar( display.HiddenStatusBar )




--====================================================================--
--== Support Functions


-- a better random seed
local function seedRandom()
	local seed = tostring( os.time() ) .. tostring( system.getTimer() )
	seed = string.sub( seed, 5 )
	math.randomseed( seed )
end


-- add our crates to the display
function addCrate()

	local crate = CrateFactory.create()

	crate.x = 60 + mrand( 160 )
	crate.y = -100

	physics.addBody( crate.display, crate:getPhysicsProps() )

end



--====================================================================--
--== Main
--====================================================================--


local function initializeDisplay()

	seedRandom()

	--== set background image ==--

	local bkg = display.newImage( 'asset/bkg_cor.png' )
	bkg.x, bkg.y = H_CENTER, V_CENTER

	--== setup Grass ==--

	-- grass for physics
	local grass = display.newImage( 'asset/grass.png' )
	grass.x, grass.y = H_CENTER, H-grass.height/2-20
	physics.addBody( grass, "static", { friction=0.5, bounce=0.3 } )

	-- setup decorative Grass  ( non-physical decorative overlay )
	local grass2 = display.newImage( 'asset/grass2.png' )
	grass2.x, grass2.y = H_CENTER, H-grass2.height/2

end



local function main()

	initializeDisplay()

	-- start crates
	local dropCrates = timer.performWithDelay( 500, addCrate, 100 )

end

main()