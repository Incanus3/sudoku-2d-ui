module Sudoku
  class Grid
    attr_reader :matrix

    def initialize(matrix)
      @matrix = matrix
    end

    def cell_filled?(cell)
      !cell_empty?(cell)
    end

    def cell_empty?(cell)
      cell_value(cell).nil?
    end

    def cell_value(cell)
      matrix[cell.row - 1][cell.column - 1]
    end

    def fill_cell(cell, number)
      matrix[cell.row - 1][cell.column - 1] = number
    end
  end
end
