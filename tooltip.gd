extends Control

@onready var tooltipText = $Panel/Label
@onready var panel = $Panel

func set_text(tip: String):
	tooltipText.text = tip # Sets text
	#tooltipText.size = tooltipText.get_minimum_size() # Resize label to fit the text properly
	panel.size = tooltipText.size + Vector2(10,10) # Dynamically scale the background panel
	size = panel.size # Set the overall size of the tooltip control to match the panel

func show_tooltip(text: String):
	set_text(text) # Sets the text
	#global_position = position # Move tooltip to appear near the cursor
	show() # Make visible
	
func hide_tooltip():
	hide()
