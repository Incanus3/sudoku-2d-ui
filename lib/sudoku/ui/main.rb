require 'ruby2d'
require_relative 'shapes'
require_relative 'output'
require_relative 'board'

# TODO: implement keyboard interaction

module Sudoku
  class UI
    DEFAULT_BOARD_SIZE = 600

    def initialize(grid, board_size: DEFAULT_BOARD_SIZE, margin: board_size / 15)
      @tick          = 0
      @state         = :waiting_for_cell_selection
      @selected_cell = nil

      init_sizes(board_size, margin)
      init_window

      @info_output  = Output.for(widget: @info_text)
      @state_output = Output.for(widget: @state_text)
      @event_output = Output.for(widget: @event_text)

      @board = board(grid, x: margin, y: texts_height + margin, size: board_size)

      init_buttons(x: margin, y: @board.y + @board.height + margin, width: buttons_height, height: buttons_height)
    end

    def show
      set_event_handlers

      @window.show
    end

    private

    attr_reader :full_spacer, :half_spacer, :font_size, :texts_height, :buttons_height
    attr_reader :window_width, :window_height


    # these have a lot of interdependencies, requiring initialize to call them in a specific order
    # TODO: try to think of a way to decouple these
    # - the simplest solution of course would be to return all the variables and pass them to the
    #   later methods, but that seems like too much noise and kind of kills the advantages of classes
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
      @separator  = horizontal_separator(position: texts_height, length: window_width)
    end

    def init_buttons(x:, y:, width:, height:)
      @buttons = (0..8).map do |i|
        button(text: i + 1, position: i, base_x: x, y: y, width: width, height: height)
      end
    end


    def button(text:, position:, base_x:, y:, width:, height:)
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
                       x: base_x + position * (width + spacer) + text_x_offset, y: y + text_y_offset,
                       size: text_size, color: 'green')
    end

    def board(grid, x:, y:, size:)
      Board.new(matrix: grid.matrix,
                x: x, y: y,
                width: size, height: size,
                border_color: 'green')
    end

    def horizontal_separator(position:, length:, offset: 0, width: 1, color: 'green')
      Shapes::Line.new(x1: offset, y1: position, x2: offset + length, y2: position,
                       width: width, color: color)
    end


    def info_text
      "time: #{Time.now.strftime('%T')}, tick: #{@tick}"
    end

    def state_text
      case @state
      when :waiting_for_cell_selection then 'select cell'
      when :cell_selected              then "you selected cell #{@selected_cell}"
      end
    end


    # the state and related values (e.g. selected cell) should be held together and we shouldn't
    # keep state variables that are irrelevant for given state
    # TODO: make a class for each state (inheriting from some common superclass) with instances
    # holding only the relevant data

    def set_state(new_state)
      @state = new_state
      @state_output << state_text
    end

    def select_cell(cell)
      @selected_cell = cell
      set_state(:cell_selected)
    end

    def deselect_cell
      @selected_cell = nil
      set_state(:waiting_for_cell_selection)
    end


    def set_event_handlers
      @window.update do
        @tick += 1
        @info_output << info_text
      end

      @window.on(:mouse_down, &self.:handle_click)
      @window.on(:key_down,   &self.:handle_key)
    end

    def handle_click(event)
      @event_output << "clicked x: #{event.x}, y: #{event.y}"

      if @board.contains?(event)
        select_cell(@board.cell_for(event))
      else
        deselect_cell()
      end
    end

    def handle_key(event)
      exit if event.key == 'q'
    end
  end
end
