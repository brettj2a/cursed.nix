#!/usr/bin/env bash
set -euo pipefail

# Tries to lift the curse for some arbitrary number of seconds

export HOST="127.0.0.1"
export RECV_PORT="5555"
export SERVE_PORT="5556"

./target/debug/curse &
rust_pid=$!

sleep 2

cd ./gosrc
./serve "chunk3.bin" &
go_pid=$!
cd ..

cd ./luasrc
./serve.lua "chunk1.bin" &
lua_pid=$!
cd ..

cd ./pysrc
./serve.py "chunk2.bin" &
py_pid=$!
cd ..

sleep 5 # adjust to taste

kill -9 "$rust_pid" "$go_pid" "$lua_pid" "$py_pid"
echo "All processes killed."
