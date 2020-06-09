extends Spatial

func _ready():
	var VR = ARVRServer.find_interface("OpenVR")
	if VR and VR.initialize():
		pass

# Higher resolution spectator camera
func _process(delta):
	get_node("Camera").transform = get_node("Viewport/ARVROrigin/PlayerCamera").transform