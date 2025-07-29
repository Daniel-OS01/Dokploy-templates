#!/bin/bash
for dir in blueprints/*; do
  if [ -d "$dir" ]; then
    cp -r "$dir" examples/
  fi
done
