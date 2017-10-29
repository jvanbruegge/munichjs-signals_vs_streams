#!/bin/bash

theme="moon"

pandoc -t revealjs -s -o docs/index.html \
    -V theme="$theme" -V slideNumber=true \
    README.md

sed -i "s/#19177c/#17b0de/g" docs/index.html
