module Sudoku
  module UI
    class Button
      DEFAULT_TEXT_COLOR   = 'white'.freeze
      DEFAULT_BORDER_COLOR = 'green'.freeze

      def initialize(text:, x:, y:, width:, height:, border_color: DEFAULT_BORDER_COLOR,
                     text_color: DEFAULT_TEXT_COLOR)
        # text size and offsets are duplicated from GridWithChars
        # TODO: extract this
        text_size     = 3.0 / 4   * height
        text_x_offset = 1.0 / 3.5 * height
        text_y_offset = 1.0 / 12  * height

        @border = Shapes::Rectangle.new(x: x, y: y, width: width, height: height,
                                        border_color: border_color)
        @text   = Shapes::Text.new(text,
                                   x: x + text_x_offset, y: y + text_y_offset,
                                   size: text_size, color: text_color)
      end

      def add
        [@border, @text].each(&:add)
      end

      def remove
        [@border, @text].each(&:remove)
      end

      def contains?(coords)
        @border.contains?(coords)
      end
    end
  end
end
