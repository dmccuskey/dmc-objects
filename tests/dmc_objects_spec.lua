module(..., package.seeall)



--====================================================================--
-- Test: dmc_objects
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


require( 'dmc_corona_boot' )

local Objects = require 'dmc_objects'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ObjectBase = Objects.ObjectBase
local CoronaBase = Objects.CoronaBase



--====================================================================--
--== Module Testing
--====================================================================--


function test_moduleBasics()

	assert_equal( type(_G.getDMCObject), 'function', "should be function" )

	assert_equal( _G.getDMCObject( { __dmc_ref=true } ), true, "should be true" )

	assert_error( "not true", function() _G.getDMCObject( {} ) end )

end



--====================================================================--
--== ObjectBase Testing
--====================================================================--


--[[
--]]

function test_objectBaseBasics()

	assert_equal( ObjectBase.NAME, "Object Class", "name is incorrect" )
	assert_equal( type(ObjectBase.new), 'function', "should be function" )
	assert_equal( type(ObjectBase.removeSelf), 'function', "should be function" )

	assert_equal( type(ObjectBase.isa), 'function', "should be function" )

	assert_equal( type(rawget(ObjectBase, '__init__')), 'function', "should be function" )
	assert_equal( type(rawget(ObjectBase, '__undoInit__')), 'function', "should be function" )
	assert_equal( type(rawget(ObjectBase, '__initComplete__')), 'function', "should be function" )
	assert_equal( type(rawget(ObjectBase, '__undoInitComplete__')), 'function', "should be function" )

end


function test_eventMixinBasics()

	assert_equal( type(ObjectBase.dispatchEvent), 'function', "should be function" )
	assert_equal( type(ObjectBase.addEventListener), 'function', "should be function" )
	assert_equal( type(ObjectBase.removeEventListener), 'function', "should be function" )

end



function test_basicObjectBase()

	local ClassA
	local obj 


	ClassA = newClass( ObjectBase, { name="Class A" } )

	function ClassA:__init__( params )
		-- print( "ClassA:__init__", params )
		params = params or {}
		self:superCall( '__init__', params )
		--==--
		self._init = '__init__'
	end

	function ClassA:__undoInit__( )
		-- print( "ClassA:__undoInit__" )
		self._init = '__undoInit__'
		--==--
		self:superCall( '__undoInit__' )
	end

	function ClassA:__initComplete__( )
		-- print( "ClassA:__initComplete__" )
		self:superCall( '__initComplete__' )
		--==--
		self._initComplete = '__initComplete__'
	end

	function ClassA:__undoInitComplete__()
		-- print( "ClassA:__undoInitComplete__" )
		self._initComplete = '__undoInitComplete__'
		--==--
		self:superCall( '__undoInitComplete__' )
	end


	obj = ClassA:new()

	assert_equal( obj._init, "__init__", "name is incorrect" )
	assert_equal( obj._initComplete, "__initComplete__", "name is incorrect" )

	assert_equal( type(rawget(obj, '__event_listeners')), 'table', "should be table" )
	assert_equal( type(rawget(obj, '__debug_on')), 'boolean', "should be boolean" )
	assert_equal( type(rawget(obj, '__event_func')), 'function', "should be function" )

	obj:removeSelf()

	assert_equal( obj._init, "__undoInit__", "name is incorrect" )
	assert_equal( obj._initComplete, "__undoInitComplete__", "name is incorrect" )

	assert_equal( type(rawget(obj, '__event_listeners')), 'nil', "should be nil" )
	assert_equal( type(rawget(obj, '__debug_on')), 'nil', "should be nil" )
	assert_equal( type(rawget(obj, '__event_func')), 'nil', "should be nil" )

end 


--[[
--]]

function test_basicObjectBaseInheritance()

	local ClassA, ClassB
	local obj, obj2 


	ClassA = newClass( ObjectBase, { name="Class A" } )

	function ClassA:__init__( params )
		-- print( "ClassA:__init__", params )
		params = params or {}
		self:superCall( '__init__', params )
		--==--
		params.p_one = "override"
		self.one = params.p_one
		self.two = params.p_two
	end


	ClassB = newClass( ClassA, { name="Class B" } )

	function ClassB:__init__( num )
		-- print( "ClassB:__init__", params )
		params = params or {}
		self:superCall( '__init__', params )
		--==--

		self.one = params.p_one
		self.two = params.p_two
	end

	-- create objects

	obj = ClassA:new{ p_one='one', p_two='two' }
	obj2 = ClassA{ p_one='1', p_two='2' }

	-- test objects

	assert_equal( obj.one, "override", "name is incorrect" )
	assert_equal( obj.two, "two", "name is incorrect" )

	assert_equal( obj2.one, "override", "name is incorrect" )
	assert_equal( obj2.two, "2", "name is incorrect" )

end



function test_multiInheritance()

	local ClassA, ClassB, ClassC, ClassZ
	local obj, obj2 


	ClassZ = newClass( ObjectBase, { name="Class Z" } )

	function ClassZ:__init__( params )
		-- print( "ClassZ:__init__", params )
		params = params or {}
		self:superCall( '__init__', params )
		--==--
		self._checkEnd = false
	end

	function ClassZ:checkEnd()
		-- print( "ClassZ:checkEnd" )
		--==--
		self._checkEnd = true
	end


	ClassA = newClass( ClassZ, { name="Class A" } )

	function ClassA:__init__( params )
		-- print( "ClassA:__init__", params )
		params = params or {}
		self:superCall( '__init__', params )
		--==--
		params.p_one = "Override A"
		self.one = params.p_one
	end


	ClassB = newClass( ObjectBase, { name="Class B" } )

	function ClassB:__init__( params )
		-- print( "ClassB:__init__", params )
		params = params or {}
		self:superCall( '__init__', params )
		--==--
		params.p_two = "Override B"
		self.two = params.p_two
	end


	ClassC = newClass( { ClassA, ClassB }, { name="Class C" } )

	function ClassC:__init__( params )
		-- print( "ClassC:__init__", params )
		params = params or {}
		self:superCall( ClassB, '__init__', params )
		self:superCall( ClassA, '__init__', params )
		--==--

		self.one = params.p_one
		self.two = params.p_two
		self.three = params.p_three
	end

	function ClassC:checkEnd()
		-- print( "ClassC:checkEnd" )
		self:superCall( 'checkEnd', params )
		--==--
	end


	-- create objects

	obj = ClassC:new{ p_one='one', p_two='two', p_three='three' }
	obj2 = ClassC:new{ p_one='apple', p_two='orange', p_three='pear' }

	-- test objects

	assert_equal( ClassC.one, "Override A", "name is incorrect" )
	assert_equal( ClassC.two, "Override B", "name is incorrect" )

	assert_equal( obj.one, "Override A", "name is incorrect" )
	assert_equal( obj.two, "Override B", "name is incorrect" )
	assert_equal( obj.three, "three", "name is incorrect" )

	assert_equal( obj2.one, "Override A", "name is incorrect" )
	assert_equal( obj2.two, "Override B", "name is incorrect" )
	assert_equal( obj2.three, "pear", "name is incorrect" )

	assert_false( obj == obj2, "name is incorrect" )

	assert_equal( obj._checkEnd, false, "name is incorrect" )
	obj:checkEnd()
	assert_equal( obj._checkEnd, true, "name is incorrect" )

end



--====================================================================--
--== CoronaBase Testing
--====================================================================--


function test_coronaBaseBasics()

	assert_equal( CoronaBase.NAME, "Corona Class", "name is incorrect" )
	assert_equal( type(CoronaBase.new), 'function', "should be function" )

	assert_equal( type(CoronaBase.isa), 'function', "should be function" )

end


