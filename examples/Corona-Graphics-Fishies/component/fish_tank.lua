--====================================================================--
-- Fish Tank Class
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
local ComponentBase = Objects.ComponentBase

local mrand = math.random
local tinsert = table.insert

local W, H = display.viewableContentWidth, display.viewableContentHeight
local H_CENTER, V_CENTER = W*0.5, H*0.5



--====================================================================--
--== Fish Tank Object
--====================================================================--


local FishTank = newClass( ComponentBase, { name="Fish Tank" } )

--== Class Constants ==--

FishTank.REFLECT_X = true

-- Preload the sound file (theoretically, we should also dispose of it when we are completely done with it)
FishTank.SOUND = audio.loadSound( 'asset/bubble_strong_wav.wav' )


--======================================================--
-- Start: Setup DMC Objects

function FishTank:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- these will be the images
	self.background_portrait = nil
	self.background_landscape = nil

	-- current background image, selected via orientation handler
	self.background = nil

	self.current_orientation = "portrait"
	self.container = nil
	self.theFish = {}

end

-- reverse init() setup
function FishTank:__undoInit__()
	self.density = nil
	self.friction = nil
	self.bounce = nil

	--==--
	self:superCall( '__undoInit__' )
end



-- create basic object view
function FishTank:__createView__()
	self:superCall( '__createView__' )
	--==--

	local o 

	o = display.newImage( 'asset/aquariumbackgroundIPhone.jpg', 0, 0 )

	self:insert( o )
	self.background_portrait = o 


	o = display.newImage( 'asset/aquariumbackgroundIPhoneLandscape.jpg', 0, 0 )
	o.isVisible = false

	self:insert( o )
	self.background_landscape = o 


	o = display.newRect( 0, 0, W, H )
	o:setFillColor( 0, 0, 0, 0)	-- make invisible

	self:insert( o )
	self.container = o

end

-- __undoCreateView__()
--
-- one of the base methods to override for dmc_objects
-- remove items added in __createView__()
--
function FishTank:__undoCreateView__()
	-- print( "FishTank:__undoCreateView__" )

	local o

	o = self.container
	o:removeSelf()

	o = self.background
	o:removeSelf()

	o = self.background_landscape
	o:removeSelf()

	o = self.background_portrait
	o:removeSelf()

	--==--
	-- be sure to call this last !
	self:superCall( '__undoCreateView__' )
end



function FishTank:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--

	self.background = self.background_portrait

	-- add some event listeners for those events we'd like to know about

	Runtime:addEventListener( 'enterFrame', self )
	Runtime:addEventListener( 'orientation', self )

end

function FishTank:__undoInitComplete__()

	-- add some event listeners for those events we'd like to know about

	Runtime:removeEventListener( 'enterFrame', self )
	Runtime:removeEventListener( 'orientation', self )

	--==--
	-- be sure to call this last !
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function FishTank:addFish( fish )
	assert( fish, "must have a fish to add to tank" )

	-- save the fish in our tank
	tinsert( self.theFish, fish )

	-- move to random position in a 200x200 region in the middle of the screen
	fish.x = H_CENTER + mrand( -100, 100 )
	fish.y = V_CENTER + mrand( -100, 100 )

end


function FishTank:enterFrame( event )

	local containerBounds = self.container.contentBounds
	local xMin = containerBounds.xMin
	local xMax = containerBounds.xMax
	local yMin = containerBounds.yMin
	local yMax = containerBounds.yMax

	local orientation = self.current_orientation
	local isLandscape = "landscapeLeft" == orientation or "landscapeRight" == orientation

	local reflectX = nil ~= FishTank.REFLECT_X
	local reflectY = nil ~= FishTank.REFLECT_Y

	-- the fish groups are stored in integer arrays, so iterate through all the
	-- integer arrays
	for i,v in ipairs( self.theFish ) do
		local object = v  -- the display object to animate, e.g. the fish group
		local vx = object.vx
		local vy = object.vy

		if ( isLandscape ) then
			if ( "landscapeLeft" == orientation ) then
				local vxOld = vx
				vx = -vy
				vy = -vxOld
			elseif ( "landscapeRight" == orientation ) then
				local vxOld = vx
				vx = vy
				vy = vxOld
			end
		elseif ( "portraitUpsideDown" == orientation ) then
			vx = -vx
			vy = -vy
		end

		-- TODO: for now, time is measured in frames instead of seconds...
		local dx = vx
		local dy = vy

		local bounds = object.contentBounds

		local flipX = false
		local flipY = false

		if (bounds.xMax + dx) > xMax then
			flipX = true
			dx = xMax - bounds.xMax
		elseif (bounds.xMin + dx) < xMin then
			flipX = true
			dx = xMin - bounds.xMin
		end

		if (bounds.yMax + dy) > yMax then
			flipY = true
			dy = yMax - bounds.yMax
		elseif (bounds.yMin + dy) < yMin then
			flipY = true
			dy = yMin - bounds.yMin
		end

		if ( isLandscape ) then flipX,flipY = flipY,flipX end
		if ( flipX ) then
			object.vx = -object.vx
			if ( reflectX ) then object:scale( -1, 1 ) end
		end
		if ( flipY ) then
			object.vy = -object.vy
			if ( reflectY ) then object:scale( 1, -1 ) end
		end

		object:translate( dx, dy )

	end

end


-- Handle changes in orientation for the background images
function FishTank:orientation( event )

	self.current_orientation = event.type
	local delta = event.delta
	if ( delta ~= 0 ) then
		local rotateParams = { rotation=-delta, time=500, delta=true }

		if ( delta == 90 or delta == -90 ) then
			local src = self.background

			-- toggle background to refer to correct dst
			self.background = ( self.background_landscape == self.background and self.background_portrait ) or self.background_landscape
			self.background.rotation = src.rotation
			transition.dissolve( src, self.background )
			transition.to( src, rotateParams )
		else
			assert( 180 == delta or -180 == delta )
		end

		transition.to( self.background, rotateParams )

		audio.play( FishTank.SOUND )	-- play preloaded sound file
	end
end




return FishTank
