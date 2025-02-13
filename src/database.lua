local sqlite3 = require("lsqlite3")
local json = require("cjson")

local Database = {}

function Database.new(config)
    local self = {
        db = sqlite3.open(config.DATABASE_PATH or "crypto_tracker.db")
    }

    function self:init()
        self.db:exec[[
            CREATE TABLE IF NOT EXISTS price_history (
                symbol TEXT,
                price REAL,
                volume REAL,
                timestamp INTEGER,
                PRIMARY KEY (symbol, timestamp)
            );

            CREATE TABLE IF NOT EXISTS alerts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                symbol TEXT,
                old_price REAL,
                new_price REAL,
                percentage_change REAL,
                timestamp INTEGER
            );
        ]]
    end

    function self:store_price(symbol, price, volume, timestamp)
        local stmt = self.db:prepare[[
            INSERT OR REPLACE INTO price_history (symbol, price, volume, timestamp)
            VALUES (?, ?, ?, ?)
        ]]
        
        stmt:bind_values(symbol, price, volume, timestamp)
        stmt:step()
        stmt:reset()
    end

    function self:store_alert(symbol, old_price, new_price, percentage_change)
        local stmt = self.db:prepare[[
            INSERT INTO alerts (symbol, old_price, new_price, percentage_change, timestamp)
            VALUES (?, ?, ?, ?, ?)
        ]]
        
        stmt:bind_values(symbol, old_price, new_price, percentage_change, os.time())
        stmt:step()
        stmt:reset()
    end

    function self:get_price_history(symbol, limit)
        local data = {}
        local query = string.format([[
            SELECT price, timestamp 
            FROM price_history 
            WHERE symbol = '%s'
            ORDER BY timestamp DESC
            LIMIT %d
        ]], symbol, limit or 100)

        for row in self.db:nrows(query) do
            table.insert(data, row)
        end
        
        return data
    end

    function self:close()
        self.db:close()
    end

    self:init()
    return self
end

return Database 