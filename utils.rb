require 'ruby2d'

DEFAULT_FONT       = 'DejaVuSansMono.ttf'
DEFAULT_FONT_SIZE  = 12
DEFAULT_FONT_COLOR = 'green'

def get_info_text(tick)
  "time: #{Time.now.strftime('%T')}, tick: #{tick}"
end

def get_event_text(event)
  case event
  when Ruby2D::Window::MouseEvent
    "clicked x: #{event.x}, y: #{event.y}"
  end
end

def draw_text(text, x: 10, y: 10,
              font: DEFAULT_FONT, size: DEFAULT_FONT_SIZE, color: DEFAULT_FONT_COLOR)
  Text.new(text, font: font, size: size, color: color, x: x, y: y)
end

def draw_grid(x:, y:, size:, rows:, cols:, width: 1, color: 'white')
  cell_height = size / rows
  cell_width  = size / cols

  (0...rows).map do |row|
    Line.new(x1: x, y1: y + row * cell_height,
             x2: x + size, y2: y + row * cell_height,
             width: width, color: color)
  end

  (0...cols).map do |col|
    Line.new(x1: x + col * cell_width, y1: y,
             x2: x + col * cell_width, y2: y + size,
             width: width, color: color)
  end
end
