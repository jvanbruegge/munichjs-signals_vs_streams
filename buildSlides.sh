#!/bin/bash

theme="moon"

pandoc -t revealjs -s -o index.html -V theme="$theme" README.md
