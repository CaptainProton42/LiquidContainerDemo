extends Spatial

func _ready():
	var VR = ARVRServer.find_interface("OpenVR")
	if VR and VR.initialize():
		pass

# Higher resolution spectator camera
func _process(delta):
	get_node("Camera").global_transform = get_node("Viewport/ARVROrigin/PlayerCamera").global_transform
