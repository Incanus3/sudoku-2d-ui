require 'ruby2d'

module Shapes
  Line = Ruby2D::Line

  class Text < SimpleDelegator
    DEFAULT_FONT       = 'DejaVuSansMono.ttf'.freeze
    DEFAULT_FONT_SIZE  = 12
    DEFAULT_FONT_COLOR = 'white'.freeze

    def initialize(text, x:, y:,
                   font: DEFAULT_FONT, size: DEFAULT_FONT_SIZE, color: DEFAULT_FONT_COLOR)
      super(Ruby2D::Text.new(text, font: font, size: size, color: color, x: x, y: y))
    end
  end

  class Rectangle
    attr_reader :x, :y, :width, :height, :border_width, :border_color

    def initialize(x:, y:, width:, height:, border_width: 1, border_color: 'white')
      @x            = x
      @y            = y
      @width        = width
      @height       = height
      @border_width = border_width
      @border_color = border_color

      init_borders
    end

    private def init_borders
      @left   = Line.new(x1: x, y1: y,
                         x2: x, y2: y + height,
                         width: border_width, color: border_color)
      @right  = Line.new(x1: x + width, y1: y,
                         x2: x + width, y2: y + height,
                         width: border_width, color: border_color)
      @top    = Line.new(x1: x, y1: y,
                         x2: x + width, y2: y,
                         width: border_width, color: border_color)
      @bottom = Line.new(x1: x, y1: y + height,
                         x2: x + width, y2: y + height,
                         width: border_width, color: border_color)
    end

    def add
      [@left, @right, @top, @bottom].each(&:add)
    end

    def remove
      [@left, @right, @top, @bottom].each(&:remove)
    end

    def contains?(coords)
      @x <= coords.x && coords.x <= @x + @width && @y <= coords.y && coords.y <= @y + @height
    end
  end

  class Square < Rectangle
    def initialize(size:, **kwargs)
      super(width: size, height: size, **kwargs)
    end
  end
end
