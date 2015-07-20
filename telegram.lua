local telegram = {
	_VERSION		= "v1.0.0",
	_DESCRIPTION	= "Telegram Bot for Turbo.lua",
	_URL			= "https://github.com/luastoned/turbo-telegram",
	_LICENSE		= [[Copyright (c) 2015 @LuaStoned]],
	
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
		table.print(res.error)
		return
	end
	
	local json = turbo.escape.json_decode(res.body)
	if (not json.ok) then
		print(json.description)
		return
	end
	
	return json.result
end

local function getMe()
	return request("getMe")
end

local function getUpdates(options)
	options = options or {}
	return request("getUpdates", options)
end

local function getUserProfilePhotos(chat_id, options)
	requireArg(chat_id, "number")
	
	options = options or {}
	options.chat_id = chat_id
	
	return request("getUserProfilePhotos", options)
end

local function sendMessage(chat_id, text, options)
	requireArg(chat_id, "number")
	requireArg(text, "string")

	options = options or {}
	options.text = text
	options.chat_id = chat_id
	
	return request("sendMessage", options)
end

local function forwardMessage(chat_id, from_chat_id, message_id)
	requireArg(chat_id, "number")
	requireArg(from_chat_id, "number")
	requireArg(message_id, "number")
	
	return request("forwardMessage", {chat_id = chat_id, from_chat_id = from_chat_id, message_id = message_id})
end

local function sendPhoto(chat_id, options)
	requireArg(chat_id, "number")
	requireArg(options, "table")
	
	options.chat_id = chat_id
	if (options.file_id) then
		options.photo = options.file_id
	else
		options.photo = {
			filename = options.filename or "moon.jpg",
			data = options.photo,
		}
	end
	
	return request("sendPhoto", options)
end

local function sendAudio(chat_id, options)
	requireArg(chat_id, "number")
	requireArg(options, "table")
	
	options.chat_id = chat_id
	if (options.file_id) then
		options.audio = options.file_id
	else
		options.audio = {
			filename = options.filename or "moon.ogg", -- OPUS
			data = options.audio,
		}
	end
	
	return request("sendAudio", options)
end

local function sendDocument(chat_id, options)
	requireArg(chat_id, "number")
	requireArg(options, "table")
	
	options.chat_id = chat_id
	if (options.file_id) then
		options.document = options.file_id
	else
		options.document = {
			filename = options.filename or "moon.txt",
			data = options.document,
		}
	end
	
	return request("sendDocument", options)
end

local function sendSticker(chat_id, options)
	requireArg(chat_id, "number")
	requireArg(options, "table")
	
	options.chat_id = chat_id
	if (options.file_id) then
		options.sticker = options.file_id
	else
		options.sticker = {
			filename = options.filename or "moon.webp",
			data = options.sticker,
		}
	end
	
	return request("sendSticker", options)
end

local function sendVideo(chat_id, options)
	requireArg(chat_id, "number")
	requireArg(options, "table")
	
	options.chat_id = chat_id
	if (options.file_id) then
		options.video = options.file_id
	else
		options.video = {
			filename = options.filename or "moon.mp4",
			data = options.video,
		}
	end
	
	return request("sendVideo", options)
end

local function sendLocation(chat_id, latitude, longitude, options)
	requireArg(chat_id, "number")
	requireArg(latitude, "number")
	requireArg(longitude, "number")
	
	options = options or {}
	options.chat_id = chat_id
	options.latitude = latitude
	options.longitude = longitude
	
	return request("sendLocation", options)
end

local function sendChatAction(chat_id, action)
	requireArg(chat_id, "number")
	requireArg(action, "string")
	
	-- typing for text messages
	-- upload_photo for photos
	-- record_video or upload_video for videos
	-- record_audio or upload_audio for audio files
	-- upload_document for general files
	-- find_location for location data
	return request("sendChatAction", {chat_id = chat_id, action = action})
end

telegram.setBotToken = setBotToken

telegram.getMe = getMe
telegram.getUpdates = getUpdates
telegram.getUserProfilePhotos = getUserProfilePhotos
telegram.setWebhook = nil
telegram.sendMessage = sendMessage
telegram.forwardMessage = forwardMessage
telegram.sendPhoto = sendPhoto
telegram.sendAudio = sendAudio
telegram.sendDocument = sendDocument
telegram.sendSticker = sendSticker
telegram.sendVideo = sendVideo
telegram.sendLocation = sendLocation
telegram.sendChatAction = sendChatAction

-- allow raw debug calls
local meta = {
	__call = function(tbl, ...)
		return request(unpack({...}))
	end
}

setmetatable(telegram, meta)
return telegram