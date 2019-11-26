require 'ruby2d'
require_relative 'shapes'
require_relative 'states'
require_relative 'board'
require_relative 'buttons'

# TODO: implement keyboard interaction

module Sudoku
  module UI
    class MainWindow
      class Layout
        attr_reader :board_size, :font_size
        attr_reader :text_spacer, :button_spacer
        attr_reader :texts_height, :buttons_height
        attr_reader :info_text_y_offset, :state_text_y_offset, :event_text_y_offset
        attr_reader :board_x_offset, :board_y_offset, :buttons_x_offset, :buttons_y_offset
        attr_reader :window_width, :window_height

        def initialize(board_size, margin)
          @board_size          = board_size
          @margin              = margin
          @font_size           = 0.3 * margin

          @text_spacer         = 2.0 / 3 * @font_size
          @half_spacer         = @text_spacer / 2
          @button_spacer       = 2 * @text_spacer

          @texts_height        = 3 * @font_size + 4 * @text_spacer
          @buttons_height      = margin

          @info_text_y_offset  = @text_spacer
          @state_text_y_offset = @info_text_y_offset  + @font_size + @half_spacer
          @event_text_y_offset = @state_text_y_offset + @font_size + @half_spacer
          @board_x_offset      = margin
          @board_y_offset      = @texts_height + margin
          @buttons_x_offset    = margin
          @buttons_y_offset    = @board_y_offset + board_size + margin

          @window_width        = board_size + 2 * margin
          @window_height       = @buttons_y_offset + @buttons_height + margin
        end
      end

      DEFAULT_BOARD_SIZE = 600
      BOARD_MARGIN_RATIO = 15

      def initialize(grid, board_size: DEFAULT_BOARD_SIZE, margin: board_size / BOARD_MARGIN_RATIO)
        layout = self.class::Layout.new(board_size, margin)

        @tick   = 0
        @state  = States::WaitingForCellSelection.new
        @window = Ruby2D::Window.new(title: 'sudoku',
                                     width: layout.window_width, height: layout.window_height)
        @board  = Board.new(matrix: grid.matrix,
                            x: layout.board_x_offset, y: layout.board_y_offset,
                            width: layout.board_size, height: layout.board_size)

        init_widgets(layout, info_text(@tick), state_text(@state))
      end

      private def init_widgets(layout, info_text, state_text, top_texts_color: 'green')
        @info_text_widget  = Shapes::Text.new(info_text,
                                              x: layout.text_spacer, y: layout.info_text_y_offset,
                                              size: layout.font_size, color: top_texts_color)
        @state_text_widget = Shapes::Text.new(state_text,
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
      attr_reader :state, :window, :board
      attr_reader :info_text_widget, :state_text_widget, :event_text_widget

      def state=(new_state)
        @state = new_state
        state_text_widget.text = state_text(new_state)
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


      def info_text(tick)
        "time: #{Time.now.strftime('%T')}, tick: #{tick}"
      end

      def state_text(state)
        case state
        when States::WaitingForCellSelection then 'select cell'
        when States::CellSelected            then "you selected cell #{state.cell}"
        end
      end


      def set_event_handlers
        window.update do
          self.tick = tick + 1
          info_text_widget.text = info_text(tick)
        end

        window.on(:mouse_down, &method(:handle_click))
        window.on(:key_down,   &method(:handle_key))
      end

      def handle_click(event)
        event_text_widget.text = "clicked x: #{event.x}, y: #{event.y}"

        self.state = if board.contains?(event)
                     then States::CellSelected.new(board.cell_for(event))
                     else States::WaitingForCellSelection.new
                     end
      end

      def handle_key(event)
        exit if event.key == 'q'
      end
    end
  end
end
