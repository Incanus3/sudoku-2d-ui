require_relative 'shapes'

module Sudoku
  module UI
    class Board
      DEFAULT_BORDER_COLOR = 'green'.freeze

      attr_reader :x, :y, :width, :height

      def initialize(grid:, x:, y:, width:, height:, border_color: DEFAULT_BORDER_COLOR)
        @grid   = grid
        @x      = x
        @y      = y
        @width  = width
        @height = height

        @common_params = { x: x, y: y, width: width, height: height }

        init_borders(@common_params, border_color)
        init_number_grids(@common_params, grid)
      end

      private def init_borders(common_params, border_color)
        @main_border = Shapes::Rectangle.new(
          **common_params,
          border_width: 5, border_color: border_color
        )

        @section_borders_grid = Shapes::GridWithBorders.new(
          **common_params,
          rows: 3, columns: 3,
          border_width: 3, border_color: border_color
        )

        @cell_borders_grid = Shapes::GridWithBorders.new(
          **common_params,
          rows: 9, columns: 9,
          border_width: 1, border_color: border_color
        )
      end

      private def init_number_grids(common_params, grid)
        @final_numbers_grid = Shapes::GridWithChars.new(
          **common_params,
          rows: 9, columns: 9,
          chars_matrix: grid.matrix
        )

        @note_numbers_grid = Shapes::Grid.new(**common_params, rows: 9, columns: 9) do |cell|
          # unless grid.cell_filled?(cell)
          # for testing purposes - the server returns a grid completely filled with note numbers
          if false
            Shapes::GridWithChars.new(
              x: cell.x + 1.0 / 20 * cell.width, y: cell.y + 1.0 / 20 * cell.height,
              width: 9.0 / 10 * cell.width, height: 9.0 / 10 * cell.height,
              rows: 3, columns: 3,
              chars_matrix: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
            )
          end
        end
      end

      def add
        all_shapes.each(&:add)
      end

      def remove
        all_shapes.each(&:remove)
      end

      def contains?(coords)
        @main_border.contains?(coords)
      end

      def cell_for(event)
        @cell_borders_grid.cell_for(event)
      end

      def cell_filled?(cell)
        @grid.cell_filled?(cell)
      end

      def fill_cell(cell, number)
        @grid.fill_cell(cell, number)
        @final_numbers_grid.set_number_at(cell, number)
        @note_numbers_grid.set_child_at(cell, nil)
      end

      private

      def all_shapes
        [@main_border, @section_borders_grid, @cell_borders_grid,
         @final_numbers_grid, @note_numbers_grid]
      end
    end
  end
end
