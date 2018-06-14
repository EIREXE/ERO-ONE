extends CanvasLayer

onready var progress_bar = get_node("LoadingScreen/ProgressBar")

func hide():
	$LoadingScreen.hide()

func show():
	$LoadingScreen.show()
	
func set_progress(progress):
	progress_bar.value = progress