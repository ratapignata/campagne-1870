extends ScrollContainer
# Explicit touch scrolling also works when a desktop test runner has no touch hardware.
# Keep native wheel/scrollbar input, but suppress duplicate emulated mouse drags.
var finger=-1
var travel=0.0
var moving=false
func _ready():
	scroll_deadzone=1000000
func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed and finger<0:finger=event.index;travel=0;moving=false
		elif not event.pressed and event.index==finger:finger=-1
	elif event is InputEventScreenDrag and event.index==finger:
		travel+=event.relative.y
		if absf(travel)>6:moving=true
		if moving:scroll_vertical-=roundi(event.relative.y);accept_event()
