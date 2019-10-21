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
      [left, right, top, bottom].each(&:add)
    end

    def remove
      [left, right, top, bottom].each(&:remove)
    end

    def contains?(coords)
      x <= coords.x && coords.x <= x + size && y <= coords.y && coords.y <= y + size
    end

    private

    attr_reader :left, :right, :top, :bottom
  end
end
