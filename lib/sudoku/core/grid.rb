module Sudoku
  class Grid
    attr_reader :matrix

    def initialize(matrix)
      @matrix = matrix
    end

    def cell_filled?(cell)
      !cell_value(cell).nil?
    end

    def cell_value(cell)
      matrix[cell.row - 1][cell.column - 1]
    end
  end
end
