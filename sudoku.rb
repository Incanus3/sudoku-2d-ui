require 'ruby2d'
require_relative 'utils'
require_relative 'shapes'

module Sudoku
  class UI
    class Output
      def initialize(widget:)
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
      attr_reader :x, :y, :size

      def initialize(x:, y:, size:, output: $stdout)
        @x      = x
        @y      = y
        @size   = size
        @output = output

        @main_border   = CustomShapes::Square.new(
          x: x, y: y, size: size,                      width: 5, color: 'green')
        @cells_grid    = CustomShapes::Grid.new(
          x: x, y: y, size: size, rows: 9, columns: 9, width: 1, color: 'green')
        @sections_grid = CustomShapes::Grid.new(
          x: x, y: y, size: size, rows: 3, columns: 3, width: 3, color: 'green')
      end

      def add
        [@main_border, @cells_grid, @sections_grid].each(&:add)
      end

      def remove
        [@main_border, @cells_grid, @sections_grid].each(&:remove)
      end

      def contains?(coords)
        @main_border.contains?(coords)
      end

      def handle_event(event)
        cell = @cells_grid.cell_for(event)

        @output << "you clicked #{cell}"
      end
    end


    def initialize
      @tick         = 0
      @window       = Ruby2D::Window.new
      @info_text    = TextUtils.draw_text(get_info_text, y: 10)
      @event_text   = TextUtils.draw_text(''           , y: @info_text.y + TextUtils::DEFAULT_FONT_SIZE + 5)
      @info_output  = Output.new(widget: @info_text)
      @event_output = Output.new(widget: @event_text)
      @board        = Board.new(x: 50, y: 50, size: 600, output: @event_output)

      @window.set(title: 'sudoku', width: @board.size + 2 * @board.x, height: @board.size + 2 * @board.y)
    end

    def show
      set_event_handlers

      @window.show
    end

    private

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
      end

      @window.on :mouse_down do |event|
        @event_output << "#{get_event_text(event)}, hit the board: #{@board.contains?(event) ? 'yes' : 'no'}"
        @board.handle_event(event) if @board.contains?(event)
      end
    end
  end
end

Sudoku::UI.new.show
