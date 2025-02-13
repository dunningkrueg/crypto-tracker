local json = require("cjson")

local Utils = {}

function Utils.round(num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utils.format_number(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function Utils.calculate_percentage_change(old_value, new_value)
    return ((new_value - old_value) / old_value) * 100
end

function Utils.timestamp_to_date(timestamp)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp / 1000)
end

function Utils.safe_json_encode(data)
    local status, result = pcall(json.encode, data)
    if status then
        return result
    end
    return nil
end

function Utils.safe_json_decode(str)
    local status, result = pcall(json.decode, str)
    if status then
        return result
    end
    return nil
end

return Utils 