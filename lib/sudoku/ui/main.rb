require 'ruby2d'
require_relative 'shapes'
require_relative 'output'
require_relative 'states'
require_relative 'board'

# TODO: implement keyboard interaction

module Sudoku
  class UI
    DEFAULT_BOARD_SIZE = 600

    def initialize(grid, board_size: DEFAULT_BOARD_SIZE, margin: board_size / 15)
      @tick  = 0
      @state = States::WaitingForCellSelection.new

      init_sizes(board_size, margin)
      init_window

      @info_output  = Output.for(widget: @info_text)
      @state_output = Output.for(widget: @state_text)
      @event_output = Output.for(widget: @event_text)

      @board = make_board(grid, x: margin, y: texts_height + margin, size: board_size)

      init_buttons(x: margin, y: @board.y + @board.height + margin,
                   width: buttons_height, height: buttons_height)
    end

    def show
      set_event_handlers

      window.show
    end

    private

    attr_accessor :tick
    attr_reader :state, :board, :window
    attr_reader :info_output, :state_output, :event_output
    attr_reader :full_spacer, :half_spacer, :font_size, :texts_height, :buttons_height
    attr_reader :window_width, :window_height

    def state=(new_state)
      @state = new_state
      state_output << state_text
    end


    # these have a lot of interdependencies, requiring initialize to call them in a specific order
    # TODO: try to think of a way to decouple these
    # - the simplest solution of course would be to return all the variables and pass them to the
    #   later methods, but that seems like too much noise and kinda kills the advantages of classes
    # - another think that might help would be to define a structure (or several) that would hold
    #   all the variables, that need to be passed around, then
    #   - we'd (hopefully) have the values coherently grouped together
    #   - could more easily pass them around
    #   - could even remove instance variable references from init methods

    def init_sizes(board_size, margin)
      @full_spacer    = margin / 5
      @half_spacer    = margin / 10
      @font_size      = full_spacer * 1.5
      @texts_height   = 3 * font_size + 4 * full_spacer
      @buttons_height = margin
      @window_width   = board_size + 2 * margin
      @window_height  = board_size + 3 * margin + texts_height + buttons_height
    end

    def init_window
      @window     = Ruby2D::Window.new(title: 'sudoku',
                                       width: window_width, height: window_height)
      @info_text  = Shapes::Text.new(info_text,
                                     x: full_spacer, y: full_spacer,
                                     size: font_size, color: 'green')
      @state_text = Shapes::Text.new(state_text,
                                     x: full_spacer,
                                     y: @info_text.y + @info_text.size + half_spacer,
                                     size: font_size, color: 'green')
      @event_text = Shapes::Text.new('',
                                     x: full_spacer,
                                     y: @state_text.y + @state_text.size + half_spacer,
                                     size: font_size, color: 'green')
      @separator  = make_horizontal_separator(position: texts_height, length: window_width)
    end

    def init_buttons(x:, y:, width:, height:)
      @buttons = (0..8).map do |i|
        make_button(text: i + 1, position: i, base_x: x, y: y, width: width, height: height)
      end
    end


    def make_button(text:, position:, base_x:, y:, width:, height:)
      spacer = 2 * full_spacer

      # text size and offsets are duplicated from GridWithChars
      # TODO: extract this
      text_size     = 3.0 / 4   * height
      text_x_offset = 1.0 / 3.5 * height
      text_y_offset = 1.0 / 12  * height

      # TODO: extract this into a Button shape and make it clickable
      Shapes::Rectangle.new(x: base_x + position * (width + spacer), y: y,
                            width: width, height: height, border_color: 'green')
      Shapes::Text.new(text,
                       x: base_x + position * (width + spacer) + text_x_offset,
                       y: y + text_y_offset,
                       size: text_size, color: 'green')
    end

    def make_board(grid, x:, y:, size:)
      Board.new(matrix: grid.matrix,
                x: x, y: y,
                width: size, height: size,
                border_color: 'green')
    end

    def make_horizontal_separator(position:, length:, offset: 0, width: 1, color: 'green')
      Shapes::Line.new(x1: offset, y1: position, x2: offset + length, y2: position,
                       width: width, color: color)
    end


    def info_text
      "time: #{Time.now.strftime('%T')}, tick: #{tick}"
    end

    def state_text
      case state
      when States::WaitingForCellSelection then 'select cell'
      when States::CellSelected            then "you selected cell #{state.cell}"
      end
    end


    def set_event_handlers
      window.update do
        self.tick = tick + 1
        info_output << info_text
      end

      window.on(:mouse_down, &method(:handle_click))
      window.on(:key_down,   &method(:handle_key))
    end

    def handle_click(event)
      event_output << "clicked x: #{event.x}, y: #{event.y}"

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
