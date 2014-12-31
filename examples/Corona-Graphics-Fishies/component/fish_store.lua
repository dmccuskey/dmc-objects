--====================================================================--
-- Fish Store Class
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


local mrand = math.random

-- aliases to make code cleaner
local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase




--====================================================================--
--== Fish Class
--====================================================================--


local Fish = newClass( ComponentBase, { name="A Fish" } )

--== Class Constants ==--

Fish.file1 = 'asset/fish.small.red.png'
Fish.file2 = 'asset/fish.small.blue.png'


--======================================================--
-- Start: Setup DMC Objects

function Fish:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	self._fish1 = nil 
	self._fish2 = nil 

	-- assign each fish a random velocity
	self.vx = mrand( 1, 5 )
	self.vy = mrand( -2, 2 )

end

-- reverse init() setup
function Fish:__undoInit__()

	self._fish1 = nil
	self._fish2 = nil

	self.vx = nil
	self.vy = nil

	--==--
	self:superCall( '__undoInit__' )
end


function Fish:__createView__()
	self:superCall( '__createView__' )
	--==--

	local o -- obj

	-- fish original
	o = display.newImage( self.file1 )

	self:insert( o, true )
	self._fish1 = o 

	-- fish different
	o = display.newImage( self.file2 )
	o.isVisible = false

	self:insert( o, true )
	self._fish2 = o

end

-- __undoCreateView__()
--
-- one of the base methods to override for dmc_objects
-- remove items added in __createView__()
--
function Fish:__undoCreateView__()
	-- print( "Fish:__undoCreateView__" )

	local o

	o = self._fish1
	o:removeSelf()

	o = self._fish2
	o:removeSelf()

	--==--
	-- be sure to call this last !
	self:superCall( '__undoCreateView__' )
end



function Fish:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--

	-- add some event listeners for those
	-- events we'd like to know about

	self:addEventListener( 'touch', self )
	Runtime:addEventListener( 'orientation', self )

end

function Fish:__undoInitComplete__()

	Runtime:removeEventListener( 'orientation', self )
	self:removeEventListener( 'touch', self )

	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- for some reason, scaling doesn't work around the proper reference point
-- need to figure out why
-- for now, just flip each image individually
--
-- BTW: it's a great name for a method - Fish Scale !
function Fish:scale( x, y )
	local d = self.display
	d[1]:scale( x, y )
	d[2]:scale( x, y )
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


function Fish:touch( event )

	local group = self.display

	if event.phase == "ended" then

		local topObject = group[1]

		if ( topObject.isVisible ) then
			local bottomObject = group[2]

			-- Dissolve to bottomObject (different color)
			transition.dissolve( topObject, bottomObject, 500 )

			-- Restore after some random delay
			transition.dissolve( bottomObject, topObject, 500, mrand( 3000, 10000 ) )
		end

		return true
	end

end

function Fish:orientation( event )

	if ( event.delta ~= 0 ) then

		local rotateParameters = { rotation = -event.delta, time=500, delta=true }

		Runtime:removeEventListener( 'enterFrame', self )

		transition.to( self.display, rotateParameters )

		local function resume( event )
			Runtime:addEventListener( 'enterFrame', self )
		end

		timer.performWithDelay( 500, resume )
	end

end




--====================================================================--
--== Fish Store Factory
--====================================================================--


local FishStore = {}


function FishStore.buyFish( params )
	return Fish:new( params )
end


return FishStore


