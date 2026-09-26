# dmc-objects Documentation

New here? The [Quick Start](../README.md#quick-start) writes a class and moves an instance of it in about 10 minutes.

## Start

- [Quick Start](../README.md#quick-start): copy the library in, write a class, create, move and remove an instance

## Use

- [Writing Classes](writing-classes.md): choosing a base class, the class file layout, construction and teardown, getters and setters, events, speed
- [API reference](api.md): `newClass()`, class members, `ObjectBase`, `ComponentBase`, `PhysicsComponentBase`, configuration, known issues
- [Examples](../examples/): five apps, including two Solar2D samples rewritten as classes

## Internals

- [lua-class](https://github.com/dmccuskey/lua-class): the class model underneath (`newClass()`, `superCall()`, getters and setters, multiple inheritance), for plain Lua
- [lua-objects](https://github.com/dmccuskey/lua-objects): `ObjectBase` and its events, for plain Lua

## Contribute

- [Development](development.md): which files are generated, building, tests, possible future changes
- [Issues](https://github.com/dmccuskey/dmc-objects/issues)

## Project Structure

```text
README.md                   landing page and Quick Start
LICENSE
docs/                       this documentation
└── images/                 screenshots for the README
dmc_corona/                 what apps copy
├── dmc_objects.lua         the component classes (source)
├── dmc_states_mix.lua      states mixin (generated copy)
└── lib/dmc_lua/            DMC Lua library, with lua-objects (generated copy)
dmc_corona_boot.lua         loader, from dmc-corona-boot (generated copy)
dmc_corona.cfg              library configuration
examples/                   sample apps, each with its own generated dmc_corona/
└── screenshots/            one per app, for examples/README.md
main.lua                    runs the tests in the Solar2D Simulator
Snakefile                   build rules for the generated copies
tests/
├── dmc_objects_spec.lua
└── lunatest.lua            test framework (Scott Vokes, MIT)
```
