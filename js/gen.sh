#!/usr/bin/env bash

./node_modules/browserify/bin/cmd.js main.js -s all_crypto -o sushi.js
cat native.js >> sushi.js
