local Utils = require("utils")

local MarketAnalyzer = {}

function MarketAnalyzer.new(config)
    local self = {
        rsi_period = config.RSI_PERIOD or 14,
        price_history = {}
    }

    function self:calculate_rsi(prices)
        if #prices < self.rsi_period then
            return nil
        end

        local gains = 0
        local losses = 0

        for i = 2, self.rsi_period + 1 do
            local diff = prices[i] - prices[i-1]
            if diff > 0 then
                gains = gains + diff
            else
                losses = losses - diff
            end
        end

        local avg_gain = gains / self.rsi_period
        local avg_loss = losses / self.rsi_period
        
        if avg_loss == 0 then
            return 100
        end
        
        local rs = avg_gain / avg_loss
        return 100 - (100 / (1 + rs))
    end

    function self:analyze_trend(symbol, current_price, price_history)
        local analysis = {
            symbol = symbol,
            current_price = current_price,
            timestamp = os.time()
        }

        if #price_history >= 2 then
            local price_change_24h = Utils.calculate_percentage_change(
                price_history[#price_history].price,
                current_price
            )
            analysis.price_change_24h = price_change_24h
        end

        local prices = {}
        for _, entry in ipairs(price_history) do
            table.insert(prices, entry.price)
        end

        analysis.rsi = self:calculate_rsi(prices)
        
        if analysis.rsi then
            if analysis.rsi < 30 then
                analysis.signal = "OVERSOLD"
            elseif analysis.rsi > 70 then
                analysis.signal = "OVERBOUGHT"
            else
                analysis.signal = "NEUTRAL"
            end
        end

        return analysis
    end

    return self
end

return MarketAnalyzer 