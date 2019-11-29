require_relative 'basic'

module Shapes
  class Grid
    Cell = Struct.new(:row, :column, :x, :y, :width, :height, keyword_init: true) do
      def inspect
        "#<#{self.class.name} row=#{row} column=#{column} x=#{x.to_i} y=#{y.to_i} " \
          "width=#{width.to_i} heigth=#{height.to_i}>"
      end

      def to_s
        "(#{row}, #{column})"
      end
    end

    attr_reader :cell_height, :cell_width

    def initialize(x:, y:, width:, height:, rows:, columns:, &cell_block)
      @x            = x
      @y            = y
      @width        = width
      @height       = height
      @rows         = rows
      @columns      = columns
      @cell_height  = height.to_f / rows
      @cell_width   = width.to_f  / columns

      @children = (0...@rows).flat_map do |row|
        (0...@columns).map do |column|
          cell_block.call(Cell.new(row: row + 1, column: column + 1,
                                   x: @x + column * @cell_width, y: @y + row * @cell_height,
                                   width: @cell_width, height: @cell_height))
        end
      end
    end

    def add
      @children.each(&:add)
    end

    def remove
      @children.each(&:remove)
    end

    def contains?(coords)
      # FIXME: this is duplicated in Rectangle
      @x <= coords.x && coords.x <= @x + @width && @y <= coords.y && coords.y <= @y + @height
    end

    def cell_for(coords)
      return unless contains?(coords)

      row    = ((coords.y - @y) / @cell_height + 1).to_i
      column = ((coords.x - @x) / @cell_width  + 1).to_i

      Cell.new(row: row, column: column)
    end
  end

  class GridWithBorders < Grid
    def initialize(border_width: 1, border_color: 'white', **kwargs)
      super(**kwargs) do |cell|
        Rectangle.new(x: cell.x, y: cell.y,
                      width: cell.width, height: cell.height,
                      border_width: border_width, border_color: border_color)
      end
    end
  end

  class GridWithChars < Grid
    def initialize(chars_matrix:, **kwargs)
      super(**kwargs) do |cell|
        Text.new(chars_matrix[cell.row - 1][cell.column - 1],
                 x: cell.x + 1.0 / 3.5 * cell.width,
                 y: cell.y + 1.0 / 12  * cell.height,
                 size: 3.0 / 4 * cell.height)
      end
    end
  end
end
