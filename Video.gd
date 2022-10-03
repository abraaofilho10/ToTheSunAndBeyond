extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _stop_video() -> void:
	$AspectRatioContainer/VideoPlayer.stop()
	$btnPlay.visible = true

func _play_video() -> void:
	$AspectRatioContainer/VideoPlayer.play()
	$btnPlay.visible = false

func _on_RichTextLabel_meta_clicked(p_meta):
	OS.shell_open(str(p_meta))


func _on_Button_button_up():
	_play_video()


func _on_VideoPlayer_finished():
	$btnPlay.visible = true


func _on_btnPause_button_up():
	if $AspectRatioContainer/VideoPlayer.is_playing():
		_stop_video()
	else:
		_play_video()
