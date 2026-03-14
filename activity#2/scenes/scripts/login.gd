extends Control
class_name NakamaMultiplayer


# =========================================================
# VARIABLES
# =========================================================
var session : NakamaSession
var client : NakamaClient
var socket : NakamaSocket

var match_id : String
var multiplayerBridge

static var players = {}


# =========================================================
# SIGNALS
# =========================================================
signal startGame()


# =========================================================
# ENUMS
# =========================================================
enum SocketState { OPEN, CLOSE, ERROR }


# =========================================================
# GODOT LIFECYCLE
# =========================================================
func _ready():
	pass


func _process(delta: float):
	pass


# =========================================================
# USER ACCOUNT
# =========================================================
func updateUserInfo(username, displayname, avatarurl = "", language = "en", location = "ph", timezone = "gmt"):
	await client.update_account_async(session, username, displayname, avatarurl, language, location, timezone)


# =========================================================
# SOCKET EVENTS
# =========================================================
func onSocketConnected():
	onSocketStatus(SocketState.OPEN)


func onSocketClosed():
	onSocketStatus(SocketState.CLOSE)


func onSocketError(err):
	onSocketStatus(SocketState.ERROR)


func onSocketStatus(state: SocketState):
	match state:
		SocketState.OPEN:
			print("Connected")
		SocketState.CLOSE:
			print("Closed")
		SocketState.ERROR:
			print("Error")


# =========================================================
# MATCH EVENTS
# =========================================================
func onMatchPresence(presence: NakamaRTAPI.MatchPresenceEvent):
	print(presence)


func onMatchState(state: NakamaRTAPI.MatchData):
	print(state)


func onMatchJoin():
	print("Matach Joined (id): " + multiplayerBridge.match_id)


func onMatchJoinError(err):
	print("Unable to Join Match: " + err.message)


# =========================================================
# LOGIN
# =========================================================
func _on_login_button_button_down():
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")

	session = await client.authenticate_email_async(
		$Panel2/EmailInput.text,
		$Panel2/PasswordInput.text
	)

	# Using Device to log in
	# var deviceId = OS.get_unique_id()
	# session = await client.authenticate_device_async(deviceId)

	if session == null:
		print("Authentication failed")
		return

	socket = Nakama.create_socket_from(client)
	await socket.connect_async(session)

	socket.connected.connect(onSocketConnected)
	socket.closed.connect(onSocketClosed)
	socket.received_error.connect(onSocketError)

	socket.received_match_presence.connect(onMatchPresence)
	socket.received_match_state.connect(onMatchState)

	var account = await client.get_account_async(session)

	$Panel/UsernameLabel.text = account.user.username
	$Panel/DisplaynameUsernameLabel.text = account.user.display_name

	setupMultiplayerBridge()


# =========================================================
# MULTIPLAYER BRIDGE SETUP
# =========================================================
func setupMultiplayerBridge():
	multiplayerBridge = NakamaMultiplayerBridge.new(socket)

	multiplayerBridge.match_joined.connect(onMatchJoin)
	multiplayerBridge.match_join_error.connect(onMatchJoinError)

	get_tree().get_multiplayer().set_multiplayer_peer(multiplayerBridge.multiplayer_peer)
	get_tree().get_multiplayer().peer_connected.connect(onPeerConnect)
	get_tree().get_multiplayer().peer_disconnected.connect(onPeerDisconnect)


# =========================================================
# PEER CONNECTION EVENTS
# =========================================================
func onPeerConnect(id):
	print("Connected to id: " + str(id))

	if !players.has(id):
		players[id] = {
			"name": id,
			"ready": 0,
		}

	if !players.has(multiplayer.get_unique_id()):
		players[multiplayer.get_unique_id()] = {
			"name": multiplayer.get_unique_id(),
			"ready": 0,
		}


func onPeerDisconnect(id):
	print("Disconnected to id: " + str(id))


# =========================================================
# STORAGE (SAVE DATA)
# =========================================================
func _on_store_data_button_down():

	var game_data = {
		"name": "username",
		"level": 1,
		"experience": 0.0,
		"items": [
			{
				"id": 1,
				"name": "Wood",
				"amount": 10,
			},
			{
				"id": 2,
				"name": "Apple",
				"amount": 8,
			},
		]
	}

	var data = JSON.stringify(game_data)

	var result = await client.write_storage_objects_async(
		session,
		[
			NakamaWriteStorageObject.new("saves", "save_game", 1, 1, data, "")
		]
	)

	if result.is_exception():
		print("args" + str(result))
		return

	print("Data Stored Successfully!!!")


func _on_retreive_data_button_down():

	var result = await client.read_storage_objects_async(
		session,
		[
			NakamaStorageObjectId.new("saves", "save_game", session.user_id)
		]
	)

	if result.is_exception():
		print("args" + str(result))
		return

	for i in result.objects:
		print(i)


# =========================================================
# MATCHMAKING
# =========================================================
func _on_join_create_btn_button_down():

	if multiplayerBridge.match_id != "":
		print("Already in a match")
		return

	multiplayerBridge.join_named_match($Panel4/MatchNameInput.text)

	# var createMatch = await socket.create_match_async($Panel4/MatchNameInput.text)
	#
	# if createMatch == null:
	# 	print("Failed to Create Match :(")
	# 	return
	#
	# match_id = createMatch.match_id
	# print("Match ID: " + match_id)


# =========================================================
# NETWORK TEST (PING)
# =========================================================
func _on_ping_btn_button_down():
	sendData.rpc("Hello World")

	# if match_id == "":
	# 	print("No match joined")
	# 	return
	#
	# var data = {"Hello": "World"}
	# socket.send_match_state_async(match_id, 1, JSON.stringify(data))


@rpc("any_peer")
func sendData(message):
	print(message)


# =========================================================
# READY SYSTEM
# =========================================================
func _on_start_btn_button_down():
	Ready.rpc(multiplayer.get_unique_id())


@rpc("any_peer", "call_local")
func Ready(id):

	if !players.has(id):
		players[id] = {
			"name": id,
			"ready": 0,
		}

	players[id]["ready"] = 1

	if multiplayer.is_server():

		var readyPlayers = 0

		for i in players:
			if players[i]["ready"] == 1:
				readyPlayers += 1

		if readyPlayers == players.size():
			StartGame.rpc()


# =========================================================
# START GAME
# =========================================================
@rpc("any_peer", "call_local")
func StartGame():
	startGame.emit()
	hide()
