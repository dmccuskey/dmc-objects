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
			"dmc-corona-boot",
			"DMC-Lua-Library"
		]
	},
	"examples": {
		"base_dir": "examples",
		"apps": [
			{
				"exp_dir": "Corona-Graphics-Fishies",
				"requires": []
			},
			{
				"exp_dir": "Corona-Physics-ManyCrates",
				"requires": []
			},
			{
				"exp_dir": "DMC-Arch-ufo2",
				"requires": []
			},
			{
				"exp_dir": "DMC-MultiShapes",
				"requires": []
			},
			{
				"exp_dir": "DMC-ufo",
				"requires": []
			}
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}

register( "dmc-objects", module_config )

