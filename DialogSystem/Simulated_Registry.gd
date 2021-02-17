extends Node

var registry = {
	"test" : "this",
	"pi" : PI,
	"cos90" : cos(90),
	"date_time" : OS.get_datetime(),
	"os_name" : OS.get_name()
}

# Public Methods

func lookup(name: String):
	if registry.has(name):
		return registry[name]
	else:
		return ""
