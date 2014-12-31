--====================================================================--
-- Crate Class
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

local mfloor = math.floor
local mrand = math.random



--====================================================================--
--== Crate Base Class
--====================================================================--


local CrateBase = newClass( ComponentBase, { name="Crate Base" } )

--== Class Constants ==--

CrateBase.IMAGE_SRC = nil


--======================================================--
-- Start: Setup DMC Objects

-- do basic object init()
function CrateBase:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	self.density = nil
	self.friction = nil
	self.bounce = nil

end
-- reverse init() setup
function CrateBase:__undoInit__()
	self.density = nil
	self.friction = nil
	self.bounce = nil

	--==--
	self:superCall( '__undoInit__' )
end

-- create basic object view
function CrateBase:__createView__()
	self:superCall( '__createView__' )
	--==--

	local o -- object tmp

	o  = display.newImage( self.IMAGE_SRC )

	-- here we use our image for our view
	-- instead of default display group
	-- physics works better this way
	self:_setView( o )
end

-- __undoCreateView__()
--
-- one of the base methods to override for dmc_objects
-- remove items added in __createView__()
--
function CrateBase:__undoCreateView__()
	-- print( "CrateBase:__undoCreateView__" )

	local o = self.view 
	self:_unsetView()

	--==--
	-- be sure to call this last !
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function CrateBase:getPhysicsProps()

	return {
		density = self.density,
		friction = self.friction,
		bounce = self.bounce,
	}

end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== LARGE CRATE CLASS
--====================================================================--


local LargeCrate = newClass( CrateBase, { name="Large Create" } )

--== Class Constants ==--

LargeCrate.IMAGE_SRC = 'asset/crateB.png'


--======================================================--
-- Start: Setup DMC Objects

function LargeCrate:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	self.density = 1.4
	self.friction = 0.3
	self.bounce = 0.3

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== MEDIUM CRATE CLASS
--====================================================================--


local MediumCrate = newClass( CrateBase, { name="Medium Create" } )

--== Class Constants ==--

MediumCrate.IMAGE_SRC = 'asset/crate.png'


--======================================================--
-- Start: Setup DMC Objects

function MediumCrate:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	self.density = 0.9
	self.friction = 0.3
	self.bounce = 0.3

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== SMALL CRATE CLASS
--====================================================================--


local SmallCrate = newClass( CrateBase, { name="Small Create" } )

--== Class Constants ==--

SmallCrate.IMAGE_SRC = 'asset/crateC.png'


--======================================================--
-- Start: Setup DMC Objects

function SmallCrate:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	self.density = 0.3
	self.friction = 0.2
	self.bounce = 0.5

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== CRATE FACTORY
--====================================================================--


local CrateFactory = {}

CrateFactory.SMALL = 'small'
CrateFactory.MEDIUM = 'medium'
CrateFactory.LARGE = 'large'


--== Support Function ==--


local function selectRandomCrate()
	local rand = mrand( 100 )

	local crateType = ""

	if rand < 60 then
		crateType = CrateFactory.MEDIUM
	elseif rand < 80 then
		crateType = CrateFactory.LARGE
	else
		crateType = CrateFactory.SMALL
	end

	return crateType
end



function CrateFactory.create( crateType, params )

	local crateType = crateType or selectRandomCrate()
	local crate

	if crateType == CrateFactory.SMALL then
		crate = SmallCrate:new( params )

	elseif crateType == CrateFactory.MEDIUM then
		crate = MediumCrate:new( params )

	elseif crateType == CrateFactory.LARGE then
		crate = LargeCrate:new( params )
	end

	return crate
end



return CrateFactory
