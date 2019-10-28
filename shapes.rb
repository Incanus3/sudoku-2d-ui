require 'ruby2d'
require_relative 'utils'

module CustomShapes
  class Square
    attr_reader :x, :y, :size, :width, :color

    def initialize(x:, y:, size:, width: 1, color: 'white')
      @x      = x
      @y      = y
      @size   = size
      @width  = width
      @color  = color

      @left   = Ruby2D::Line.new(x1: x, y1: y,
                                 x2: x, y2: y + size,
                                 width: width, color: color)
      @right  = Ruby2D::Line.new(x1: x + size, y1: y,
                                 x2: x + size, y2: y + size,
                                 width: width, color: color)
      @top    = Ruby2D::Line.new(x1: x, y1: y,
                                 x2: x + size, y2: y,
                                 width: width, color: color)
      @bottom = Ruby2D::Line.new(x1: x, y1: y + size,
                                 x2: x + size, y2: y + size,
                                 width: width, color: color)
    end

    def add
      [@left, @right, @top, @bottom].each(&:add)
    end

    def remove
      [@left, @right, @top, @bottom].each(&:remove)
    end

    def contains?(coords)
      @x <= coords.x && coords.x <= @x + @size && @y <= coords.y && coords.y <= @y + @size
    end
  end

  class Grid
    Cell = Struct.new(:row, :column) do
      def inspect
        "#<#{self.class.name} row=#{row} column=#{column}>"
      end

      def to_s
        "(#{row}, #{column})"
      end
    end

    attr_reader :cell_height, :cell_width

    def initialize(x:, y:, size:, rows:, columns:, width: 1, color: 'white')
      @x       = x
      @y       = y
      @size    = size
      @rows    = rows
      @columns = columns
      @width   = width
      @color   = color

      @cell_height = size.to_f / rows
      @cell_width  = size.to_f / columns

      @lines = (0...rows).map do |row|
        Ruby2D::Line.new(x1: x, y1: y + row * cell_height,
                         x2: x + size, y2: y + row * cell_height,
                         width: width, color: color)
      end

      @lines += (0...columns).map do |column|
        Ruby2D::Line.new(x1: x + column * cell_width, y1: y,
                         x2: x + column * cell_width, y2: y + size,
                         width: width, color: color)
      end
    end

    def add
      @lines.each(&:add)
    end

    def remove
      @lines.each(&:remove)
    end

    def cell_for(coords)
      row    = ((coords.y - @y) / @cell_height + 1).to_i
      column = ((coords.x - @x) / @cell_width  + 1).to_i

      Cell.new(row, column)
    end
  end

  class GridWithChars < Grid
    def initialize(chars_matrix:, **kwargs)
      super(**kwargs)

      @chars_matrix = chars_matrix
      @char_texts   = @chars_matrix.each_with_index.flat_map do |row_chars, row_index|
        row_chars.each_with_index.map do |col_char, col_index|
          TextUtils.draw_text(col_char,
                              x: @x + col_index * @cell_width  + 1.0/4  * @cell_width,
                              y: @y + row_index * @cell_height + 1.0/10 * @cell_height,
                              size: 3.0/4 * @cell_height)
        end
      end
    end

    def add
      super

      @char_texts.each(&:add)
    end

    def remove
      super

      @char_texts.each(&:remove)
    end
  end
end
