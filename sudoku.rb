require 'ruby2d'
require_relative 'shapes'

# TODO: implement keyboard interaction

module Sudoku
  class UI
    class Output
      def self.for(widget:)
        new(widget)
      end

      def initialize(widget)
        @widget = widget
      end

      def puts(message)
        @widget.text = message
      end

      def p(thing)
        @widget.text = thing.inspect
      end

      alias_method :<<, :puts
    end


    class Board
      attr_reader :x, :y, :width, :height

      def initialize(matrix:, x:, y:, width:, height:, border_color: 'white', output: $stdout)
        @matrix = matrix
        @x      = x
        @y      = y
        @width  = width
        @height = height
        @output = output

        common_params = {
          x: x, y: y,
          width: width, height: height,
        }

        @main_border = Shapes::Rectangle.new(
          **common_params,
          border_width: 5, border_color: border_color)

        @section_borders_grid = Shapes::GridWithBorders.new(
          **common_params,
          rows: 3, columns: 3,
          border_width: 3, border_color: border_color)

        @cell_borders_grid = Shapes::GridWithBorders.new(
          **common_params,
          rows: 9, columns: 9,
          border_width: 1, border_color: border_color)

        @final_numbers_grid = Shapes::GridWithChars.new(
          **common_params,
          rows: 9, columns: 9,
          chars_matrix: @matrix)

        full_matrix  = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        empty_matrix = [[], [], []]

        @note_numbers_grid = Shapes::Grid.new(**common_params, rows: 9, columns: 9) do |cell|
          Shapes::GridWithChars.new(x: cell.x + 1.0/20 * cell.width, y: cell.y + 1.0/20 * cell.height,
                                    width: 9.0/10 * cell.width, height: 9.0/10 * cell.height,
                                    rows: 3, columns: 3,
                                    chars_matrix: (cell.row + cell.column).odd? ? full_matrix : empty_matrix)
        end

        @all_shapes = [@main_border, @section_borders_grid, @cell_borders_grid,
                       @final_numbers_grid, @note_numbers_grid]
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

      def handle_event(event)
        cell = @cell_borders_grid.cell_for(event)

        @output << "you clicked #{cell}"
      end
    end

    DEFAULT_BOARD_SIZE = 600

    def initialize(board_size: DEFAULT_BOARD_SIZE, margin: board_size / 15)
      full_spacer   = margin / 5
      half_spacer   = margin / 10
      font_size     = full_spacer * 1.5
      texts_height  = 2 * font_size + 3 * full_spacer
      window_width  = board_size + 2 * margin
      window_height = board_size + 2 * margin + texts_height

      @tick         = 0
      @window       = Ruby2D::Window.new(title: 'sudoku', width: window_width, height: window_height)
      @info_text    = Shapes::Text.new(get_info_text, x: full_spacer, y: full_spacer,
                                       size: font_size, color: 'green')
      @event_text   = Shapes::Text.new('', x: full_spacer,
                                       y: @info_text.y + @info_text.size + half_spacer,
                                       size: font_size, color: 'green')
      @info_output  = Output.for(widget: @info_text)
      @event_output = Output.for(widget: @event_text)
      @separator    = horizontal_separator(position: texts_height, length: window_width)
      @board        = board(x: margin, y: texts_height + margin, size: board_size)
    end

    def show
      set_event_handlers

      @window.show
    end

    private

    def board(x:, y:, size:)
      numbers            = (1..9).to_a
      empty_matrix       = (0..8).map {|i| numbers.map {nil}}
      full_matrix        = (0..8).map {|i| numbers.rotate(i-1)}
      alternating_matrix = (0..8).map do |i|
        numbers.rotate(i).each_with_index.map {|num, j| num if (i + j).even?}
      end

      Board.new(matrix: alternating_matrix,
                x: x, y: y,
                width: size, height: size,
                border_color: 'green', output: @event_output)
    end

    def horizontal_separator(position:, length:, offset: 0, width: 1, color: 'green')
      Shapes::Line.new(x1: offset, y1: position, x2: offset + length, y2: position, width: width, color: color)
    end

    def get_info_text
      "time: #{Time.now.strftime('%T')}, tick: #{@tick}"
    end

    def get_event_text(event)
      case event
      when Ruby2D::Window::MouseEvent
        "clicked x: #{event.x}, y: #{event.y}"
      end
    end

    def set_event_handlers
      @window.update do
        @tick += 1
        @info_output << get_info_text

        # test showing and hiding of the whole board
        # @board.add    if @tick % 120 < 60
        # @board.remove if @tick % 120 > 60
      end

      @window.on :mouse_down do |event|
        @event_output << "#{get_event_text(event)}, hit the board: #{@board.contains?(event) ? 'yes' : 'no'}"
        @board.handle_event(event) if @board.contains?(event)
      end

      @window.on :key_down do |event|
        exit if event.key == 'q'
      end
    end
  end
end

Sudoku::UI.new.show
