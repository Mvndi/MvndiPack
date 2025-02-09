#!/bin/bash
for item in "$@"; do
  printf '{
  "model": {
    "type": "minecraft:model",
    "model": "minecraft:item/%s"
  }
}\n' "$item" > "$item.json"
done

