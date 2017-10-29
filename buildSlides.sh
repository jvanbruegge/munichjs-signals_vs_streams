#!/bin/bash

theme="moon"

pandoc -t revealjs -s -o docs/index.html \
    -V theme="$theme" -V revealjs-url=https://lab.hakim.se/reveal-js \
    README.md
