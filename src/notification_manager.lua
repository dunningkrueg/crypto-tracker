local Utils = require("utils")

local NotificationManager = {}

function NotificationManager.new(config)
    local self = {
        cooldown = config.NOTIFICATION_COOLDOWN or 300,
        last_notifications = {},
        priority_levels = {
            LOW = 1,
            MEDIUM = 2,
            HIGH = 3,
            URGENT = 4
        }
    }

    function self:can_send_notification(symbol, priority)
        local current_time = os.time()
        local last_time = self.last_notifications[symbol]
        
        if not last_time then
            return true
        end

        if priority >= self.priority_levels.HIGH then
            return true
        end

        return (current_time - last_time) >= self.cooldown
    end

    function self:format_alert_message(data)
        local priority = self:calculate_priority(data)
        local emoji = self:get_priority_emoji(priority)

        return string.format(
            "%s <b>%s Alert</b>\n\n" ..
            "Priority: %s\n" ..
            "Current Price: %s\n" ..
            "Change: %.2f%%\n" ..
            "Signal: %s\n" ..
            "RSI: %.2f\n\n" ..
            "Volume: %s\n" ..
            "Time: %s",
            emoji,
            data.symbol,
            self:get_priority_text(priority),
            Utils.format_number(data.current_price),
            data.price_change,
            data.signal,
            data.rsi or 0,
            Utils.format_number(data.volume),
            os.date("%Y-%m-%d %H:%M:%S")
        )
    end

    function self:calculate_priority(data)
        local priority = self.priority_levels.LOW
        
        if math.abs(data.price_change) >= 10 then
            priority = self.priority_levels.URGENT
        elseif math.abs(data.price_change) >= 5 then
            priority = self.priority_levels.HIGH
        elseif math.abs(data.price_change) >= 2 then
            priority = self.priority_levels.MEDIUM
        end
        
        return priority
    end

    function self:get_priority_emoji(priority)
        local emojis = {
            [self.priority_levels.LOW] = "ℹ️",
            [self.priority_levels.MEDIUM] = "⚠️",
            [self.priority_levels.HIGH] = "🚨",
            [self.priority_levels.URGENT] = "🔥"
        }
        return emojis[priority] or "ℹ️"
    end

    function self:get_priority_text(priority)
        local texts = {
            [self.priority_levels.LOW] = "Low",
            [self.priority_levels.MEDIUM] = "Medium",
            [self.priority_levels.HIGH] = "High",
            [self.priority_levels.URGENT] = "Urgent"
        }
        return texts[priority] or "Unknown"
    end

    function self:record_notification(symbol)
        self.last_notifications[symbol] = os.time()
    end

    return self
end

return NotificationManager 