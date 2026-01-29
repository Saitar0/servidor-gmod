local category = "sadmin"

mLogs.addCategory(
	"sAdmin",
	category,
	sAdmin.config["chat_prefix"][1],
	function()
		return true
	end
)

mLogs.addCategoryDefinitions(category, {
	sacommand = function(data) return mLogs.doLogReplace({"^ply", slib.getLang("sadmin", sAdmin.config["language"], "ran_command"),"^cmd", slib.getLang("sadmin", sAdmin.config["language"], "with_args").." [","^args", "]"}, data) end,
	sabanedit = function(data) return mLogs.doLogReplace({"^ply", slib.getLang("sadmin", sAdmin.config["language"], "has_edited"),"^target", slib.getLang("sadmin", sAdmin.config["language"], "his_ban_new_time"),"^new_time", slib.getLang("sadmin", sAdmin.config["language"], "with_reason"), "^new_reason"}, data) end,
})