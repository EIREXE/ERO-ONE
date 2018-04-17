extends CanvasLayer

onready var progress_bar = get_node("Control/ProgressBar")

func hide():
	$Control.hide()

func show():
	$Control.show()
	
func set_progress(progress):
	progress_bar.value = progress