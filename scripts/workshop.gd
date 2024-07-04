extends Node


const LVLS_PER_PAGE = 10.0
const STEAM_LVLS_PER_PAGE = 50.0

var is_initialized :bool= false

var user_id : int

#region update
var current_file_id 

var mod_path:String = ""
var meta_file:String = ""
var preview_file:String = ""

var meta_data:ConfigFile = null
#endregion

var current_ugc_query_handler_id:int=-1
var current_loading_mod_id:int=-1

func activate():
	Steam.steamworks_error.connect(_log_error, CONNECT_PERSIST)
	Steam.current_stats_received.connect(_steam_stats_ready, CONNECT_PERSIST)
	Steam.item_created.connect(_on_item_created, CONNECT_PERSIST)
	Steam.item_updated.connect(_on_item_updated, CONNECT_PERSIST)
	Steam.ugc_query_completed.connect(_on_ugc_query_completed, CONNECT_PERSIST)
	Steam.item_downloaded.connect(_on_item_downloaded, CONNECT_PERSIST)
	get_installed_mod_paths()


#region Mod Management

func upload_mod(mod_folder:String):
	# set up path structure
	mod_folder = mod_folder.strip_edges().replace("\\", "/")
	if not DirAccess.dir_exists_absolute(mod_folder):
		UIConsole.instance.print_to_console("Directory does not exist: %s"%mod_folder)
		return
	if not mod_folder.ends_with("/"):
		mod_folder=mod_folder+"/"
	mod_path = mod_folder
	meta_file = mod_path+"meta.cfg"
	preview_file = mod_path+"preview.png"
	
	# Set up meta data
	meta_data=ConfigFile.new()
	meta_data.load(meta_file)
	var mod_id = meta_data.get_value("steam", "id", 0)
	if mod_id == 0:
		register_mod()
	else:
		UIConsole.instance.print_to_console("Updating existing mod. id: %s"%str(mod_id))
		update_mod(mod_id)

func update_mod(file_id:int):
	var handler_id = Steam.startItemUpdate(Global.steam_app_id, file_id)
	var mod_title = meta_data.get_value("puggos_world", "title", "A Puggo Mod")
	var mod_tags = []
	# Saving file_id into the metadata file so I can update this item later if needed
	meta_data.set_value("steam", "id", file_id)
	meta_data.save(meta_file)

	# Setting UGC item title - it will appear in the workshop
	Steam.setItemTitle(handler_id, mod_title)
	#Steam.setItemDescription(handler_id, "")
	# Setting the path to directory containing the item files
	Steam.setItemContent(handler_id, mod_path)	
	# Setting UGC item tags - they will be visible in the workshop	
	Steam.setItemTags(handler_id, mod_tags)
	# Attaching a preview file is an optional step. The preview file is just a .png image. For example, you can take a screenshot in Godot and save it as file.
	Steam.setItemPreview(handler_id, preview_file)
	# Making item visible in the workshop
	Steam.setItemVisibility(handler_id, 0)
	# Adding workshop metadata that is not visible via web interface. For example, I store the version of the editor.
	Steam.setItemMetadata(handler_id, "Love pugs.")
	# Submit item update - Steam will now upload the data
	Steam.submitItemUpdate(handler_id, "A Puggo mod is born.")
	
	var console_report_info:={"id":file_id, "title":mod_title, "path":mod_path}
	UIConsole.instance.print_to_console("Uploaded mod id: {id} - {title}, at {path}".format(console_report_info))
	
## 1 Create a NEW mod.
func register_mod():
	UIConsole.instance.print_to_console("Registering new mod...")
	Steam.createItem(Global.steam_app_id, 0)

## 2 Update an existing record.
func _on_item_created(result: int, file_id: int, accept_tos: bool):
	update_mod(file_id)	
	reset()
	
## 3 Update complete. 
func _on_item_updated(result: int, accept_tos):
	var item_page_template = "steam://url/CommunityFilePage/%s"
	if accept_tos:
		Steam.activateGameOverlayToWebPage(item_page_template % str(current_file_id))

func reset():
	current_file_id = 0

	mod_path= ""
	meta_file = ""
	preview_file = ""
	meta_data = null

#endregion

#region Subscriptions

## Gets a list of mods user is SUBSCRIBED to
func get_subscribed_mods():	
	return Steam.getSubscribedItems()

## Gets the paths to user INSTALLED mods
func get_installed_mod_paths():	
	var paths:Array = []
	var mods:Array = get_subscribed_mods()
	for mod in mods:
		var info:Dictionary = Steam.getItemInstallInfo(mod)
		paths.append(info["folder"])
	return paths

## Starts a query for mod info based on mod_ids.
func get_mod_info(item_ids:Array):
	if current_ugc_query_handler_id > 0:
		# There is already a query in the works, so will just release its handler because we need the new one to work its way.
		Steam.releaseQueryUGCRequest(current_ugc_query_handler_id)
	# Creating a query with type 0 - ordered by upvotes for all time.
	current_ugc_query_handler_id = Steam.createQueryUGCDetailsRequest(item_ids)
	Steam.setAllowCachedResponse(current_ugc_query_handler_id, 30)
	# Finally, send the query
	Steam.sendQueryUGCRequest(current_ugc_query_handler_id)
#endregion

func _log_error(err_signal:String, err_msg:String):
	print_debug("Error with signal: %s" % err_signal)
	print_debug(err_msg)

func _steam_stats_ready(game: int, result: int, user: int) -> void:
	is_initialized = true

func get_workshop_mods(page :int= 1, filters :Array= []):
	if current_ugc_query_handler_id > 0:
		# There is already a query in the works, so will just release its handler because we need the new one to work its way.
		Steam.releaseQueryUGCRequest(current_ugc_query_handler_id)
	# This is a quick way to convert YOUR pages into STEAM pages. Steam SDK does not allow you to specify the number of items per page, it always returns up to 50 results. Here, LVLS_PER_PAGE = 10 and STEAM_LVLS_PER_PAGE = 50.
	var steam_page = ceil(page * LVLS_PER_PAGE / STEAM_LVLS_PER_PAGE)
	# Creating a query with type 0 - ordered by upvotes for all time.
	current_ugc_query_handler_id = Steam.createQueryAllUGCRequest(0, 0, Global.steam_app_id, Global.steam_app_id, steam_page)
	# Add filters. In my case, I am exluding tags. filters is just an array of strings.
	for filter in filters:
		Steam.addExcludedTag(current_ugc_query_handler_id, filter)
	# Reduce the number of server calls by relying on local cache (managed by SteamSDK)
	Steam.setAllowCachedResponse(current_ugc_query_handler_id, 30)
	# Finally, send the query
	Steam.sendQueryUGCRequest(current_ugc_query_handler_id)

func download_mod(mod_id):
	if current_loading_mod_id==mod_id:
		# This means that we are already downloading this item. Probably just a second click on a button.
		return false
	elif current_loading_mod_id>0 and current_loading_mod_id!=mod_id:
		# We are already downloading another level. I allow this situations to happen but you might decide otherwise.
		pass
	# This function return bool, true if download request was successfully sent
	if Steam.downloadItem(mod_id, false):
		current_loading_mod_id = mod_id
		# Here you can block user input to prevent send clicks a launch loading animation.


func upvote_mod(file_id:int):
	if !Global.check_steam():
		return false
	Steam.setUserItemVote(file_id, true)


func downvote_mod(file_id:int):
	if !Global.check_steam():
		return false
	Steam.setUserItemVote(file_id, false)


func open_item_page(file_id):
	Steam.activateGameOverlayToWebPage("steam://url/CommunityFilePage/%s" % str(file_id))


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
	process_mod_list_results(list_of_results)

func process_mod_list_results(list_of_results:Array):
	print(list_of_results)

func _on_item_downloaded(result, file_id, app_id):
	if result != 1:
		# See steam result codes for more details
		print_debug("Download failed %d" % result)
	if file_id != current_loading_mod_id:
		# We are expecting another file to download, so we will just skip this one. You can of course allow multiple parallel downloads in you game, if you wish.
		return
	# Getting the information about the downloaded item
	var lvl_info = Steam.getItemInstallInfo(file_id)
	# lvl_info["folder"] will contain a folder with item files
	# In my case, these are level.tscn and level.data
	# Reset the global variable to allow new downloads to happen
	current_loading_mod_id = -1
	# You can stop tracking for all items just in case there is still an item in use
	Steam.stopPlaytimeTrackingForAllItems()
	# Start tracking playtime for the downloaded item
	Steam.startPlaytimeTracking([file_id])
	# Lauch the downloaded level
	
	'''
	SomeFunctionToLauchTheLevel(lvl_info["folder"])
	'''
