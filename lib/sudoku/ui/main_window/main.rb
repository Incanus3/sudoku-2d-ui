require 'ruby2d'
require 'sudoku/ui/shapes'
require 'sudoku/ui/buttons'
require 'sudoku/ui/board'
require_relative 'states'
require_relative 'layout'

module Sudoku
  module UI
    class MainWindow
      DEFAULT_BOARD_SIZE = 600
      BOARD_MARGIN_RATIO = 15

      def initialize(grid, board_size: DEFAULT_BOARD_SIZE, margin: board_size / BOARD_MARGIN_RATIO)
        layout = self.class::Layout.new(board_size, margin)

        @tick   = 0
        @grid   = grid
        @state  = States::WaitingForCellSelection.new
        @window = Ruby2D::Window.new(title: 'sudoku',
                                     width: layout.window_width, height: layout.window_height)
        @board  = Board.new(matrix: grid.matrix,
                            x: layout.board_x_offset, y: layout.board_y_offset,
                            width: layout.board_size, height: layout.board_size)

        init_widgets(layout, @state)
      end

      private def init_widgets(layout, state, top_texts_color: 'green')
        @info_text_widget  = Shapes::Text.new('',
                                              x: layout.text_spacer, y: layout.info_text_y_offset,
                                              size: layout.font_size, color: top_texts_color)
        @state_text_widget = Shapes::Text.new(state.text,
                                              x: layout.text_spacer, y: layout.state_text_y_offset,
                                              size: layout.font_size, color: top_texts_color)
        @event_text_widget = Shapes::Text.new('',
                                              x: layout.text_spacer, y: layout.event_text_y_offset,
                                              size: layout.font_size, color: top_texts_color)
        @separator         = horizontal_separator(position: layout.texts_height,
                                                  length: layout.window_width)
        @buttons           = buttons(layout)
      end

      def show
        set_event_handlers

        window.show
      end

      private

      attr_accessor :tick
      attr_reader :grid, :state, :window, :board
      attr_reader :info_text_widget, :state_text_widget, :event_text_widget

      def state=(new_state)
        @state = new_state
        state_text_widget.text = new_state.text
      end


      def buttons(layout)
        width = layout.buttons_height

        (0..8).map do |index|
          Sudoku::UI::Button.new(
            text: index + 1,
            x: layout.buttons_x_offset + index * (width + layout.button_spacer),
            y: layout.buttons_y_offset,
            width: width, height: layout.buttons_height
          )
        end
      end

      def horizontal_separator(position:, length:, offset: 0, width: 1, color: 'green')
        Shapes::Line.new(x1: offset, y1: position, x2: offset + length, y2: position,
                         width: width, color: color)
      end


      def set_event_handlers
        window.update do
          self.tick = tick + 1
          info_text_widget.text = "time: #{Time.now.strftime('%T')}, tick: #{tick}"
        end

        window.on(:mouse_down, &method(:handle_click))
        window.on(:key_down,   &method(:handle_key))
      end

      def handle_click(event)
        event_text_widget.text = "clicked x: #{event.x}, y: #{event.y}"

        self.state = if board.contains?(event)
                     then States::CellSelected.new(board.cell_for(event), grid)
                     else States::WaitingForCellSelection.new
                     end
      end

      def handle_key(event)
        exit if event.key == 'q'
      end
    end
  end
end
