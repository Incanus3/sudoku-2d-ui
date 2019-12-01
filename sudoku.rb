$LOAD_PATH.unshift './lib'

require 'sudoku/client'
require 'sudoku/ui'

base_url = 'http://localhost:9292'
client   = Sudoku::Client.new(base_url)

Sudoku::UI::MainWindow.new(client).show
