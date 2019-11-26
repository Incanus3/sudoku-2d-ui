$LOAD_PATH.unshift './lib'

require 'sudoku/client'
require 'sudoku/ui'

base_url = 'http://localhost:9292'
client   = Sudoku::Client.new(base_url)
game     = client.create_game

Sudoku::UI::MainWindow.new(game.puzzle.grid).show
