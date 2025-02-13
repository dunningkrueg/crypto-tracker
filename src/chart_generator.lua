local gnuplot = require("gnuplot")
local Utils = require("utils")

local ChartGenerator = {}

function ChartGenerator.new(config)
    local self = {
        temp_dir = config.TEMP_DIR or "/tmp",
        chart_style = config.CHART_STYLE or "lines"
    }

    function self:generate_price_chart(symbol, price_data, output_file)
        local timestamps = {}
        local prices = {}
        
        for _, data in ipairs(price_data) do
            table.insert(timestamps, data.timestamp)
            table.insert(prices, data.price)
        end

        local plot = gnuplot.new()
        plot:cmd("set terminal png size 1200,600")
        plot:cmd(string.format("set output '%s'", output_file))
        plot:cmd("set title '" .. symbol .. " Price Chart'")
        plot:cmd("set xlabel 'Time'")
        plot:cmd("set ylabel 'Price'")
        plot:cmd("set grid")
        plot:cmd("set xdata time")
        plot:cmd("set timefmt '%s'")
        plot:cmd("set format x '%Y-%m-%d\\n%H:%M'")
        plot:cmd("set style line 1 lc rgb '#0060ad' lt 1 lw 2")
        
        plot:plot(timestamps, prices, "with " .. self.chart_style .. " ls 1 title 'Price'")
        plot:close()
        
        return output_file
    end

    function self:generate_volume_chart(symbol, volume_data, output_file)
        local timestamps = {}
        local volumes = {}
        
        for _, data in ipairs(volume_data) do
            table.insert(timestamps, data.timestamp)
            table.insert(volumes, data.volume)
        end

        local plot = gnuplot.new()
        plot:cmd("set terminal png size 1200,600")
        plot:cmd(string.format("set output '%s'", output_file))
        plot:cmd("set title '" .. symbol .. " Volume Chart'")
        plot:cmd("set xlabel 'Time'")
        plot:cmd("set ylabel 'Volume'")
        plot:cmd("set grid")
        plot:cmd("set xdata time")
        plot:cmd("set timefmt '%s'")
        plot:cmd("set format x '%Y-%m-%d\\n%H:%M'")
        plot:cmd("set style fill solid")
        plot:cmd("set boxwidth 0.5 relative")
        
        plot:plot(timestamps, volumes, "with boxes title 'Volume'")
        plot:close()
        
        return output_file
    end

    return self
end

return ChartGenerator 