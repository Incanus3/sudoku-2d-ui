require_relative 'grid'

module Sudoku
  class Game
    attr_reader :id, :grid

    def initialize(id, grid_or_matrix)
      @id   = id
      @grid = if grid_or_matrix.is_a?(Grid)
                grid_or_matrix
              else
                Grid.new(grid_or_matrix)
              end
    end

    def finished?
      self.grid.completely_filled?
    end
  end
end
