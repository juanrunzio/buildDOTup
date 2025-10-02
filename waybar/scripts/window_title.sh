#!/bin/bash
hyprctl active -j | jq -r '.title' | sed 's/^$/home/'
