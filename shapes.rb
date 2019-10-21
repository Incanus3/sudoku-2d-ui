require 'ruby2d'

module CustomShapes
  class Square
    attr_reader :x, :y, :size, :width, :color

    def initialize(x:, y:, size:, width: 1, color: 'white')
      @x      = x
      @y      = y
      @size   = size
      @width  = width
      @color  = color

      @left   = Line.new(x1: x, y1: y,
                         x2: x, y2: y + size,
                         width: width, color: color)
      @right  = Line.new(x1: x + size, y1: y,
                         x2: x + size, y2: y + size,
                         width: width, color: color)
      @top    = Line.new(x1: x, y1: y,
                         x2: x + size, y2: y,
                         width: width, color: color)
      @bottom = Line.new(x1: x, y1: y + size,
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
    def initialize(x:, y:, size:, rows:, cols:, width: 1, color: 'white')
      cell_height = size / rows
      cell_width  = size / cols

      @lines = (0...rows).map do |row|
        Line.new(x1: x, y1: y + row * cell_height,
                 x2: x + size, y2: y + row * cell_height,
                 width: width, color: color)
      end

      @lines += (0...cols).map do |col|
        Line.new(x1: x + col * cell_width, y1: y,
                 x2: x + col * cell_width, y2: y + size,
                 width: width, color: color)
      end
    end

    def add
      @lines.each(&:add)
    end

    def remove
      @lines.each(&:remove)
    end
  end
end
