dmc-objects
===========

Advanced object oriented library for Corona SDK and Lua OOP

# Overview #

The `dmc-objects` modules power advanced, object-oriented development when using the Corona SDK. It provides:

* a classical model of object oriented programming
* a simple structure for creating/initializing/destroying Lua objects
* class getters and setters
* multiple inheritance
* support for mixins
* enhanced method access on supers
* an object API similar to Corona display objects
* fast execution through structure and optimizations

_**Though it's not just for Corona - the top-level object classes can be used when developing software in plain Lua.**_

Note: `dmc-objects` is a subclass of `lua-objects` and the latter does most of the heavy lifting. In this way `dmc-objects` not only provides a development framework for Corona SDK, it also provides a great example on how to subclass `lua-objects` with custom behavior.


**Documentation & Examples**

Additional documentation is online at: [docs.davidmccuskey.com](http://docs.davidmccuskey.com/display/docs/dmc-objects.lua)

There are several examples located in the folder `examples` which show how to setup OOP structures in Lua. Among these are some original Corona examples which have been modified to use `dmc-objects` and fit into an OOP style of programming.


**Questions or Comments**

If you have questions or comments you can either (preferred order):
* send me an email: corona-lib at davidmccuskey com
* send a PM @ coronalabs.com: @dmccuskey
* post an issue here on github
* post to the Corona forums: http://forums.coronalabs.com


**Issues**

If you discover any bugs, please post them here on github: [dmc-corona-library issues](https://github.com/dmccuskey/dmc-objects/issues)



## Installation & Use ##

For easy installation, copy the following items at the root-level of your Corona project:

* The entire `dmc_corona` folder
* `dmc_corona_boot.lua`
* `dmc_corona.cfg`

With this setup, modules should be imported like so:

```lua
local Objects = require 'dmc_corona.dmc_objects'
```


The library has been designed to give a lot of flexibility where it is stored in your project. For more information regarding installation, visit how to [install the library](http://docs.davidmccuskey.com/display/docs/Install+the+DMC+Corona+Library).



