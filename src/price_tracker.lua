local Utils = require("utils")
local Database = require("database")
local MarketAnalyzer = require("market_analyzer")

local PriceTracker = {}

function PriceTracker.new(binance_api, telegram_bot, config)
    local self = {
        binance = binance_api,
        telegram = telegram_bot,
        threshold = config.PRICE_CHANGE_THRESHOLD,
        price_cache = {},
        last_alert_time = {},
        db = Database.new(config),
        analyzer = MarketAnalyzer.new(config)
    }

    function self:track_symbol(symbol)
        local current_price = self.binance:get_price(symbol)
        local stats = self.binance:get_24h_stats(symbol)
        
        if not current_price or not stats then
            return
        end

        if config.ENABLE_DATABASE_LOGGING then
            self.db:store_price(symbol, current_price, tonumber(stats.volume), os.time())
        end

        if not self.price_cache[symbol] then
            self.price_cache[symbol] = current_price
            return
        end

        local price_change = Utils.calculate_percentage_change(self.price_cache[symbol], current_price)
        local current_time = os.time()
        
        if math.abs(price_change) >= self.threshold then
            if not self.last_alert_time[symbol] or 
               (current_time - self.last_alert_time[symbol]) >= config.ALERT_COOLDOWN then
                
                local price_history = self.db:get_price_history(symbol, 100)
                local analysis = self.analyzer:analyze_trend(symbol, current_price, price_history)
                
                local message = string.format(
                    "<b>%s Price Alert</b>\n\n" ..
                    "Current Price: %s\n" ..
                    "Price Change: %.2f%%\n" ..
                    "24h Volume: %s\n" ..
                    "24h High: %s\n" ..
                    "24h Low: %s\n" ..
                    "RSI: %.2f\n" ..
                    "Signal: %s",
                    symbol,
                    Utils.format_number(current_price),
                    price_change,
                    Utils.format_number(tonumber(stats.volume)),
                    Utils.format_number(tonumber(stats.highPrice)),
                    Utils.format_number(tonumber(stats.lowPrice)),
                    analysis.rsi or 0,
                    analysis.signal or "UNKNOWN"
                )
                
                self.telegram:send_message(message)
                self.last_alert_time[symbol] = current_time
                
                if config.ENABLE_DATABASE_LOGGING then
                    self.db:store_alert(symbol, self.price_cache[symbol], current_price, price_change)
                end
            end
        end
        
        self.price_cache[symbol] = current_price
    end

    return self
end

return PriceTracker