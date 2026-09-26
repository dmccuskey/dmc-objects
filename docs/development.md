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

The tests are in `tests/dmc_objects_spec.lua` ([lunatest](https://github.com/silentbicycle/lunatest)). They need Solar2D: open the repository's root folder in the Simulator, and `main.lua` runs them and prints the results to the console:

```text
-- Starting suite "tests.dmc_objects_spec", 7 test(s)
  ...FF..---- Testing finished, with 33 assertion(s) ----  5 passed, 2 failed, 0 error(s), 0 skipped.
FAIL: tests.dmc_objects_spec.test_objectBaseBasics: Expected "Object Base", got "Object Class" - name is incorrect
```

The two failures are out of date tests: they expect the class names from before the classes were renamed. The tests cover the class basics, inheritance and multiple inheritance, not the component classes' forwarding or the construction hooks.

## Possible Future Changes

Each needs discussion and a concrete use case before it is worked on.

- Forward the anchor properties (`anchorX`, `anchorY`, `anchorChildren`) to the view, and drop the Graphics 1.0 members listed in [Known Issues](api.md#known-issues).
- Tests that run in plain Lua, with stand-ins for `display`, like dmc-sockets' `tests/run_unit.sh`.
