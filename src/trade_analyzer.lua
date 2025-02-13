local Utils = require("utils")

local TradeAnalyzer = {}

function TradeAnalyzer.new(config)
    local self = {
        ma_periods = {
            short = config.SHORT_MA_PERIOD or 7,
            medium = config.MEDIUM_MA_PERIOD or 25,
            long = config.LONG_MA_PERIOD or 99
        },
        volume_threshold = config.VOLUME_THRESHOLD or 1.5
    }

    function self:calculate_moving_average(prices, period)
        if #prices < period then
            return nil
        end

        local sum = 0
        for i = #prices - period + 1, #prices do
            sum = sum + prices[i]
        end
        
        return sum / period
    end

    function self:detect_volume_spike(current_volume, average_volume)
        return current_volume > (average_volume * self.volume_threshold)
    end

    function self:analyze_market_structure(price_data)
        local prices = {}
        local volumes = {}
        
        for _, data in ipairs(price_data) do
            table.insert(prices, data.price)
            table.insert(volumes, data.volume)
        end

        local analysis = {
            ma_short = self:calculate_moving_average(prices, self.ma_periods.short),
            ma_medium = self:calculate_moving_average(prices, self.ma_periods.medium),
            ma_long = self:calculate_moving_average(prices, self.ma_periods.long),
            volume_spike = false
        }

        local avg_volume = self:calculate_moving_average(volumes, 24)
        if avg_volume then
            analysis.volume_spike = self:detect_volume_spike(volumes[#volumes], avg_volume)
        end

        analysis.trend = self:determine_trend(analysis)
        analysis.strength = self:calculate_trend_strength(analysis)
        analysis.support_resistance = self:find_support_resistance(prices)

        return analysis
    end

    function self:determine_trend(analysis)
        if not analysis.ma_short or not analysis.ma_medium or not analysis.ma_long then
            return "UNKNOWN"
        end

        if analysis.ma_short > analysis.ma_medium and analysis.ma_medium > analysis.ma_long then
            return "STRONG_UPTREND"
        elseif analysis.ma_short < analysis.ma_medium and analysis.ma_medium < analysis.ma_long then
            return "STRONG_DOWNTREND"
        elseif analysis.ma_short > analysis.ma_medium then
            return "UPTREND"
        elseif analysis.ma_short < analysis.ma_medium then
            return "DOWNTREND"
        end

        return "SIDEWAYS"
    end

    function self:calculate_trend_strength(analysis)
        if not analysis.ma_short or not analysis.ma_medium or not analysis.ma_long then
            return 0
        end

        local short_medium_diff = math.abs(analysis.ma_short - analysis.ma_medium)
        local medium_long_diff = math.abs(analysis.ma_medium - analysis.ma_long)
        
        return (short_medium_diff + medium_long_diff) / 2
    end

    function self:find_support_resistance(prices)
        local levels = {}
        local window_size = 10
        
        for i = window_size + 1, #prices - window_size do
            local is_support = true
            local is_resistance = true
            
            for j = i - window_size, i + window_size do
                if prices[i] > prices[j] then
                    is_support = false
                end
                if prices[i] < prices[j] then
                    is_resistance = false
                end
            end
            
            if is_support then
                table.insert(levels, {price = prices[i], type = "SUPPORT"})
            elseif is_resistance then
                table.insert(levels, {price = prices[i], type = "RESISTANCE"})
            end
        end
        
        return levels
    end

    return self
end

return TradeAnalyzer 