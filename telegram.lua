local telegram = {
	_VERSION		= "v1.2.0",
	_DESCRIPTION	= "Telegram Bot API for Turbo.lua",
	_URL			= "https://github.com/luastoned/turbo-telegram",
	_LICENSE		= [[Copyright (c) 2016 @LuaStoned]],
	
	botToken		= nil,
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

local function setBotToken(token)
	telegram.botToken = token
end

-- https://core.telegram.org/bots/api
local function request(path, request, multi)
	assert(telegram.botToken, "please set the bot token with setBotToken")
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
	
	local url = string.format("https://api.telegram.org/bot%s/%s", telegram.botToken, path)
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

local function getUpdates(options)
	options = options or {}
	return request("getUpdates", options)
end

local function setWebhook(url)
	requireArg(url, "string")
	return request("setWebhook", {url = url})
end

-- Available methods

local function getMe()
	return request("getMe")
end

local function sendMessage(chat_id, text, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(text, "string")

	options = options or {}
	options.text = text
	options.chat_id = chat_id
	
	return request("sendMessage", options)
end

local function forwardMessage(chat_id, from_chat_id, message_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(from_chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(message_id, "number")
	
	return request("forwardMessage", {chat_id = chat_id, from_chat_id = from_chat_id, message_id = message_id})
end

local function sendPhoto(chat_id, options)
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
	
	return request("sendPhoto", options, multipart)
end

local function sendAudio(chat_id, options)
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
	
	return request("sendAudio", options, multipart)
end

local function sendDocument(chat_id, options)
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
	
	return request("sendDocument", options, multipart)
end

local function sendSticker(chat_id, options)
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
	
	return request("sendSticker", options, multipart)
end

local function sendVideo(chat_id, options)
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
	
	return request("sendVideo", options, multipart)
end

local function sendVoice(chat_id, options)
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
	
	return request("sendVoice", options, multipart)
end

local function sendLocation(chat_id, latitude, longitude, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(latitude, "number")
	requireArg(longitude, "number")
	
	options = options or {}
	options.chat_id = chat_id
	options.latitude = latitude
	options.longitude = longitude
	
	return request("sendLocation", options)
end

local function sendVenue(chat_id, latitude, longitude, title, address, options)
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
	
	return request("sendVenue", options)
end

local function sendContact(chat_id, phone_number, first_name, options)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(phone_number, "string")
	requireArg(first_name, "string")
	
	options = options or {}
	options.chat_id = chat_id
	options.phone_number = phone_number
	options.first_name = first_name
	
	return request("sendContact", options)
end

local function sendChatAction(chat_id, action)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(action, "string")
	
	-- typing for text messages
	-- upload_photo for photos
	-- record_video or upload_video for videos
	-- record_audio or upload_audio for audio files
	-- upload_document for general files
	-- find_location for location data
	return request("sendChatAction", {chat_id = chat_id, action = action})
end

local function getUserProfilePhotos(user_id, options)
	requireArg(user_id, "number") -- TODO: chat_id can be number or string
	
	options = options or {}
	options.user_id = user_id
	
	return request("getUserProfilePhotos", options)
end

-- https://api.telegram.org/file/bot<token>/<file_path>
local function getFile(file_id)
	requireArg(file_id, "number")
	return request("getFile", {file_id = file_id})
end

local function kickChatMember(chat_id, user_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(user_id, "number")
	
	return request("kickChatMember", {chat_id = chat_id, user_id = user_id})
end

local function leaveChat(chat_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	
	return request("leaveChat", {chat_id = chat_id})
end

local function unbanChatMember(chat_id, user_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(user_id, "number")
	
	return request("unbanChatMember", {chat_id = chat_id, user_id = user_id})
end

local function getChat(chat_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	
	return request("getChat", {chat_id = chat_id})
end

local function getChatAdministrators(chat_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	
	return request("getChatAdministrators", {chat_id = chat_id})
end

local function getChatMembersCount(chat_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	
	return request("getChatMembersCount", {chat_id = chat_id})
end

local function getChatMember(chat_id, user_id)
	requireArg(chat_id, "number") -- TODO: chat_id can be number or string
	requireArg(user_id, "number")
	
	return request("getChatMember", {chat_id = chat_id, user_id = user_id})
end

local function answerCallbackQuery(callback_query_id 	, options)
	requireArg(callback_query_id, "string")
	
	options = options or {}
	options.callback_query_id = callback_query_id
	
	return request("answerCallbackQuery", options)
end

-- Updating messages

local function editMessageText(text, options)
	-- (chat_id and message_id) or inline_message_id
	requireArg(text, "string")

	options = options or {}
	options.text = text
	
	return request("editMessageText", options)
end

local function editMessageCaption(caption, options)
	-- (chat_id and message_id) or inline_message_id
	requireArg(caption, "string")

	options = options or {}
	options.caption = caption
	
	return request("editMessageCaption", options)
end

local function editMessageReplyMarkup(reply_markup, options)
	-- (chat_id and message_id) or inline_message_id
	requireArg(reply_markup, "string")

	options = options or {}
	options.reply_markup = reply_markup
	
	return request("editMessageReplyMarkup", options)
end

-- Inline mode

local function answerInlineQuery(inline_query_id, results, options)
	requireArg(inline_query_id, "string")
	requireArg(results, "table")

	options = options or {}
	options.inline_query_id = inline_query_id
	options.results = results
	
	return request("answerInlineQuery", options)
end


-- Internal
telegram.setBotToken = setBotToken

-- Getting updates
telegram.getUpdates = getUpdates
telegram.setWebhook = setWebhook

-- Available methods
telegram.getMe = getMe
telegram.sendMessage = sendMessage
telegram.forwardMessage = forwardMessage
telegram.sendPhoto = sendPhoto
telegram.sendAudio = sendAudio
telegram.sendDocument = sendDocument
telegram.sendSticker = sendSticker
telegram.sendVideo = sendVideo
telegram.sendVoice = sendVoice
telegram.sendLocation = sendLocation
telegram.sendVenue = sendVenue
telegram.sendContact = sendContact
telegram.sendChatAction = sendChatAction
telegram.getUserProfilePhotos = getUserProfilePhotos
telegram.getFile = getFile

-- Updating messages
telegram.editMessageText = editMessageText
telegram.editMessageCaption = editMessageCaption
telegram.editMessageReplyMarkup = editMessageReplyMarkup

-- Inline mode
telegram.answerInlineQuery = answerInlineQuery

-- allow raw debug calls
local meta = {
	__call = function(tbl, ...)
		return request(unpack({...}))
	end
}

setmetatable(telegram, meta)
return telegram