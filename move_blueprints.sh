#!/bin/bash
mkdir -p examples
for dir in blueprints/*; do
  if [ -d "$dir" ]; then
    mv "$dir" examples/
  fi
done
