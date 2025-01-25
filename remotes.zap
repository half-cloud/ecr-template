opt casing = "snake_case"
opt client_output = "src/client/utils/remotes.luau"
opt server_output = "src/server/utils/remotes.luau"

event test_event = {
	from: Server,
	type: Reliable,
	call: SingleAsync
}
