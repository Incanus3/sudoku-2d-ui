require_relative 'puzzle'

module Sudoku
  class Game
    attr_reader :id, :puzzle

    def initialize(id, puzzle)
      @id     = id
      @puzzle = puzzle
    end
  end
end
