extends Node3D
@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar

const PORT = 9999
const PLAYER = preload("uid://d3wto0ff44dow")

var enet_peer = ENetMultiplayerPeer.new() #Create a new multiplayer peer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"): #QOL quit by pressing esc
		get_tree().quit()


func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_server(PORT) #Establish the server on the passed in PORT
	multiplayer.multiplayer_peer = enet_peer 
	multiplayer.peer_connected.connect(add_player) #Connect the signal of when someone connects to add a new player to the scene
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	#upnp_setup()


func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	enet_peer.create_client("localhost",PORT)
	multiplayer.multiplayer_peer = enet_peer
	

func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
		
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)

#func upnp_setup(): Deprecated Service for online play (won't be necessary)
	#var upnp = UPNP.new()
	#
	#var discover_result = upnp.discover() #Find UPNP device
	#assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
	#"UPNP Discover Failed! Error %s" % discover_result) #Throw error if UPNP discovery fails
	#
	#assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		#"UPNP Invalid Gateway!") #Make sure that the gateway is valid
		#
	#var map_result = upnp.add_port_mapping(PORT)
	#assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		#"UPNP Port Mapping Failed! Error %s" % map_result) #Potential Error if Port mapping fails
		#
	#print("Success! Join Address: %s" % upnp.query_external_address())
	#
		#
