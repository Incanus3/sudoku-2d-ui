require 'ruby2d'
require_relative 'utils'
require_relative 'shapes'

module Sudoku
  class UI
    class Board
      SIZE = 900
      X    = 50
      Y    = 50

      def initialize
        @main_border   = CustomShapes::Square.new(x: X, y: Y, size: SIZE, width: 5,                   color: 'green')
        @cells_grid    = CustomShapes::Grid.new(  x: X, y: Y, size: SIZE, rows: 9, cols: 9, width: 1, color: 'green')
        @sections_grid = CustomShapes::Grid.new(  x: X, y: Y, size: SIZE, rows: 3, cols: 3, width: 3, color: 'green')
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
    end


    def initialize
      @tick       = 0
      @window     = Ruby2D::Window.current
      @board      = Board.new
      @info_text  = TextUtils::draw_text(get_info_text, y: 10)
      @event_text = TextUtils::draw_text(''           , y: @info_text.y + TextUtils::DEFAULT_FONT_SIZE + 5)

      @window.set(title: 'sudoku', width: Board::SIZE + 2 * Board::X, height: Board::SIZE + 2 * Board::Y)
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
        @tick          += 1
        @info_text.text = get_info_text
      end

      @window.on :mouse_down do |event|
        @event_text.text = "#{get_event_text(event)}, hit the board: #{@board.contains?(event) ? 'yes' : 'no'}"
      end
    end
  end
end

Sudoku::UI.new.show
