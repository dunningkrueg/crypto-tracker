local config = require("config")
local BinanceAPI = require("binance_api")
local TelegramBot = require("telegram_bot")
local PriceTracker = require("price_tracker")
local Utils = require("utils")

local binance = BinanceAPI.new(config)
local telegram = TelegramBot.new(config)
local tracker = PriceTracker.new(binance, telegram, config)

telegram:register_command("price", "Get current price for a symbol", function(message)
    local symbol = message.text:match("^/price%s+(.+)")
    if symbol then
        symbol = string.upper(symbol)
        local price = binance:get_price(symbol)
        if price then
            telegram:send_message(string.format("<b>%s</b>\nCurrent price: %s", symbol, Utils.format_number(price)))
        else
            telegram:send_message("Symbol not found")
        end
    end
end)

telegram:register_command("track", "Track a new symbol", function(message)
    local symbol = message.text:match("^/track%s+(.+)")
    if symbol then
        symbol = string.upper(symbol)
        telegram:send_keyboard("Select tracking options for " .. symbol, {
            {
                {text = "Start Tracking", callback_data = "track_" .. symbol},
                {text = "Cancel", callback_data = "cancel"}
            }
        })
    end
end)

telegram:register_command("stats", "Get 24h statistics", function(message)
    local symbol = message.text:match("^/stats%s+(.+)")
    if symbol then
        symbol = string.upper(symbol)
        local stats = binance:get_24h_stats(symbol)
        if stats then
            local text = string.format(
                "<b>%s 24h Statistics</b>\n\n" ..
                "High: %s\n" ..
                "Low: %s\n" ..
                "Volume: %s\n" ..
                "Price Change: %.2f%%",
                symbol,
                Utils.format_number(tonumber(stats.highPrice)),
                Utils.format_number(tonumber(stats.lowPrice)),
                Utils.format_number(tonumber(stats.volume)),
                tonumber(stats.priceChangePercent)
            )
            telegram:send_message(text)
        end
    end
end)

telegram:set_commands()

local function main()
    while true do
        pcall(function()
            telegram:get_updates()
        end)
        os.execute("sleep 1")
    end
end

main() 