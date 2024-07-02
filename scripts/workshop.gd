extends Node

var appId = 0

const LVLS_PER_PAGE = 10.0
const STEAM_LVLS_PER_PAGE = 50.0

var is_initialized :bool= false

var user_id : int

var current_item_id
var current_file_id
var current_ugc_query_handler_id:int=-1
var current_loading_level_id:int=-1

func _ready():
	'''
	Steam.connect("steamworks_error", self, "_log_error", [], CONNECT_PERSIST)
	Steam.connect("current_stats_received", self, "_steam_Stats_Ready", [], CONNECT_PERSIST)
	Steam.connect("item_created", self, "_on_item_created", [], CONNECT_PERSIST)
	Steam.connect("item_updated", self, "_on_item_updated", [], CONNECT_PERSIST)
	Steam.connect("ugc_query_completed", self, "_on_ugc_query_completed", [], CONNECT_PERSIST)
	Steam.connect("item_downloaded", self, "_on_item_downloaded", [], CONNECT_PERSIST)
	'''
	Steam.steamworks_error.connect(_log_error, CONNECT_PERSIST)
	Steam.current_stats_received.connect(_steam_Stats_Ready, CONNECT_PERSIST)
	Steam.item_created.connect(_on_item_created, CONNECT_PERSIST)
	Steam.item_updated.connect(_on_item_updated, CONNECT_PERSIST)
	Steam.ugc_query_completed.connect(_on_ugc_query_completed, CONNECT_PERSIST)
	Steam.item_downloaded.connect(_on_item_downloaded, CONNECT_PERSIST)

func _log_error(err_signal:String, err_msg:String):
	print_debug("Error with signal: %s" % err_signal)
	print_debug(err_msg)

func checkSteam() -> bool:
	if !Steam.isSteamRunning():
		print_debug("Steam is not running")
		return false
	if !Steam.isSubscribed():
		print_debug("Not subscribed / Ownership is not confirmed")
		return false
	return true

func _steam_Stats_Ready(game: int, result: int, user: int) -> void:
	
	appId = game
	is_initialized = true

func get_workshop_levels(page :int= 1, filters :Array= []):
	if current_ugc_query_handler_id > 0:
		# There is already a query in the works, so will just release its handler because we need the new one to work its way.
		Steam.releaseQueryUGCRequest(current_ugc_query_handler_id)
	# This is a quick way to convert YOUR pages into STEAM pages. Steam SDK does not allow you to specify the number of items per page, it always returns up to 50 results. Here, LVLS_PER_PAGE = 10 and STEAM_LVLS_PER_PAGE = 50.
	var steam_page = ceil(page * LVLS_PER_PAGE / STEAM_LVLS_PER_PAGE)
	# Creating a query with type 0 - ordered by upvotes for all time.
	current_ugc_query_handler_id = Steam.createQueryAllUGCRequest(0, 0, appId, appId, steam_page)
	# Add filters. In my case, I am exluding tags. filters is just an array of strings.
	for filter in filters:
		Steam.addExcludedTag(current_ugc_query_handler_id, filter)
	# Reduce the number of server calls by relying on local cache (managed by SteamSDK)
	Steam.setAllowCachedResponse(current_ugc_query_handler_id, 30)
	# Finally, send the query
	Steam.sendQueryUGCRequest(current_ugc_query_handler_id)

func download_level(lvl_id):
	if current_loading_level_id==lvl_id:
		# This means that we are already downloading this item. Probably just a second click on a button.
		return false
	elif current_loading_level_id>0 and current_loading_level_id!=lvl_id:
		# We are already downloading another level. I allow this situations to happen but you might decide otherwise.
		pass
	# This function return bool, true if download request was successfully sent
	if Steam.downloadItem(lvl_id, false):
		current_loading_level_id = lvl_id
		# Here you can block user input to prevent send clicks a launch loading animation.

func upload_level(lvl_id):
	current_item_id = lvl_id
	Steam.createItem(appId, 0)

func upvote_level(file_id:int):
	if !checkSteam():
		return false
	Steam.setUserItemVote(file_id, true)


func downvote_level(file_id:int):
	if !checkSteam():
		return false
	Steam.setUserItemVote(file_id, false)


func open_item_page(file_id):
	Steam.activateGameOverlayToWebPage("steam://url/CommunityFilePage/%s" % str(file_id))


func _on_item_created(result: int, file_id: int, accept_tos: bool):
	var handler_id = Steam.startItemUpdate(appId, file_id)
	var lvl_id = current_item_id
	var lvl_path = "ABSOLUTE-PATH-TO-ITEM-FOLDER"
	# Access metadata file and read the level title and tags from it
	var metadata:ConfigFile=ConfigFile.new()
	metadata.load("PATH-TO-METADATA-FILE")
	var lvl_title = metadata.get_value("main", "title", "")
	var lvl_tags = []
	# Saving file_id into the metadata file so I can update this item later if needed
	metadata.set_value("steam", "file_id", file_id)
	metadata.save("PATH-TO-METADATA-FILE")
	for tag in ["LIST", "OF", "YOUR", "TAGS"]:
		if metadata.get_value("main", tag, false):
			lvl_tags.append(tag)
	# Setting UGC item title - it will appear in the workshop
	Steam.setItemTitle(handler_id, lvl_title)
	# Setting the path to directory containing the item files
	Steam.setItemContent(handler_id, lvl_path)
	# Setting UGC item tags - they will be visible in the workshop
	Steam.setItemTags(handler_id, lvl_tags)
	# Attaching a preview file is an optional step. The preview file is just a .png image. For example, you can take a screenshot in Godot and save it as file.
	Steam.setItemPreview(handler_id, "ABSOLUTE-PATH-TO-PREVIEW-FILE.PNG")
	# Making item visible in the workshop
	Steam.setItemVisibility(handler_id, 0)
	# Adding workshop metadata that is not visible via web interface. For example, I store the version of the editor.
	Steam.setItemMetadata(handler_id, "OPTIONAL METADATA STRING")
	# Submit item update - Steam will now upload the data
	Steam.submitItemUpdate(handler_id, "CHANGE NOTE")
	current_item_id = null
	current_file_id = file_id
	# You will need this file_id if you wish to monitor the progress


func _on_item_updated(result: int, accept_tos):
	var item_page_template = "steam://url/CommunityFilePage/%s"
	if accept_tos:
		Steam.activateGameOverlayToWebPage(item_page_template % str(current_file_id))


func _on_ugc_query_completed(handle:int, result:int, results_returned:int, total_matching:int, cached:bool):
	# If the current handler id changed - it means that we requested a list of items again, so we can dismiss these results. 
	if handle != current_ugc_query_handler_id:
		Steam.releaseQueryUGCRequest(handle)
		return
	if result != 1:
		# The query failed. See steam result codes for possible reasons.
		return
	var list_of_results = []
	for item_id in range(results_returned):
		# Get information for each item and (optional) metadata
		var item = Steam.getQueryUGCResult(handle, item_id)
		var md = Steam.getQueryUGCMetadata(handle, item_id)
		item["metadata"] = md
		list_of_results.append(item)
	# Release the query handle to free memory
	Steam.releaseQueryUGCRequest(handle)
	current_ugc_query_handler_id = 0
	# Now we can show the list of results to the player


func _on_item_downloaded(result, file_id, app_id):
	if result != 1:
		# See steam result codes for more details
		print_debug("Download failed %d" % result)
	if file_id != current_loading_level_id:
		# We are expecting another file to download, so we will just skip this one. You can of course allow multiple parallel downloads in you game, if you wish.
		return
	# Getting the information about the downloaded item
	var lvl_info = Steam.getItemInstallInfo(file_id)
	# lvl_info["folder"] will contain a folder with item files
	# In my case, these are level.tscn and level.data
	# Reset the global variable to allow new downloads to happen
	current_loading_level_id = -1
	# You can stop tracking for all items just in case there is still an item in use
	Steam.stopPlaytimeTrackingForAllItems()
	# Start tracking playtime for the downloaded item
	Steam.startPlaytimeTracking([file_id])
	# Lauch the downloaded level
	
	'''
	SomeFunctionToLauchTheLevel(lvl_info["folder"])
	'''
