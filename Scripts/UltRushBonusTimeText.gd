extends Label

func setTextAnim(num: float):
	var textVal = str(num)
	$".".text = "+" + textVal
	var tween = create_tween()
	
	# Move upward by 30 pixels over 0.5s
	tween.tween_property(self, "position:y", position.y - 30, 0.5)
	
	# Fade out to transparent over the same 0.5s
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	
	# After tween finishes, remove the node
	tween.finished.connect(queue_free)
