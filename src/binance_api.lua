local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("cjson")
local crypto = require("crypto")

local BinanceAPI = {}

function BinanceAPI.new(config)
    local self = {
        api_key = config.BINANCE_API_KEY,
        secret_key = config.BINANCE_SECRET_KEY,
        base_url = "https://api.binance.com"
    }

    function self:get_price(symbol)
        local endpoint = "/api/v3/ticker/price"
        local url = self.base_url .. endpoint .. "?symbol=" .. symbol
        local response = {}
        
        local _, code = http.request{
            url = url,
            method = "GET",
            headers = {
                ["X-MBX-APIKEY"] = self.api_key
            },
            sink = ltn12.sink.table(response)
        }

        if code == 200 then
            local data = json.decode(table.concat(response))
            return tonumber(data.price)
        end
        return nil
    end

    function self:get_24h_stats(symbol)
        local endpoint = "/api/v3/ticker/24hr"
        local url = self.base_url .. endpoint .. "?symbol=" .. symbol
        local response = {}
        
        local _, code = http.request{
            url = url,
            method = "GET",
            headers = {
                ["X-MBX-APIKEY"] = self.api_key
            },
            sink = ltn12.sink.table(response)
        }

        if code == 200 then
            return json.decode(table.concat(response))
        end
        return nil
    end

    return self
end

return BinanceAPI 