require 'ruby2d'
require 'dry-monads'

require 'sudoku/ui/shapes'
require 'sudoku/ui/buttons'
require 'sudoku/ui/board'

require_relative 'layout'
require_relative 'events'
require_relative 'states'

module Sudoku
  module UI
    class MainWindow
      include Dry::Monads[:result]

      DEFAULT_BOARD_SIZE = 600
      DEFAULT_TEXT_COLOR = 'green'.freeze
      ERROR_TEXT_COLOR   = 'red'.freeze
      BOARD_MARGIN_RATIO = 15

      def initialize(client,
                     board_size: DEFAULT_BOARD_SIZE, margin: board_size / BOARD_MARGIN_RATIO)
        layout = self.class::Layout.new(board_size, margin)

        @tick   = 0
        @client = client

        client.create_game.bind do |game, _|
          @game   = game
          @state  = States::WaitingForCellSelection.new
          @window = Ruby2D::Window.new(title: 'sudoku',
                                       width: layout.window_width, height: layout.window_height)
          @board  = Board.new(grid: game.grid,
                              x: layout.board_x_offset, y: layout.board_y_offset,
                              width: layout.board_size, height: layout.board_size)

          init_widgets(layout, @state)
        end
      end

      private def init_widgets(layout, state, top_texts_color: DEFAULT_TEXT_COLOR)
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

      attr_accessor :tick, :game
      attr_reader :client, :state, :window, :board
      attr_reader :info_text_widget, :state_text_widget, :event_text_widget

      def state=(new_state)
        @state = new_state
        state_text_widget.text = new_state.text
      end

      def error=(error)
        event_text_widget.text  = error
        event_text_widget.color = ERROR_TEXT_COLOR
      end

      def clear_error
        event_text_widget.text  = ''
        event_text_widget.color = DEFAULT_TEXT_COLOR
      end


      def buttons(layout)
        width = layout.buttons_height

        (0..8).map { |index|
          Sudoku::UI::Button.new(
            data: index + 1,
            x: layout.buttons_x_offset + index * (width + layout.button_spacer),
            y: layout.buttons_y_offset,
            width: width,
            height: layout.buttons_height
          )
        }
      end

      def horizontal_separator(position:, length:, offset: 0, width: 1, color: DEFAULT_TEXT_COLOR)
        Shapes::Line.new(x1: offset,          y1: position,
                         x2: offset + length, y2: position,
                         width: width, color: color)
      end


      def set_event_handlers
        window.update do
          self.tick = tick + 1
          info_text_widget.text = "time: #{Time.now.strftime('%T')}, tick: #{tick}"
        end

        window.on(:key_down,   &method(:handle_key))
        window.on(:mouse_down, &method(:handle_click))
      end

      def handle_key(event)
        exit if event.key == 'q'
      end

      def handle_click(click_event)
        clear_error

        event = translate_event(click_event, self.board)
        event = trigger_side_effects_for(self.state, event)

        self.state = new_state_for(self.state, self.board, event)
      end


      def translate_event(click_event, board)
        if board.contains?(click_event)
          Events::CellClicked.new(board.cell_for(click_event))
        elsif (clicked_button = @buttons.find { |button| button.contains?(click_event) })
          Events::ButtonClicked.new(clicked_button)
        else
          Events::Dummy.new
        end
      end

      def trigger_side_effects_for(current_state, event)
        case [current_state, event]
        in [States::EmptyCellSelected, Events::ButtonClicked]
          case fill_cell(current_state.cell, event.button.data)
          in Success(_, finished) then Events::CellFilled.new(finished)
          in Failure(_)           then Events::Dummy.new
          end
        else
          event
        end
      end

      def new_state_for(current_state, board, event)
        case [current_state, event]
        in [States::Victory, _]
          current_state
        in [_, Events::CellClicked]
          if board.cell_filled?(event.cell)
            States::FilledCellSelected.new(event.cell)
          else
            States::EmptyCellSelected.new(event.cell)
          end
        in [_, Events::CellFilled]
          event.finished ? States::Victory.new : States::WaitingForCellSelection.new
        else
          current_state
        end
      end


      def fill_cell(cell, number)
        case result = client.fill_cell(game, cell, number)
        in Success        then board.fill_cell(cell, number)
        in Failure(error) then self.error = error
        end

        result
      end
    end
  end
end
