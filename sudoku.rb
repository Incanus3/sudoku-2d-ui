require 'ruby2d'
require_relative 'utils'
require_relative 'shapes'

BOARD_SIZE = 900
BOARD_X    = 50
BOARD_Y    = 50


set title: 'sudoku', width: BOARD_SIZE + 2 * BOARD_X, height: BOARD_SIZE + 2 * BOARD_Y

tick = 0

info_text  = draw_text(get_info_text(tick), y: 10)
event_text = draw_text(''                 , y: info_text.y + DEFAULT_FONT_SIZE + 5)

main_border = CustomShapes::Square.new(x: BOARD_X, y: BOARD_Y, size: BOARD_SIZE, width: 5, color: 'green')

draw_grid(x: BOARD_X, y: BOARD_Y, size: BOARD_SIZE, rows: 9, cols: 9, width: 1, color: 'green')
draw_grid(x: BOARD_X, y: BOARD_Y, size: BOARD_SIZE, rows: 3, cols: 3, width: 3, color: 'green')


update do
  tick          += 1
  info_text.text = get_info_text(tick)
end

on :mouse_down do |event|
  hit             = main_border.contains?(event)
  event_text.text = ("#{get_event_text(event)}, hit the square: #{hit ? 'yes' : 'no'}")
end


show
