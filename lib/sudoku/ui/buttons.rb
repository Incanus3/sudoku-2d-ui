module Sudoku
  module UI
    class Button
      DEFAULT_TEXT_COLOR   = 'white'.freeze
      DEFAULT_BORDER_COLOR = 'green'.freeze

      attr_reader :text, :data

      def initialize(data: nil, text: data.to_s, x:, y:, width:, height:,
                     border_color: DEFAULT_BORDER_COLOR, text_color: DEFAULT_TEXT_COLOR)
        @text = text
        @data = data

        # text size and offsets are duplicated from GridWithChars
        # TODO: extract this
        text_size     = 3.0 / 4   * height
        text_x_offset = 1.0 / 3.5 * height
        text_y_offset = 1.0 / 12  * height

        @border_rect = Shapes::Rectangle.new(x: x, y: y, width: width, height: height,
                                             border_color: border_color)
        @text_widget = Shapes::Text.new(text,
                                        x: x + text_x_offset, y: y + text_y_offset,
                                        size: text_size, color: text_color)
      end

      def add
        [@border_rect, @text_widget].each(&:add)
      end

      def remove
        [@border_rect, @text_widget].each(&:remove)
      end

      def contains?(coords)
        @border_rect.contains?(coords)
      end

      def inspect
        "<#{self.class.name} text: '#{text}', data: #{data.inspect}>"
      end

      def to_s
        inspect
      end
    end
  end
end
