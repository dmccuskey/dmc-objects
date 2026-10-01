# Development

How dmc-objects is built and tested, and what could change.

## Where the Code Lives

Only `dmc_corona/dmc_objects.lua` (the component classes) is written in this repository. The rest of `dmc_corona/`, `dmc_corona_boot.lua`, and each example's copy of them are generated: they are copied from the repositories that own them by the build below. Fix a generated file in its own repository, then rebuild:

| file | owner |
|---|---|
| `lua_class.lua` (`newClass()`, `superCall()`, getters and setters) | [lua-class](https://github.com/dmccuskey/lua-class) |
| `lua_objects.lua` (`ObjectBase`) | [lua-objects](https://github.com/dmccuskey/lua-objects) |
| `lua_events_mix.lua` (events) | [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin) |
| `dmc_states_mix.lua` | [dmc-states-mixin](https://github.com/dmccuskey/dmc-states-mixin) |
| `dmc_corona_boot.lua` | [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) |
| the rest of `lib/dmc_lua/` | [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) |

## Building

The `Snakefile` lists this library's files, the libraries it requires, and the example apps. The build rules are in [DMC-Corona-Library](https://github.com/dmccuskey/DMC-Corona-Library) (`snakemake/Snakefile`), which expects every required repository checked out next to this one. From this repository:

```sh
snakemake --cores 1 build_all     # dmc_corona/ and every examples/*/dmc_corona/
snakemake --cores 1 -n build_all  # dry run: show what would be copied
```

The build copies the sibling checkouts as they are on disk, on whatever branch each one has checked out.

## Testing

The tests are in `tests/dmc_objects_spec.lua` ([lunatest](https://github.com/silentbicycle/lunatest)). Run them with plain Lua 5.1, with stand-ins for the Solar2D globals they touch (`display.newGroup()`, `system`); it needs the `dkjson` rock:

```sh
tests/run_unit.sh                  # uses ../tools/lua51/bin/lua
LUA=lua5.1 tests/run_unit.sh       # or another Lua 5.1
```

To run them in Solar2D, open the repository's root folder in the Simulator: `main.lua` runs them and prints the results to the console:

```text
-- Starting suite "tests.dmc_objects_spec", 12 test(s)
  ............---- Testing finished, with 69 assertion(s) ----  12 passed, 0 failed, 0 error(s), 0 skipped.
```

They cover the class basics, inheritance and multiple inheritance, the module's exports, and the component classes' view, anchors and events. Each example app is a further check: run it in the Simulator after a change.
