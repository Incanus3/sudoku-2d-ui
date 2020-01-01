require 'ruby2d'

class MultiText
  FONT = 'DejaVuSansMono.ttf'.freeze

  def initialize(number = 100)
    @texts = number.times.map { render_text }
  end

  def render_text
    Ruby2D::Text.new('test', font: FONT, size: 10, x: 10, y: 10)
  end

  def add
    @texts.each(&:add)
  end

  def remove
    @texts.each(&:remove)
  end
end


window = Ruby2D::Window.new(title: 'test', width: 100, height: 100)
multi  = MultiText.new

5.times do |i|
  puts "starting loop #{i}"

  multi.remove
  multi = nil

  GC.start

  # when number is >= 447, this fails with Error: (TTF_OpenFont) Couldn't open DejaVuSansMono.ttf
  multi = MultiText.new(447)
end

window.on(:key_down) { |event| exit if event.key == 'q' }

window.show
