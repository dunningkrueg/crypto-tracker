package = "crypto-tracker"
version = "1.0-1"
source = {
   url = "git://github.com/dunningkrueg/crypto-tracker",
   tag = "v1.0"
}

description = {
   summary = "Cryptocurrency price tracker with Telegram notifications",
   detailed = [[
      A cryptocurrency price tracker that monitors prices
      from Binance, sends notifications via Telegram, and includes
      technical analysis features.
   ]],
   homepage = "https://github.com/dunningkrueg/crypto-tracker",
   license = "MIT"
}

dependencies = {
   "lua >= 5.1",
   "luasocket >= 3.0",
   "lua-cjson >= 2.1.0",
   "luasec >= 1.0",
   "lsqlite3 >= 0.9.5",
   "luacrypto >= 0.3.2",
   "gnuplot >= 1.0",
   "lua-gnuplot >= 0.1"
}

build = {
   type = "builtin",
   modules = {
      ["crypto-tracker.config"] = "src/config.lua",
      ["crypto-tracker.binance_api"] = "src/binance_api.lua",
      ["crypto-tracker.telegram_bot"] = "src/telegram_bot.lua",
      ["crypto-tracker.price_tracker"] = "src/price_tracker.lua",
      ["crypto-tracker.utils"] = "src/utils.lua",
      ["crypto-tracker.database"] = "src/database.lua",
      ["crypto-tracker.market_analyzer"] = "src/market_analyzer.lua",
      ["crypto-tracker.chart_generator"] = "src/chart_generator.lua",
      ["crypto-tracker.notification_manager"] = "src/notification_manager.lua",
      ["crypto-tracker.trade_analyzer"] = "src/trade_analyzer.lua"
   },
   install = {
      bin = {
         "src/main.lua"
      }
   }
} 