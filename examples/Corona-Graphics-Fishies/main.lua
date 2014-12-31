--====================================================================--
-- Corona Fishies Example
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


local FishStore = require 'component.fish_store'
local FishTank = require 'component.fish_tank'



--====================================================================--
--== Setup, Constants


local mrand = math.random

local W, H = display.viewableContentWidth, display.viewableContentHeight
local H_CENTER, V_CENTER = W*0.5, H*0.5

-- how many fish in the tank
local NUM_FISH = 10

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


local function main()

	seedRandom()

	-- create our brand new fish tank
	local myFishTank = FishTank:new()
	myFishTank.x, myFishTank.y = H_CENTER, V_CENTER

	-- get some fish for it
	for i=1, NUM_FISH do
		local fish = FishStore.buyFish()
		myFishTank:addFish( fish )
	end

end


main()
