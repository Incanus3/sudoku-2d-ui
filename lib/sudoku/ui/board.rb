require_relative 'shapes'

module Sudoku
  module UI
    class Board
      DEFAULT_BORDER_COLOR = 'green'.freeze

      attr_reader :x, :y, :width, :height

      def initialize(matrix:, x:, y:, width:, height:, border_color: DEFAULT_BORDER_COLOR)
        @matrix = matrix
        @x      = x
        @y      = y
        @width  = width
        @height = height

        common_params = {
          x: x, y: y,
          width: width, height: height
        }

        @main_border = Shapes::Rectangle.new(
          **common_params,
          border_width: 5, border_color: border_color
        )

        grids = init_grids(common_params, border_color)

        @all_shapes = [@main_border] + grids
      end

      private def init_grids(common_params, border_color) # rubocop:disable Metrics/MethodLength
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

        @final_numbers_grid = Shapes::GridWithChars.new(
          **common_params,
          rows: 9, columns: 9,
          chars_matrix: @matrix
        )

        full_matrix  = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        empty_matrix = [[], [], []]

        @note_numbers_grid = Shapes::Grid.new(**common_params, rows: 9, columns: 9) do |cell|
          Shapes::GridWithChars.new(
            x: cell.x + 1.0 / 20 * cell.width, y: cell.y + 1.0 / 20 * cell.height,
            width: 9.0 / 10 * cell.width, height: 9.0 / 10 * cell.height,
            rows: 3, columns: 3,
            chars_matrix: (cell.row + cell.column).odd? ? full_matrix : empty_matrix
          )
        end

        [@section_borders_grid, @cell_borders_grid, @final_numbers_grid, @note_numbers_grid]
      end

      def add
        @all_shapes.each(&:add)
      end

      def remove
        @all_shapes.each(&:remove)
      end

      def contains?(coords)
        @main_border.contains?(coords)
      end

      def cell_for(event)
        @cell_borders_grid.cell_for(event)
      end
    end
  end
end
