local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("cjson")
local url = require("socket.url")

local TelegramBot = {}

function TelegramBot.new(config)
    local self = {
        token = config.TELEGRAM_BOT_TOKEN,
        chat_id = config.TELEGRAM_CHAT_ID,
        base_url = "https://api.telegram.org/bot" .. config.TELEGRAM_BOT_TOKEN,
        commands = {},
        last_update_id = 0
    }

    function self:send_message(text, reply_markup)
        local endpoint = "/sendMessage"
        local response = {}
        
        local request_data = {
            chat_id = self.chat_id,
            text = text,
            parse_mode = "HTML"
        }

        if reply_markup then
            request_data.reply_markup = json.encode(reply_markup)
        end

        local params = url.buildquery(request_data)
        local _, code = http.request{
            url = self.base_url .. endpoint .. "?" .. params,
            method = "GET",
            sink = ltn12.sink.table(response)
        }

        return code == 200
    end

    function self:send_photo(photo_url, caption)
        local endpoint = "/sendPhoto"
        local response = {}
        
        local params = url.buildquery({
            chat_id = self.chat_id,
            photo = photo_url,
            caption = caption,
            parse_mode = "HTML"
        })

        local _, code = http.request{
            url = self.base_url .. endpoint .. "?" .. params,
            method = "GET",
            sink = ltn12.sink.table(response)
        }

        return code == 200
    end

    function self:register_command(command, description, handler)
        self.commands[command] = {
            description = description,
            handler = handler
        }
    end

    function self:set_commands()
        local endpoint = "/setMyCommands"
        local commands = {}
        
        for cmd, info in pairs(self.commands) do
            table.insert(commands, {
                command = cmd,
                description = info.description
            })
        end

        local response = {}
        local _, code = http.request{
            url = self.base_url .. endpoint,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json"
            },
            source = ltn12.source.string(json.encode({commands = commands})),
            sink = ltn12.sink.table(response)
        }

        return code == 200
    end

    function self:get_updates()
        local endpoint = "/getUpdates"
        local response = {}
        
        local params = url.buildquery({
            offset = self.last_update_id + 1,
            timeout = 30
        })

        local _, code = http.request{
            url = self.base_url .. endpoint .. "?" .. params,
            method = "GET",
            sink = ltn12.sink.table(response)
        }

        if code == 200 then
            local updates = json.decode(table.concat(response))
            if updates and updates.ok and updates.result then
                for _, update in ipairs(updates.result) do
                    if update.update_id > self.last_update_id then
                        self.last_update_id = update.update_id
                    end
                    
                    if update.message and update.message.text then
                        self:handle_message(update.message)
                    end
                end
            end
        end
    end

    function self:handle_message(message)
        local text = message.text
        if text:sub(1, 1) == "/" then
            local command = text:match("^/([%w_]+)")
            if self.commands[command] then
                self.commands[command].handler(message)
            end
        end
    end

    function self:send_keyboard(text, buttons)
        return self:send_message(text, {
            inline_keyboard = buttons
        })
    end

    function self:edit_message(message_id, text, reply_markup)
        local endpoint = "/editMessageText"
        local response = {}
        
        local request_data = {
            chat_id = self.chat_id,
            message_id = message_id,
            text = text,
            parse_mode = "HTML"
        }

        if reply_markup then
            request_data.reply_markup = json.encode(reply_markup)
        end

        local params = url.buildquery(request_data)
        local _, code = http.request{
            url = self.base_url .. endpoint .. "?" .. params,
            method = "GET",
            sink = ltn12.sink.table(response)
        }

        return code == 200
    end

    function self:delete_message(message_id)
        local endpoint = "/deleteMessage"
        local response = {}
        
        local params = url.buildquery({
            chat_id = self.chat_id,
            message_id = message_id
        })

        local _, code = http.request{
            url = self.base_url .. endpoint .. "?" .. params,
            method = "GET",
            sink = ltn12.sink.table(response)
        }

        return code == 200
    end

    function self:pin_message(message_id)
        local endpoint = "/pinChatMessage"
        local response = {}
        
        local params = url.buildquery({
            chat_id = self.chat_id,
            message_id = message_id
        })

        local _, code = http.request{
            url = self.base_url .. endpoint .. "?" .. params,
            method = "GET",
            sink = ltn12.sink.table(response)
        }

        return code == 200
    end

    return self
end

return TelegramBot 