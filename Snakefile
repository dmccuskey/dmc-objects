# dmc-objects

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-objects"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-objects",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_objects.lua"
		],
		"requires": [
			"DMC-Lua-Library"
		]
	},
	"examples": {
		"dir": "examples",
		"apps": [
			{
				"dir": "Corona-Graphics-Fishies",
				"requires": []
			},
			{
				"dir": "Corona-Physics-ManyCrates",
				"requires": []
			},
			{
				"dir": "DMC-Arch-ufo2",
				"requires": []
			},
			{
				"dir": "DMC-MultiShapes",
				"requires": []
			},
			{
				"dir": "DMC-ufo",
				"requires": []
			}
		]
	},
	"tests": {
		"files": [
		],
		"requires": [
		]
	}
}

register( "dmc-objects", module_config )

