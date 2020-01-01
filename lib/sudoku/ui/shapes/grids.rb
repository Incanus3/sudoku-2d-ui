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
      @children     = {}

      (1..@rows).each do |row|
        (1..@columns).each do |column|
          @children[[row, column]] = cell_block.call(full_cell_for(row, column))
        end
      end
    end

    def add
      @children.values.compact.each(&:add)
    end

    def remove
      @children.values.compact.each(&:remove)
    end

    def set_child_at(cell, new_child)
      @children[[cell.row, cell.column]]&.remove
      @children[[cell.row, cell.column]] = new_child
    end

    def contains?(coords)
      # FIXME: this is duplicated in Rectangle
      @x <= coords.x && coords.x <= @x + @width && @y <= coords.y && coords.y <= @y + @height
    end

    def cell_for(coords)
      return unless contains?(coords)

      row    = ((coords.y - @y) / @cell_height + 1).to_i
      column = ((coords.x - @x) / @cell_width  + 1).to_i

      full_cell_for(row, column)
    end

    def full_cell_for(row, column)
      Cell.new(row: row, column: column,
               x: @x + (column - 1) * @cell_width, y: @y + (row - 1) * @cell_height,
               width: @cell_width, height: @cell_height)
    end
  end

  class GridWithBorders < Grid
    def initialize(border_width: 1, border_color: 'white', **kwargs)
      @border_width = border_width
      @border_color = border_color

      super(**kwargs) { |cell| rectange_for(cell) }
    end

    def rectange_for(cell)
      Rectangle.new(x: cell.x, y: cell.y,
                    width: cell.width, height: cell.height,
                    border_width: @border_width, border_color: @border_color)
    end
  end

  class GridWithChars < Grid
    def initialize(chars_matrix:, **kwargs)
      super(**kwargs) { |cell| text_for(cell, chars_matrix[cell.row - 1][cell.column - 1]) }
    end

    def text_for(cell, number)
      Text.new(number,
               x: cell.x + 1.0 / 3.5 * cell.width,
               y: cell.y + 1.0 / 12  * cell.height,
               size: 3.0 / 4 * cell.height)
    end

    def set_number_at(cell, number)
      set_child_at(cell, text_for(cell, number))
    end
  end
end
