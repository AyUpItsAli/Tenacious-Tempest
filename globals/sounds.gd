extends Node

func play(sound: String, interupt: bool = false):
	if not has_node(sound): return
	var audio_stream: AudioStreamPlayer = get_node(sound)
	if not audio_stream.playing or interupt:
		audio_stream.play()

func stop(sound: String):
	if not has_node(sound): return
	var audio_stream: AudioStreamPlayer = get_node(sound)
	audio_stream.stop()
