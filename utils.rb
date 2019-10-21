require 'ruby2d'

module TextUtils
  extend self

  DEFAULT_FONT       = 'DejaVuSansMono.ttf'
  DEFAULT_FONT_SIZE  = 12
  DEFAULT_FONT_COLOR = 'green'

  def draw_text(text, x: 10, y: 10,
                font: DEFAULT_FONT, size: DEFAULT_FONT_SIZE, color: DEFAULT_FONT_COLOR)
    Ruby2D::Text.new(text, font: font, size: size, color: color, x: x, y: y)
  end
end
