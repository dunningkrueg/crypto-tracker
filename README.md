# Crypto Price Tracker

A cryptocurrency price tracker with Telegram notifications and technical analysis.

## Features
- Real-time price monitoring from Binance
- Telegram notifications for price alerts
- Technical analysis with RSI, moving averages, and volume analysis
- Price and volume charts generation
- Database logging for historical data
- Market structure analysis with trend detection
- Support and resistance level detection

## Requirements
- Lua >= 5.1
- LuaRocks package manager

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/dunningkrueg/crypto-tracker.git
cd crypto-tracker
```

### 2. Run the installation script
```bash
./install.sh
```

### 3. Configure the application
Edit `src/config.lua` and set your API keys:
```lua
config = {
    BINANCE_API_KEY = "YOUR_BINANCE_API_KEY",
    BINANCE_SECRET_KEY = "YOUR_BINANCE_SECRET_KEY",
    TELEGRAM_BOT_TOKEN = "YOUR_TELEGRAM_BOT_TOKEN",
    TELEGRAM_CHAT_ID = "YOUR_CHAT_ID",
    ...
}
```

### 4. Run the application
```bash
lua src/main.lua
```


## Available Commands
- `/price [symbol]` - Get current price for a symbol
- `/track [symbol]` - Track a new symbol
- `/stats [symbol]` - Get 24h statistics
- `/chart [symbol]` - Get price chart

## Configuration Options
- `UPDATE_INTERVAL`: Interval in seconds for price updates
- `PRICE_CHANGE_THRESHOLD`: Percentage change to trigger alerts
- `RSI_PERIOD`: Period for RSI calculation
- `TEMP_DIR`: Directory for temporary files
- `CHART_STYLE`: Style for charts (e.g., "lines", "points")
- `NOTIFICATION_COOLDOWN`: Cooldown period for notifications
- `SHORT_MA_PERIOD`, `MEDIUM_MA_PERIOD`, `LONG_MA_PERIOD`: Periods for moving averages
- `VOLUME_THRESHOLD`: Threshold for volume spike detection

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing
Feel free to submit issues or pull requests. For major changes, please open an issue first to discuss what you would like to change.

