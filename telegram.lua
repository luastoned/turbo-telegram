local telegram = {
	_VERSION		= "v1.2.0",
	_DESCRIPTION	= "Telegram Bot API for Turbo.lua",
	_URL			= "https://github.com/luastoned/turbo-telegram",
	_LICENSE		= [[Copyright (c) 2016 @LuaStoned]],
}

-- Always set me when using SSL, before loading framework.
TURBO_SSL = true
local turbo = require("turbo")
local multipart = require("multipart")

-- Argument Check
local prevFunc, prevLine, curArg = "", 0, 0
local function requireArg(arg, expected)
	local info = debug.getinfo(2)
	if (prevLine >= info.currentline or prevFunc ~= info.name) then
		curArg = 0
	end
	
	curArg = curArg  + 1
	prevFunc = info.name
	prevLine = info.currentline
	assert(type(arg) == expected, string.format("bad argument #%d to '%s' (%s expected, got %s)", curArg, info.name, expected, type(arg)))
end

-- https://core.telegram.org/bots/api
function telegram:request(path, request, multi)
	assert(self.token, "Please use createBot(<token>) first.")
	local options = {
		method = "POST",
		params = request,
	}
	
	request = request or {}
	if (multi and next(request)) then
		local body, boundary = multipart.encode(request)
		options.body = body
		options.params = nil
		options.on_headers = function(headers)
			headers:add("Content-Type", "multipart/form-data; boundary=" .. boundary)
		end
	end
	
	local url = string.format("https://api.telegram.org/bot%s/%s", self.token, path)
	local res = coroutine.yield(turbo.async.HTTPClient():fetch(url, options))
	if (res.error) then
		error(res.error)
	end
	
	local json = turbo.escape.json_decode(res.body)
	if (not json.ok) then
		print(json.description)
		return
	end
	
	return json.result
end

-- Getting updates

function telegram:getUpdates(options)
	options = options or {}
	return self:request("getUpdates", options)
end

function telegram:setWebhook(url)
	requireArg(url, "string")
	return self:request("setWebhook", {url = url})
end

-- Available methods

function telegram:getMe()
	return self:request("getMe")
end

function telegram:sendMessage(chat_id, text, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(text, "string")

	options = options or {}
	options.text = text
	options.chat_id = chat_id
	
	return self:request("sendMessage", options)
end

function telegram:forwardMessage(chat_id, from_chat_id, message_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(from_chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(message_id, "number")
	
	return self:request("forwardMessage", {chat_id = chat_id, from_chat_id = from_chat_id, message_id = message_id})
end

function telegram:sendPhoto(chat_id, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(options, "table")
	
	local multipart = false
	options.chat_id = chat_id
	if (options.file_id) then
		options.photo = options.file_id
	else
		multipart = true
		options.photo = {
			filename = options.filename or "moon.jpg",
			data = options.photo,
		}
	end
	
	return self:request("sendPhoto", options, multipart)
end

function telegram:sendAudio(chat_id, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(options, "table")
	
	local multipart = false
	options.chat_id = chat_id
	if (options.file_id) then
		options.audio = options.file_id
	else
		multipart = true
		options.audio = {
			filename = options.filename or "moon.ogg", -- OPUS
			data = options.audio,
		}
	end
	
	return self:request("sendAudio", options, multipart)
end

function telegram:sendDocument(chat_id, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(options, "table")
	
	local multipart = false
	options.chat_id = chat_id
	if (options.file_id) then
		options.document = options.file_id
	else
		multipart = true
		options.document = {
			filename = options.filename or "moon.txt",
			data = options.document,
		}
	end
	
	return self:request("sendDocument", options, multipart)
end

function telegram:sendSticker(chat_id, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(options, "table")
	
	local multipart = false
	options.chat_id = chat_id
	if (options.file_id) then
		options.sticker = options.file_id
	else
		multipart = true
		options.sticker = {
			filename = options.filename or "moon.webp",
			data = options.sticker,
		}
	end
	
	return self:request("sendSticker", options, multipart)
end

function telegram:sendVideo(chat_id, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(options, "table")
	
	local multipart = false
	options.chat_id = chat_id
	if (options.file_id) then
		options.video = options.file_id
	else
		multipart = true
		options.video = {
			filename = options.filename or "moon.mp4",
			data = options.video,
		}
	end
	
	return self:request("sendVideo", options, multipart)
end

function telegram:sendVoice(chat_id, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(options, "table")
	
	local multipart = false
	options.chat_id = chat_id
	if (options.file_id) then
		options.voice = options.file_id
	else
		multipart = true
		options.voice = {
			filename = options.filename or "moon.ogg",
			data = options.voice,
		}
	end
	
	return self:request("sendVoice", options, multipart)
end

function telegram:sendLocation(chat_id, latitude, longitude, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(latitude, "number")
	requireArg(longitude, "number")
	
	options = options or {}
	options.chat_id = chat_id
	options.latitude = latitude
	options.longitude = longitude
	
	return self:request("sendLocation", options)
end

function telegram:sendVenue(chat_id, latitude, longitude, title, address, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(latitude, "number")
	requireArg(longitude, "number")
	requireArg(title, "string")
	requireArg(address, "string")
	
	options = options or {}
	options.chat_id = chat_id
	options.latitude = latitude
	options.longitude = longitude
	options.title = title
	options.address = address
	
	return self:request("sendVenue", options)
end

function telegram:sendContact(chat_id, phone_number, first_name, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(phone_number, "string")
	requireArg(first_name, "string")
	
	options = options or {}
	options.chat_id = chat_id
	options.phone_number = phone_number
	options.first_name = first_name
	
	return self:request("sendContact", options)
end

function telegram:sendChatAction(chat_id, action)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(action, "string")
	
	-- typing for text messages
	-- upload_photo for photos
	-- record_video or upload_video for videos
	-- record_audio or upload_audio for audio files
	-- upload_document for general files
	-- find_location for location data
	return self:request("sendChatAction", {chat_id = chat_id, action = action})
end

function telegram:getUserProfilePhotos(user_id, options)
	requireArg(user_id, "number") -- TODO: chat_id can be number or string
	
	options = options or {}
	options.user_id = user_id
	
	return self:request("getUserProfilePhotos", options)
end

-- https://api.telegram.org/file/bot<token>/<file_path>
function telegram:getFile(file_id)
	requireArg(file_id, "number")
	return self:request("getFile", {file_id = file_id})
end

function telegram:kickChatMember(chat_id, user_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(user_id, "number")
	
	return self:request("kickChatMember", {chat_id = chat_id, user_id = user_id})
end

function telegram:leaveChat(chat_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	
	return self:request("leaveChat", {chat_id = chat_id})
end

function telegram:unbanChatMember(chat_id, user_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(user_id, "number")
	
	return self:request("unbanChatMember", {chat_id = chat_id, user_id = user_id})
end

function telegram:getChat(chat_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	
	return self:request("getChat", {chat_id = chat_id})
end

function telegram:getChatAdministrators(chat_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	
	return self:request("getChatAdministrators", {chat_id = chat_id})
end

function telegram:getChatMembersCount(chat_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	
	return self:request("getChatMembersCount", {chat_id = chat_id})
end

function telegram:getChatMember(chat_id, user_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(user_id, "number")
	
	return self:request("getChatMember", {chat_id = chat_id, user_id = user_id})
end

function telegram:answerCallbackQuery(callback_query_id 	, options)
	requireArg(callback_query_id, "string")
	
	options = options or {}
	options.callback_query_id = callback_query_id
	
	return self:request("answerCallbackQuery", options)
end

-- Updating messages

function telegram:editMessageText(text, options)
	-- (chat_id and message_id) or inline_message_id
	requireArg(text, "string")

	options = options or {}
	options.text = text
	
	return self:request("editMessageText", options)
end

function telegram:editMessageCaption(caption, options)
	-- (chat_id and message_id) or inline_message_id
	requireArg(caption, "string")

	options = options or {}
	options.caption = caption
	
	return self:request("editMessageCaption", options)
end

function telegram:editMessageReplyMarkup(reply_markup, options)
	-- (chat_id and message_id) or inline_message_id
	requireArg(reply_markup, "string")

	options = options or {}
	options.reply_markup = reply_markup
	
	return self:request("editMessageReplyMarkup", options)
end

-- Inline mode

function telegram:answerInlineQuery(inline_query_id, results, options)
	requireArg(inline_query_id, "string")
	requireArg(results, "table")

	options = options or {}
	options.inline_query_id = inline_query_id
	options.results = turbo.escape.json_encode(results)
	
	return self:request("answerInlineQuery", options)
end

-- Create Bot

function telegram.createBot(token)
	requireArg(token, "string")
	local bot = {token = token}
	setmetatable(bot, {__index = telegram})
	return bot
end

return telegram
