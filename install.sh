#!/bin/bash

echo "Installing LuaRocks..."
if [ "$(uname)" == "Darwin" ]; then
    brew install luarocks
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    sudo apt-get update
    sudo apt-get install -y luarocks
fi

echo "Installing dependencies..."
sudo luarocks install luasocket
sudo luarocks install lua-cjson
sudo luarocks install luasec
sudo luarocks install lsqlite3
sudo luarocks install luacrypto
sudo luarocks install gnuplot
sudo luarocks install lua-gnuplot

echo "Installing crypto-tracker..."
sudo luarocks make

echo "Installation complete!" 