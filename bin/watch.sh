#!/bin/bash

for ((;;)); do
  inotifywait -e MODIFY -r sudoku.rb lib
  ruby sudoku.rb
done
