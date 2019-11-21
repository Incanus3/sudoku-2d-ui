require_relative 'grid'

module Sudoku
  class Puzzle
    attr_reader :grid

    def initialize(grid_or_matrix)
      @grid = if grid_or_matrix.is_a?(Grid)
                grid_or_matrix
              else
                Grid.new(grid_or_matrix)
              end
    end
  end
end
