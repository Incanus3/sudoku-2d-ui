$LOAD_PATH.unshift './lib'

require 'client'
require 'ui'

base_url = 'http://localhost:9292'
client   = Sudoku::Client.new(base_url)
game     = client.create_game

Sudoku::UI.new(game.puzzle.grid).show
