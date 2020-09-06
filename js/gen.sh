#!/usr/bin/env bash

./node_modules/browserify/bin/cmd.js main.js -s all_crypto -o axentro.js
cat native.js >> axentro.js
