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
    end
  end
end
